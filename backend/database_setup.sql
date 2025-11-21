-- Money Heist Database Setup for Supabase
-- Run this in your Supabase SQL Editor

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

-- 9. Create function to auto-create wallet on user signup (OPTIONAL - Commented out to prevent signup failures)
-- If you want automatic wallet creation, uncomment this section
-- However, it's recommended to let the backend API handle wallet creation

-- CREATE OR REPLACE FUNCTION handle_new_user()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   INSERT INTO wallet (user_id, balance)
--   VALUES (NEW.id, 0)
--   ON CONFLICT (user_id) DO NOTHING;
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW
--   EXECUTE FUNCTION handle_new_user();

-- Note: Wallet creation is now handled by the backend API on first login/wallet access
-- This prevents "Database error saving new user" issues

