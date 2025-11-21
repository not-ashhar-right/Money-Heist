# 🚀 Money Heist - Complete Setup Instructions

## ⚠️ CRITICAL: Database Setup First!

**Before doing anything else, set up your Supabase database:**

1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Open `backend/database_setup_simple.sql` (RECOMMENDED - no triggers)
   - Or use `backend/database_setup.sql` if you want triggers (may cause signup issues)
4. Copy the entire contents
5. Paste and run in Supabase SQL Editor
6. Verify tables are created (check Table Editor)

**This is REQUIRED - the app won't work without it!**

**Important**: Use `database_setup_simple.sql` to avoid "Database error saving new user" issues!

## Step-by-Step Setup

### 1. Backend Setup

```bash
cd backend
npm install

# Create backend/.env file:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
PORT=5001

npm run dev
```

**Verify backend is running:**
- Open http://localhost:5001/health
- Should see: `{"status":"ok","timestamp":"..."}`

### 2. Frontend Setup

```bash
cd frontend
flutter pub get

# Create frontend/.env file:
API_BASE_URL=http://localhost:5001
# For Android emulator: http://10.0.2.2:5001
# For physical device: http://<your-computer-ip>:5001

flutter run
```

## ✅ Testing Checklist

- [ ] Database tables created (wallet, transactions)
- [ ] Backend .env file exists with Supabase credentials
- [ ] Frontend .env file exists with API_BASE_URL
- [ ] Backend server running (check /health endpoint)
- [ ] Flutter app launches without errors
- [ ] Can sign up new user
- [ ] Can login with created user
- [ ] Wallet balance displays correctly
- [ ] Can make payments

## 🐛 Common Issues

**"Database error saving new user"**
→ Run `backend/database_setup.sql` in Supabase

**"Connection refused"**
→ Check backend is running
→ Verify API_BASE_URL is correct

**"Invalid credentials"**
→ Check email format
→ Password must be 6+ characters

## 📞 Need Help?

1. Check backend terminal for errors
2. Check Flutter console for debug messages
3. Verify all .env files exist
4. Test backend API directly with curl

---

**The app is ready to use once database is set up!**

