-- COMPLETE DATABASE FIX FOR SIGNUP ISSUES
-- Run this ENTIRE script in Supabase SQL Editor to fix "Database error saving new user"

-- Step 1: Remove any problematic triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Step 2: Ensure wallet table exists (create if missing)
CREATE TABLE IF NOT EXISTS wallet (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  balance DECIMAL(10, 2) DEFAULT 0 NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 3: Ensure transactions table exists
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('debit', 'credit', 'investment')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 4: Create indexes
CREATE INDEX IF NOT EXISTS idx_wallet_user_id ON wallet(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);

-- Step 5: Enable RLS
ALTER TABLE wallet ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Step 6: Drop existing policies and recreate them
DROP POLICY IF EXISTS "Users can view own wallet" ON wallet;
DROP POLICY IF EXISTS "Users can insert own wallet" ON wallet;
DROP POLICY IF EXISTS "Users can update own wallet" ON wallet;
DROP POLICY IF EXISTS "Users can view own transactions" ON transactions;
DROP POLICY IF EXISTS "Users can insert own transactions" ON transactions;

-- Step 7: Create RLS Policies for wallet
CREATE POLICY "Users can view own wallet" ON wallet
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own wallet" ON wallet
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own wallet" ON wallet
  FOR UPDATE USING (auth.uid() = user_id);

-- Step 8: Create RLS Policies for transactions
CREATE POLICY "Users can view own transactions" ON transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions" ON transactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Step 9: Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 10: Create trigger to auto-update updated_at (only for wallet table)
DROP TRIGGER IF EXISTS update_wallet_updated_at ON wallet;
CREATE TRIGGER update_wallet_updated_at
  BEFORE UPDATE ON wallet
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Step 11: Verify no triggers exist on auth.users
SELECT 
    trigger_name, 
    event_manipulation, 
    event_object_table 
FROM information_schema.triggers 
WHERE event_object_table = 'users' 
AND trigger_schema = 'auth';

-- If the above query returns any rows, those triggers need to be removed manually
-- The wallet will be created by the backend API when needed, not by database triggers

