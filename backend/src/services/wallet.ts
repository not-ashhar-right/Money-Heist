import { supabase } from './supabase';

export interface Wallet {
  id: string;
  user_id: string;
  balance: number;
  created_at: string;
  updated_at: string;
}

export async function getWallet(user_id: string): Promise<Wallet | null> {
  const { data, error } = await supabase
    .from('wallet')
    .select('*')
    .eq('user_id', user_id)
    .single();

  if (error) {
    console.error('Error fetching wallet:', error);
    return null;
  }

  return data;
}

export async function createWallet(user_id: string): Promise<Wallet | null> {
  try {
    // First check if wallet already exists
    const existing = await getWallet(user_id);
    if (existing) {
      return existing;
    }

    const { data, error } = await supabase
      .from('wallet')
      .insert({
        user_id,
        balance: 0,
      })
      .select()
      .single();

    if (error) {
      // If it's a unique constraint error, wallet might have been created by another process
      if (error.code === '23505') {
        return await getWallet(user_id);
      }
      console.error('Error creating wallet:', error);
      return null;
    }

    return data;
  } catch (err) {
    console.error('Exception creating wallet:', err);
    return null;
  }
}

export async function addMoney(user_id: string, amount: number): Promise<Wallet | null> {
  const wallet = await getWallet(user_id);
  if (!wallet) return null;

  const newBalance = wallet.balance + amount;

  const { data, error } = await supabase
    .from('wallet')
    .update({ balance: newBalance })
    .eq('user_id', user_id)
    .select()
    .single();

  if (error) {
    console.error('Error adding money:', error);
    return null;
  }

  return data;
}

export async function deductMoney(user_id: string, amount: number): Promise<Wallet | null> {
  const wallet = await getWallet(user_id);
  if (!wallet) return null;

  if (wallet.balance < amount) {
    throw new Error('Insufficient balance');
  }

  const newBalance = wallet.balance - amount;

  const { data, error } = await supabase
    .from('wallet')
    .update({ balance: newBalance })
    .eq('user_id', user_id)
    .select()
    .single();

  if (error) {
    console.error('Error deducting money:', error);
    return null;
  }

  return data;
}

export function calculateInvestment(amount: number): number {
  let invest = 0;

  // First ₹100 → 2% per ₹10 = 0.2% per ₹1
  const first100 = Math.min(amount, 100);
  invest += first100 * 0.002; // 0.2%

  // Above ₹100 → 1%
  if (amount > 100) {
    invest += (amount - 100) * 0.01;
  }

  // Cap at 10%
  const maxCap = amount * 0.10;
  if (invest > maxCap) {
    invest = maxCap;
  }

  return Number(invest.toFixed(2));
}

