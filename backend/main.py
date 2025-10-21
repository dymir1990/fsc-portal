import os, csv, io
from datetime import datetime, timezone
from fastapi import FastAPI, UploadFile, File, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from supabase import create_client, Client

# --- setup ---
load_dotenv()
SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_SERVICE_ROLE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
ALLOWED_ORIGIN = os.getenv("ALLOWED_ORIGIN", "https://app.fscnj.com")

SB: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

app = FastAPI()

# Parse comma-separated origins, with production default
origins = [o.strip() for o in ALLOWED_ORIGIN.split(",") if o.strip()]

# Add common development origins if not in production
if not any('fscnj.com' in o for o in origins):
    origins.extend([
        "http://localhost:5173",
        "http://localhost:5174",
        "http://127.0.0.1:5173"
    ])

# Add Vercel domains for deployment
vercel_domains = [
    "https://fsc-portal-my54f0rua-dymirs-projects.vercel.app",
    "https://fsc-portal-ko030riu2-dymirs-projects.vercel.app"
]
for domain in vercel_domains:
    if domain not in origins:
        origins.append(domain)

# Add all vercel.app domains for flexibility
origins.append("https://*.vercel.app")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Temporarily allow all origins for testing
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)

def require_user(authorization: str | None = Header(default=None)):
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(401, "Missing or invalid authorization header")

    token = authorization.split(" ", 1)[1].strip()
    if not token:
        raise HTTPException(401, "Missing access token")

    try:
        user_response = SB.auth.get_user(jwt=token)
    except Exception as e:
        raise HTTPException(401, "Auth check failed") from e

    user = getattr(user_response, "user", None)
    if not user:
        raise HTTPException(401, "Invalid session")

    return user

# --- routes ---
@app.get("/health")
def health():
    return {"ok": True}

@app.get("/api/payers")
def get_payers(current_user = Depends(require_user)):
    """Get all active payers with their billing routes."""
    _ = current_user  # auth check
    payers = SB.table("payers").select("id,name,billing_route,status").eq("status", "Active").order("name").execute()
    return {"payers": payers.data}

@app.get("/api/imports/history")
def get_import_history(current_user = Depends(require_user)):
    """Get import history."""
    _ = current_user  # auth check
    history = SB.table("import_runs").select("id,file_name,started_at,finished_at,total_rows,inserted_rows,updated_rows,flagged_rows").order("started_at", desc=True).limit(10).execute()
    return history.data

@app.get("/api/user/profile")
def get_user_profile(current_user = Depends(require_user)):
    """Get current user's profile information."""
    _ = current_user  # auth check
    profile = SB.table("profiles").select("id,role").eq("id", current_user["id"]).single().execute()
    return profile.data

@app.get("/api/sessions")
def get_sessions(current_user = Depends(require_user)):
    """Get all sessions with client and provider details including insurance payer."""
    _ = current_user  # auth check
    sessions = SB.table("sessions").select("id,session_date,client_id,provider_id,payer_uuid,minutes,note_submitted,is_duplicate,billing_status,amount_billed,amount_paid,date_submitted,date_paid,clients(name),providers(name),payers(name)").order("session_date", desc=True).limit(100).execute()
    return sessions.data

# --- helpers ---
def find_provider(name: str | None):
    if not name: return None
    r = SB.table("providers").select("id").ilike("name", name).limit(1).execute().data
    return r[0] if r else None

def find_client(name: str | None):
    if not name: return None
    r = SB.table("clients").select("id").ilike("name", name).limit(1).execute().data
    return r[0] if r else None

def to_minutes(start_s: str | None, end_s: str | None) -> int | None:
    if not start_s or not end_s: return None
    from datetime import datetime as dt
    for f in ("%H:%M", "%I:%M %p"):
        try:
            start = dt.strptime(start_s.strip(), f)
            end = dt.strptime(end_s.strip(), f)
            return max(0, round((end - start).seconds / 60))
        except: pass
    return None

# Accepts columns with any of these header aliases:
COLS = {
    "provider_name": [
        "provider_name",
        "provider",
        "therapist",
        "therapist_name",
        "primary clinician",
        "Primary clinician",
    ],
    "client_name":   [
        "client_name",
        "client",
        "Client",
        "client_full_name",
        "patient_name",
    ],
    "service_date":  [
        "service_date",
        "date",
        "session_date",
        "Date added",
        "date added",
    ],
    "client_type": [
        "client_type",
        "Client type",
        "client category",
    ],
    "primary_insurance": [
        "primary_insurance",
        "Primary insurance",
    ],
    "billing_route": [
        "billing_route",
        "Billing route",
        "billing_channel",
        "Billing channel",
        "billing",
    ],
    "start_time":    ["start_time","start","start_at","from"],
    "end_time":      ["end_time","end","end_at","to"],
    "minutes":       ["minutes","duration","length_min"],
    "insurance_type":["insurance_type","payer","insurance"],
    "note_status":   ["note_status","note","notes","status"],
    "sp_session_id": ["sp_session_id","appointment_id","session_id","id"],
}

def pick(row: dict, keys: list[str]) -> str | None:
    for k in keys:
        if k in row and str(row[k]).strip() != "": return str(row[k]).strip()
    return None


@app.post("/api/imports/simplepractice")
async def import_simplepractice(file: UploadFile = File(...), current_user = Depends(require_user)):
    if not file.filename or not file.filename.lower().endswith(".csv"):
        raise HTTPException(400, "Please upload a .csv file.")

    # audit start
    _ = current_user  # force evaluation of auth dependency
    run = SB.table("import_runs").insert({
        "source":"simplepractice",
        "file_name": file.filename,
        "started_at": datetime.now(timezone.utc).isoformat()
    }).execute().data[0]

    total=inserted=updated=flagged=duplicates=0
    errors=[]
    flagged_preview=[]

    payload_bytes = await file.read()
    reader = csv.DictReader(io.StringIO(payload_bytes.decode("utf-8", errors="ignore")))

    for i, row in enumerate(reader, start=1):
        total += 1
        try:
            provider_name = pick(row, COLS["provider_name"])
            client_name   = pick(row, COLS["client_name"])
            service_date  = pick(row, COLS["service_date"])
            start_time    = pick(row, COLS["start_time"])
            end_time      = pick(row, COLS["end_time"])
            minutes_val   = pick(row, COLS["minutes"])
            insurance     = pick(row, COLS["insurance_type"])
            note_status   = (pick(row, COLS["note_status"]) or "").lower()
            sp_id         = pick(row, COLS["sp_session_id"])
            client_type   = pick(row, COLS["client_type"])
            primary_ins   = pick(row, COLS["primary_insurance"])
            billing_route = pick(row, COLS["billing_route"]) or "simplepractice"

            prov = find_provider(provider_name)
            cli  = find_client(client_name)

            if not prov or not cli or not service_date:
                reason = "missing_provider" if not prov else ("missing_client" if not cli else "missing_date")
                SB.table("import_staging").insert({
                    "run_id": run["id"],
                    "raw": row,
                    "reason": reason
                }).execute()
                if len(flagged_preview) < 10:
                    flagged_preview.append({
                        "reason": reason,
                        "provider_name": provider_name,
                        "client_name": client_name,
                        "service_date": service_date
                    })
                flagged += 1
                continue

            # minutes (fallback from times)
            minutes = int(minutes_val) if (minutes_val and minutes_val.isdigit()) else to_minutes(start_time, end_time)

            session_payload = {
                "provider_id": prov["id"],
                "client_id": cli["id"],
                "session_date": service_date,
                "start_time": start_time or "",
                "end_time": end_time or "",
                "minutes": minutes,
                "insurance_type": insurance,
                "note_submitted": note_status in ("submitted","finalized","complete","completed"),
                "billing_status": "completed",  # Default status for new imports
                "external_source": "simplepractice",
                "external_session_id": sp_id,
                "imported_at": datetime.now(timezone.utc).isoformat(),
                "client_type": client_type,
                "primary_insurance": primary_ins,
                "billing_route": billing_route,
            }

            # upsert by external_session_id if present; else fallback to natural key
            if sp_id:
                existing = SB.table("sessions").select("id")\
                    .eq("external_source","simplepractice").eq("external_session_id", sp_id)\
                    .limit(1).execute().data
                if existing:
                    session_payload["is_duplicate"] = True
                    SB.table("sessions").update(session_payload).eq("id", existing[0]["id"]).execute()
                    updated += 1
                    duplicates += 1
                else:
                    session_payload["is_duplicate"] = False
                    SB.table("sessions").insert(session_payload).execute()
                    inserted += 1
            else:
                existing = SB.table("sessions").select("id")\
                    .eq("provider_id", prov["id"]).eq("client_id", cli["id"])\
                    .eq("session_date", service_date).eq("start_time", start_time or "").eq("end_time", end_time or "")\
                    .limit(1).execute().data
                if existing:
                    session_payload["is_duplicate"] = True
                    SB.table("sessions").update(session_payload).eq("id", existing[0]["id"]).execute()
                    updated += 1
                    duplicates += 1
                else:
                    session_payload["is_duplicate"] = False
                    SB.table("sessions").insert(session_payload).execute()
                    inserted += 1

        except Exception as e:
            flagged += 1
            errors.append({"row": i, "error": str(e)})

    SB.table("import_runs").update({
        "finished_at": datetime.now(timezone.utc).isoformat(),
        "total_rows": total,
        "inserted_rows": inserted,
        "updated_rows": updated,
        "flagged_rows": flagged,
        "errors": errors
    }).eq("id", run["id"]).execute()

    return {
        "run_id": run["id"],
        "total": total,
        "inserted": inserted,
        "updated": updated,
        "flagged": flagged,
        "errors": len(errors),
        "duplicates": duplicates,
        "flagged_preview": flagged_preview,
        "errors_detail": errors[:10]
    }
