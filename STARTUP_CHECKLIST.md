# 🚀 FSC Portal - Startup Checklist

**Always run these commands to start your development session correctly!**

---

## 📍 **Project Location**

```
/Users/dymirtatem/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Projects/fsc-portal
```

---

## ⚡ **Quick Start Commands**

### **1. Navigate to Project**

```bash
cd "/Users/dymirtatem/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Projects/fsc-portal"
```

### **2. Start Backend Server**

```bash
cd backend
source venv/bin/activate
python main.py
```

**✅ Expected:** `Uvicorn running on http://0.0.0.0:8001`

### **3. Start Frontend Server** (New Terminal)

```bash
cd frontend
npm run dev
```

**✅ Expected:** `Local: http://localhost:5173/`

---

## 🔧 **Verification Steps**

### **Backend Health Check**

```bash
curl http://localhost:8001/api/imports/test-connection
```

**✅ Expected:** `{"success":true,"message":"Database connection successful"}`

### **Frontend Access**

- Open: http://localhost:5173/
- Should see login page

### **Production Access**

- Open: https://app.fscnj.com
- Should see production site

---

## 🚨 **Common Issues & Fixes**

### **Issue: "python command not found"**

**Fix:** Always use `source venv/bin/activate` first

### **Issue: "Cannot find module"**

**Fix:** Run `npm install` in frontend directory

### **Issue: "Port already in use"**

**Fix:** Kill existing processes:

```bash
# Kill backend
lsof -ti:8001 | xargs kill -9

# Kill frontend
lsof -ti:5173 | xargs kill -9
```

### **Issue: CSV upload stuck**

**Fix:** Check backend is running on port 8001

---

## 📱 **iCloud Drive Notes**

**✅ Pros:**

- Syncs across all devices
- Automatic backups
- Access from anywhere

**⚠️ Cons:**

- Can cause sync delays
- Path issues if not fully synced
- Performance slower than local

**💡 Recommendation:** Keep using iCloud Drive, but always verify files are synced before starting

---

## 🎯 **Daily Workflow**

1. **Open Terminal**
2. **Run Startup Commands** (above)
3. **Verify Both Servers Running**
4. **Open Browser to localhost:5173**
5. **Start Coding!**

---

## 📞 **Emergency Contacts**

- **GitHub:** https://github.com/dymir1990/fsc-portal
- **Production:** https://app.fscnj.com
- **Supabase:** https://supabase.com/dashboard

---

**💡 Pro Tip:** Bookmark this file and run these commands every time you start working!
