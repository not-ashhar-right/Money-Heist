-- Money Heist Database Setup for Supabase (Simplified - No Triggers)
-- Run this in your Supabase SQL Editor if the trigger version causes issues

-- 1. Create wallet table
CREATE TABLE IF NOT EXISTS wallet (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  balance DECIMAL(10, 2) DEFAULT 0 NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create transactions table
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('debit', 'credit', 'investment')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_wallet_user_id ON wallet(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);

-- 4. Enable Row Level Security
ALTER TABLE wallet ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS Policies for wallet
DROP POLICY IF EXISTS "Users can view own wallet" ON wallet;
CREATE POLICY "Users can view own wallet" ON wallet
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own wallet" ON wallet;
CREATE POLICY "Users can insert own wallet" ON wallet
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own wallet" ON wallet;
CREATE POLICY "Users can update own wallet" ON wallet
  FOR UPDATE USING (auth.uid() = user_id);

-- 6. Create RLS Policies for transactions
DROP POLICY IF EXISTS "Users can view own transactions" ON transactions;
CREATE POLICY "Users can view own transactions" ON transactions
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own transactions" ON transactions;
CREATE POLICY "Users can insert own transactions" ON transactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 7. Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_wallet_updated_at ON wallet;
CREATE TRIGGER update_wallet_updated_at
  BEFORE UPDATE ON wallet
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Note: Wallet creation is handled by the backend API, not by database triggers
-- This prevents signup failures due to database trigger issues

