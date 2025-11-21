import { Router } from 'express';
import { z } from 'zod';
import { getTransactions, addTransaction, processPayment } from '../services/transactions';
import { supabase } from '../services/supabase';

const router = Router();

// Middleware to verify auth token
async function verifyAuth(req: any, res: any, next: any) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user) {
    return res.status(401).json({ error: 'Invalid token' });
  }

  req.userId = data.user.id;
  next();
}

const transactionSchema = z.object({
  amount: z.number().positive(),
  type: z.string(),
});

const paymentSchema = z.object({
  amount: z.number().positive(),
});

router.get('/', verifyAuth, async (req, res) => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    const transactions = await getTransactions(req.userId);
    res.json(transactions);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/', verifyAuth, async (req, res) => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    const validated = transactionSchema.parse(req.body);
    const transaction = await addTransaction(
      req.userId,
      validated.amount,
      validated.type
    );
    if (!transaction) {
      return res.status(500).json({ error: 'Failed to add transaction' });
    }
    res.json(transaction);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/process-payment', verifyAuth, async (req, res) => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    const validated = paymentSchema.parse(req.body);
    const result = await processPayment(req.userId, validated.amount);
    if (!result) {
      return res.status(400).json({ error: 'Payment failed' });
    }
    res.json(result);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }
    if (error instanceof Error) {
      return res.status(400).json({ error: error.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

export { router as transactionRouter };

