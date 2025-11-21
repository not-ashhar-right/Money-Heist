# 🔧 Fix "Database error saving new user" - Step by Step

## The Problem
Supabase is returning "Database error saving new user" which means there's a database trigger, constraint, or RLS policy blocking user creation.

## ✅ Solution (Do This Now!)

### Step 1: Remove Problematic Triggers

1. **Open Supabase Dashboard**
2. **Go to SQL Editor**
3. **Run this script** (copy from `backend/fix_database.sql`):

```sql
-- Remove any triggers on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Check if any triggers still exist
SELECT 
    trigger_name, 
    event_manipulation, 
    event_object_table 
FROM information_schema.triggers 
WHERE event_object_table = 'users' 
AND trigger_schema = 'auth';
```

**If the query returns ANY rows, those triggers need to be removed!**

### Step 2: Set Up Tables (If Not Done)

Run the complete `backend/fix_database.sql` script in Supabase SQL Editor.

### Step 3: Check Supabase Auth Settings

1. Go to **Authentication** → **Settings** in Supabase
2. Check **"Enable email confirmations"** - **DISABLE IT FOR TESTING**
3. Check **"Enable email change confirmations"** - **DISABLE IT FOR TESTING**

### Step 4: Restart Backend

```bash
cd backend
# Stop the current server (Ctrl+C)
npm run dev
```

### Step 5: Try Signup Again

The signup should now work!

## 🔍 Alternative: Check Supabase Logs

1. Go to **Supabase Dashboard** → **Logs** → **Postgres Logs**
2. Look for errors when you try to signup
3. The error message will tell you exactly what's wrong

## 🚨 If Still Not Working

### Option 1: Disable All Triggers Temporarily

```sql
-- In Supabase SQL Editor, run:
SELECT 
    'DROP TRIGGER IF EXISTS ' || trigger_name || ' ON ' || event_object_schema || '.' || event_object_table || ';' 
FROM information_schema.triggers 
WHERE event_object_table = 'users' 
AND trigger_schema = 'auth';
```

This will generate DROP statements for all triggers. Run them.

### Option 2: Check RLS Policies

```sql
-- Check if RLS is blocking
SELECT * FROM pg_policies WHERE tablename = 'users' AND schemaname = 'auth';
```

### Option 3: Test Direct Signup in Supabase

1. Go to **Authentication** → **Users** in Supabase
2. Click **"Add user"** manually
3. If this also fails, the issue is in Supabase configuration, not our code

## ✅ Verification

After running `fix_database.sql`, verify:

1. **No triggers on auth.users:**
```sql
SELECT trigger_name FROM information_schema.triggers 
WHERE event_object_table = 'users' AND trigger_schema = 'auth';
-- Should return 0 rows
```

2. **Tables exist:**
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('wallet', 'transactions');
-- Should return 2 rows
```

3. **Try signup again** - should work now!

---

**The key issue**: There's likely a trigger on `auth.users` that's trying to create a wallet and failing. Removing it will fix the signup.

