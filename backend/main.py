"""
Fixed CSV Import Handler for FSC Portal
This module handles CSV uploads and creates sessions in the database
"""

import os
import csv
import io
from datetime import datetime, timezone
from fastapi import FastAPI, UploadFile, File, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Import the Supabase client from main.py if available
try:
    from main import SB, require_user
except ImportError:
    logger.warning("Could not import from main.py, using standalone configuration")
    from dotenv import load_dotenv
    from supabase import create_client, Client
    
    load_dotenv()
    SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
    SUPABASE_SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    
    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:
        SB: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    else:
        logger.error("Supabase credentials not found in environment variables")
        SB = None

app = FastAPI(title="FSC Portal CSV Import Fix")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ImportResult(BaseModel):
    """Result of CSV import operation"""
    success: bool
    run_id: Optional[str] = None
    total: int = 0
    inserted: int = 0
    updated: int = 0
    flagged: int = 0
    duplicates: int = 0
    errors: int = 0
    flagged_preview: List[Dict[str, Any]] = []
    errors_detail: List[Dict[str, Any]] = []
    message: str = ""

def parse_insurance_info(insurance_string: str) -> tuple[str, Optional[str]]:
    """
    Parse insurance string to extract company name and ID
    Example: "Horizon NJ Health (22356)" -> ("Horizon NJ Health", "22356")
    """
    if not insurance_string:
        return ("Unknown", None)
    
    # Check if there's an ID in parentheses
    if "(" in insurance_string and ")" in insurance_string:
        name_part = insurance_string.split("(")[0].strip()
        id_part = insurance_string.split("(")[1].replace(")", "").strip()
        return (name_part, id_part)
    
    return (insurance_string.strip(), None)

def parse_time_to_minutes(start_time: str, end_time: str) -> Optional[int]:
    """Convert start and end times to minutes"""
    if not start_time or not end_time:
        return None
    
    try:
        # Parse times
        start = datetime.strptime(start_time.strip(), "%I:%M %p")
        end = datetime.strptime(end_time.strip(), "%I:%M %p")
        
        # Calculate difference in minutes
        diff = (end - start).total_seconds() / 60
        return max(0, int(diff))
    except Exception as e:
        logger.warning(f"Could not parse times {start_time} - {end_time}: {e}")
        return None

def find_or_create_provider(name: str) -> Optional[dict]:
    """Find provider or create if doesn't exist"""
    if not name:
        logger.warning("find_or_create_provider called with empty name")
        return None
    
    if not SB:
        logger.error("Supabase client (SB) is not initialized!")
        return None
    
    try:
        logger.info(f"Searching for provider: {name}")
        
        # Try to find existing provider - use eq for exact match first
        result = SB.table("providers").select("id").eq("name", name.strip()).limit(1).execute()
        
        if result.data and len(result.data) > 0:
            logger.info(f"✓ Found existing provider: {name} (ID: {result.data[0]['id']})")
            return result.data[0]
        
        # Not found, create new provider
        logger.info(f"Provider '{name}' not found, creating new...")
        new_provider = SB.table("providers").insert({"name": name.strip()}).execute()
        
        if new_provider.data and len(new_provider.data) > 0:
            logger.info(f"✓ Created new provider: {name} (ID: {new_provider.data[0]['id']})")
            return new_provider.data[0]
        else:
            logger.error(f"✗ Insert returned no data for provider: {name}")
            logger.error(f"Response: {new_provider}")
            return None
            
    except Exception as e:
        logger.error(f"✗ Exception creating/finding provider '{name}': {type(e).__name__}: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return None
    
    logger.error(f"✗ Fell through - provider '{name}' failed for unknown reason")
    return None

def find_or_create_client(name: str) -> Optional[dict]:
    """Find client or create if doesn't exist"""
    if not name:
        logger.warning("find_or_create_client called with empty name")
        return None
    
    if not SB:
        logger.error("Supabase client (SB) is not initialized!")
        return None
    
    try:
        logger.info(f"Searching for client: {name}")
        
        # Try to find existing client - use eq for exact match first
        result = SB.table("clients").select("id").eq("name", name.strip()).limit(1).execute()
        
        if result.data and len(result.data) > 0:
            logger.info(f"✓ Found existing client: {name} (ID: {result.data[0]['id']})")
            return result.data[0]
        
        # Not found, create new client
        logger.info(f"Client '{name}' not found, creating new...")
        new_client = SB.table("clients").insert({"name": name.strip()}).execute()
        
        if new_client.data and len(new_client.data) > 0:
            logger.info(f"✓ Created new client: {name} (ID: {new_client.data[0]['id']})")
            return new_client.data[0]
        else:
            logger.error(f"✗ Insert returned no data for client: {name}")
            logger.error(f"Response: {new_client}")
            return None
            
    except Exception as e:
        logger.error(f"✗ Exception creating/finding client '{name}': {type(e).__name__}: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return None
    
    logger.error(f"✗ Fell through - client '{name}' failed for unknown reason")
    return None

def find_or_create_payer(insurance_string: str, billing_route: str = "simplepractice") -> Optional[str]:
    """Find or create payer and return UUID"""
    if not insurance_string or not SB:
        return None
    
    payer_name, payer_id = parse_insurance_info(insurance_string)
    
    try:
        # Try to find existing payer by name (case-insensitive)
        result = SB.table("payers").select("id").ilike("name", payer_name).limit(1).execute()
        if result.data:
            logger.info(f"✓ Found existing payer: {payer_name}")
            return result.data[0]['id']
        
        # Create new payer (payers table uses 'id' not 'uuid')
        logger.info(f"Creating new payer: {payer_name} (payer_id: {payer_id})")
        new_payer = SB.table("payers").insert({
            "name": payer_name,
            "payer_id": payer_id,
            "billing_route": billing_route,
            "status": "Active"
        }).execute()
        
        if new_payer.data:
            logger.info(f"✓ Created new payer: {payer_name} (ID: {new_payer.data[0]['id']})")
            return new_payer.data[0]['id']
        else:
            logger.error(f"✗ Failed to create payer: {payer_name}")
            return None
    except Exception as e:
        logger.error(f"✗ Error with payer {payer_name}: {e}")
        import traceback
        logger.error(traceback.format_exc())
    
    return None

@app.post("/api/imports/simplepractice", response_model=ImportResult)
async def import_simplepractice(file: UploadFile = File(...)):
    """
    Fixed version of the SimplePractice CSV import handler
    """
    logger.info(f"Starting CSV import: {file.filename}")
    
    # Check database connection
    if not SB:
        logger.error("Database connection not available")
        return ImportResult(
            success=False,
            message="Database connection error. Please check configuration.",
            errors=1
        )
    
    # Validate file
    if not file.filename or not file.filename.lower().endswith(".csv"):
        return ImportResult(
            success=False,
            message="Please upload a valid CSV file",
            errors=1
        )
    
    # Create import run record
    try:
        run_data = SB.table("import_runs").insert({
            "source": "simplepractice",
            "file_name": file.filename,
            "started_at": datetime.now(timezone.utc).isoformat()
        }).execute()
        
        if not run_data.data:
            logger.error("Could not create import run record")
            return ImportResult(
                success=False,
                message="Could not initialize import. Please check database connection.",
                errors=1
            )
        
        run = run_data.data[0]
        run_id = run["id"]
        logger.info(f"Created import run ID: {run_id}")
    except Exception as e:
        logger.error(f"Error creating import run: {e}")
        return ImportResult(
            success=False,
            message=f"Database error: {str(e)}",
            errors=1
        )
    
    # Process CSV
    total = inserted = updated = flagged = duplicates = errors = 0
    errors_list = []
    flagged_preview = []
    
    try:
        # Read and decode CSV file
        payload_bytes = await file.read()
        csv_text = payload_bytes.decode("utf-8", errors="ignore")
        
        # Parse CSV
        reader = csv.DictReader(io.StringIO(csv_text))
        
        # Track seen records for duplicate detection
        seen_records = set()
        
        for row_num, row in enumerate(reader, start=2):  # Start at 2 to account for header
            total += 1
            
            try:
                # Extract fields (handle BOTH SimplePractice CSV formats)
                client_name = row.get("Client", row.get("client", "")).strip()
                client_type = row.get("Client type", row.get("client_type", "")).strip()
                
                # Handle BOTH "Date of Service" (new format) and "Date added" (old format)
                service_date = row.get("Date of Service", row.get("Date added", row.get("service_date", ""))).strip()
                
                # Handle BOTH "Clinician" (new format) and "Primary clinician" (old format)
                provider_name = row.get("Clinician", row.get("Primary clinician", row.get("provider", ""))).strip()
                
                # Parse start_time from "Date of Service" if needed (format: "10/06/2025 12:00")
                start_time = row.get("Start time", row.get("start_time", "")).strip()
                if not start_time and service_date and " " in service_date:
                    # Extract time from "MM/DD/YYYY HH:MM" format
                    date_parts = service_date.split(" ", 1)
                    if len(date_parts) == 2:
                        service_date = date_parts[0]  # Just the date part
                        start_time = date_parts[1]     # Just the time part
                
                end_time = row.get("End time", row.get("end_time", "")).strip()
                minutes_str = row.get("Minutes", row.get("minutes", "")).strip()
                
                # Handle BOTH "Primary Insurance" (new format) and "Primary insurance" (old format)
                primary_insurance = row.get("Primary Insurance", row.get("Primary insurance", row.get("insurance", ""))).strip()
                
                billing_route = row.get("Billing route", row.get("billing_route", "simplepractice")).strip()
                status = row.get("Status", row.get("status", "")).strip()
                notes = row.get("Notes", row.get("notes", "")).strip()
                
                logger.info(f"Processing row {row_num}: {client_name} - {provider_name} - {service_date}")
                
                # Check for duplicates
                record_key = (client_name, service_date, start_time, provider_name)
                if record_key in seen_records:
                    duplicates += 1
                    logger.warning(f"Duplicate record found at row {row_num}: {record_key}")
                    continue
                seen_records.add(record_key)
                
                # Validate required fields
                if not client_name or not provider_name or not service_date:
                    reason = "missing_data"
                    details = []
                    if not client_name:
                        details.append("client")
                    if not provider_name:
                        details.append("provider")
                    if not service_date:
                        details.append("date")
                    
                    flagged += 1
                    if len(flagged_preview) < 10:
                        flagged_preview.append({
                            "reason": f"missing_{', '.join(details)}",
                            "client_name": client_name or "Unknown",
                            "provider_name": provider_name or "Unknown",
                            "service_date": service_date or "Unknown",
                            "row": row_num
                        })
                    
                    logger.warning(f"Row {row_num} flagged: missing {', '.join(details)}")
                    
                    # Store in staging table
                    if SB:
                        try:
                            SB.table("import_staging").insert({
                                "run_id": run_id,
                                "raw": row,
                                "reason": f"missing_{', '.join(details)}"
                            }).execute()
                        except Exception as e:
                            logger.error(f"Could not save to staging: {e}")
                    continue
                
                # Convert date format if needed (MM/DD/YYYY to YYYY-MM-DD)
                try:
                    date_obj = datetime.strptime(service_date, "%m/%d/%Y")
                    formatted_date = date_obj.strftime("%Y-%m-%d")
                except ValueError:
                    # Try other date formats
                    try:
                        date_obj = datetime.strptime(service_date, "%Y-%m-%d")
                        formatted_date = service_date
                    except ValueError:
                        logger.error(f"Invalid date format at row {row_num}: {service_date}")
                        errors += 1
                        errors_list.append({
                            "row": row_num,
                            "error": f"Invalid date format: {service_date}"
                        })
                        continue
                
                # Calculate minutes from times if not provided
                if minutes_str and minutes_str.isdigit():
                    minutes = int(minutes_str)
                else:
                    minutes = parse_time_to_minutes(start_time, end_time)
                
                # Find or create provider
                provider = find_or_create_provider(provider_name)
                if not provider:
                    logger.error(f"Could not create provider: {provider_name}")
                    flagged += 1
                    continue
                
                # Find or create client  
                client = find_or_create_client(client_name)
                if not client:
                    logger.error(f"Could not create client: {client_name}")
                    flagged += 1
                    continue
                
                # Handle insurance/payer - auto-create if possible
                payer_id = None
                if primary_insurance:
                    payer_id = find_or_create_payer(primary_insurance, billing_route)
                    
                    # If payer creation STILL failed (rare), flag it
                    if not payer_id:
                        logger.error(f"Failed to create payer at row {row_num}: {primary_insurance}")
                        flagged += 1
                        if len(flagged_preview) < 10:
                            flagged_preview.append({
                                "reason": "payer_creation_failed",
                                "client_name": client_name,
                                "provider_name": provider_name,
                                "service_date": formatted_date,
                                "insurance": primary_insurance,
                                "row": row_num
                            })
                        
                        # Store in staging for team review
                        if SB:
                            try:
                                SB.table("import_staging").insert({
                                    "run_id": run_id,
                                    "raw": row,
                                    "reason": f"payer_creation_failed: {primary_insurance}"
                                }).execute()
                            except Exception as e:
                                logger.error(f"Could not save to staging: {e}")
                        continue
                # If no insurance, leave payer_id as None (self-pay)
                
                # Determine note submission status
                note_submitted = status.lower() in ["completed", "submitted", "finalized", "complete"]
                
                # Prepare session data
                session_data = {
                    "provider_id": provider["id"],
                    "client_id": client["id"],
                    "session_date": formatted_date,
                    "start_time": start_time,
                    "end_time": end_time,
                    "minutes": minutes,
                    "note_submitted": note_submitted,
                    "billing_status": "completed" if note_submitted else "pending",
                    "client_type": client_type,
                    "primary_insurance": primary_insurance,
                    "billing_route": billing_route,
                    "external_source": "simplepractice",
                    "imported_at": datetime.now(timezone.utc).isoformat()
                }
                
                # Add payer ID if available
                if payer_id:
                    session_data["payer_id"] = payer_id
                
                # Check if session already exists
                existing = SB.table("sessions").select("id") \
                    .eq("provider_id", provider["id"]) \
                    .eq("client_id", client["id"]) \
                    .eq("session_date", formatted_date) \
                    .limit(1).execute()
                
                if existing.data:
                    # Update existing session
                    session_data["is_duplicate"] = True
                    result = SB.table("sessions").update(session_data).eq("id", existing.data[0]["id"]).execute()
                    updated += 1
                    logger.info(f"Updated existing session ID: {existing.data[0]['id']}")
                else:
                    # Insert new session
                    session_data["is_duplicate"] = False
                    result = SB.table("sessions").insert(session_data).execute()
                    inserted += 1
                    logger.info(f"Created new session for {client_name} on {formatted_date}")
                    
            except Exception as e:
                logger.error(f"Error processing row {row_num}: {str(e)}")
                errors += 1
                errors_list.append({
                    "row": row_num,
                    "error": str(e)
                })
        
        # Update import run with results
        SB.table("import_runs").update({
            "finished_at": datetime.now(timezone.utc).isoformat(),
            "total_rows": total,
            "inserted_rows": inserted,
            "updated_rows": updated,
            "flagged_rows": flagged,
            "errors": errors_list[:10]  # Limit to first 10 errors
        }).eq("id", run_id).execute()
        
        logger.info(f"Import complete: {inserted} inserted, {updated} updated, {flagged} flagged, {errors} errors")
        
        return ImportResult(
            success=True,
            run_id=run_id,
            total=total,
            inserted=inserted,
            updated=updated,
            flagged=flagged,
            duplicates=duplicates,
            errors=errors,
            flagged_preview=flagged_preview,
            errors_detail=errors_list[:10],
            message=f"Successfully imported {inserted} new sessions, updated {updated} existing sessions"
        )
        
    except Exception as e:
        logger.error(f"Fatal error during import: {str(e)}")
        
        # Update import run with error
        if 'run_id' in locals():
            SB.table("import_runs").update({
                "finished_at": datetime.now(timezone.utc).isoformat(),
                "errors": [{"error": str(e)}]
            }).eq("id", run_id).execute()
        
        return ImportResult(
            success=False,
            message=f"Import failed: {str(e)}",
            errors=1
        )

@app.get("/api/sessions")
async def get_sessions():
    """Get all sessions with client and provider names"""
    if not SB:
        logger.error("Database connection not available")
        raise HTTPException(status_code=500, detail="Database connection error")
    
    try:
        # Query sessions with joins to clients and providers
        result = SB.table("sessions").select(
            "id, session_date, client_id, provider_id, minutes, note_submitted, "
            "billing_status, amount_billed, amount_paid, date_submitted, date_paid, "
            "clients(name), providers(name)"
        ).order("session_date", desc=True).execute()
        
        logger.info(f"Found {len(result.data) if result.data else 0} sessions")
        return result.data if result.data else []
    except Exception as e:
        logger.error(f"Error fetching sessions: {e}")
        import traceback
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/user/profile")
async def get_user_profile(authorization: str = Header(None)):
    """Get user profile with role information"""
    if not SB:
        logger.error("Database connection not available")
        raise HTTPException(status_code=500, detail="Database connection error")
    
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    try:
        # Extract token
        token = authorization.replace("Bearer ", "")
        
        # Verify token with Supabase
        auth_response = SB.auth.get_user(token)
        if not auth_response or not auth_response.user:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        user = auth_response.user
        user_id = user.id
        email = user.email
        
        # Fetch user profile from profiles table
        profile_result = SB.table("profiles").select("role, full_name").eq("id", user_id).limit(1).execute()
        
        if profile_result.data and len(profile_result.data) > 0:
            profile = profile_result.data[0]
            return {
                "id": user_id,
                "email": email,
                "role": profile.get("role", "billing"),  # Default to billing if not set
                "name": profile.get("full_name", email.split("@")[0])
            }
        else:
            # No profile found, return default
            logger.warning(f"No profile found for user {user_id}, returning defaults")
            return {
                "id": user_id,
                "email": email,
                "role": "billing",  # Default role
                "name": email.split("@")[0] if email else "User"
            }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching user profile: {e}")
        import traceback
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/imports/history")
async def get_import_history():
    """Get recent import runs with statistics"""
    if not SB:
        logger.error("Database connection not available")
        raise HTTPException(status_code=500, detail="Database connection error")
    
    try:
        # Query import_runs table, get last 20 imports
        result = SB.table("import_runs").select(
            "id, source, file_name, started_at, finished_at, "
            "total_rows, inserted_rows, updated_rows, flagged_rows, errors"
        ).order("started_at", desc=True).limit(20).execute()
        
        logger.info(f"Found {len(result.data) if result.data else 0} import runs")
        return result.data if result.data else []
    except Exception as e:
        logger.error(f"Error fetching import history: {e}")
        import traceback
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/imports/test-connection")
async def test_database_connection():
    """Test database connection and return status"""
    if not SB:
        return {"success": False, "message": "Supabase client not initialized"}
    
    try:
        # Test connection by querying providers table
        result = SB.table("providers").select("count").limit(1).execute()
        
        # Test all required tables
        tables_status = {}
        for table in ["providers", "clients", "sessions", "payers", "import_runs"]:
            try:
                SB.table(table).select("count").limit(1).execute()
                tables_status[table] = "✅ Available"
            except Exception as e:
                tables_status[table] = f"❌ Error: {str(e)}"
        
        return {
            "success": True,
            "message": "Database connection successful",
            "tables": tables_status
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"Database connection failed: {str(e)}"
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
    