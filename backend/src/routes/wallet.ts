import { Router } from 'express';
import { z } from 'zod';
import { getWallet, addMoney, deductMoney, createWallet } from '../services/wallet';
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

const depositSchema = z.object({
  amount: z.number().positive(),
});

const withdrawSchema = z.object({
  amount: z.number().positive(),
});

router.get('/', verifyAuth, async (req, res) => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    let wallet = await getWallet(req.userId);
    
    // Auto-create wallet if it doesn't exist
    if (!wallet) {
      wallet = await createWallet(req.userId);
      if (!wallet) {
        return res.status(500).json({ error: 'Failed to create wallet' });
      }
    }
    
    res.json(wallet);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/deposit', verifyAuth, async (req, res) => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    const validated = depositSchema.parse(req.body);
    const wallet = await addMoney(req.userId, validated.amount);
    if (!wallet) {
      return res.status(500).json({ error: 'Failed to deposit' });
    }
    res.json(wallet);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/withdraw', verifyAuth, async (req, res) => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }
    const validated = withdrawSchema.parse(req.body);
    const wallet = await deductMoney(req.userId, validated.amount);
    if (!wallet) {
      return res.status(400).json({ error: 'Insufficient balance' });
    }
    res.json(wallet);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }
    if (error instanceof Error && error.message === 'Insufficient balance') {
      return res.status(400).json({ error: error.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

export { router as walletRouter };

