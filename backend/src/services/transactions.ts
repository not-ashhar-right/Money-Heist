import { supabase } from './supabase';
import { addMoney, deductMoney, calculateInvestment } from './wallet';

export interface Transaction {
  id: string;
  user_id: string;
  amount: number;
  type: string;
  created_at: string;
}

export async function addTransaction(
  user_id: string,
  amount: number,
  type: string
): Promise<Transaction | null> {
  const { data, error } = await supabase
    .from('transactions')
    .insert({
      user_id,
      amount,
      type,
    })
    .select()
    .single();

  if (error) {
    console.error('Error adding transaction:', error);
    return null;
  }

  return data;
}

export async function getTransactions(user_id: string): Promise<Transaction[]> {
  const { data, error } = await supabase
    .from('transactions')
    .select('*')
    .eq('user_id', user_id)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching transactions:', error);
    return [];
  }

  return data || [];
}

export async function processPayment(
  user_id: string,
  amount: number
): Promise<{ status: string; invested: number } | null> {
  // 1. Deduct from wallet
  const deducted = await deductMoney(user_id, amount);
  if (!deducted) {
    throw new Error('Payment failed (insufficient balance)');
  }

  // 2. Add transaction record
  await addTransaction(user_id, amount, 'debit');

  // 3. Calculate investment amount
  const investAmount = calculateInvestment(amount);

  // 4. Credit investment amount to wallet
  await addMoney(user_id, investAmount);

  // 5. Log investment transaction
  await addTransaction(user_id, investAmount, 'investment');

  return {
    status: 'success',
    invested: investAmount,
  };
}

