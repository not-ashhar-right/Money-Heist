import { Router } from 'express';
import { z } from 'zod';
import { signUp, login } from '../services/auth';
import { getWallet, createWallet } from '../services/wallet';

const router = Router();

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

router.post('/signup', async (req, res) => {
  try {
    const validated = signupSchema.parse(req.body);
    const result = await signUp(validated.email, validated.password);

    if (result.error) {
      console.error('Signup error details:', JSON.stringify(result.error, null, 2));
      
      // Provide more helpful error messages
      let errorMessage = result.error.message || 'Failed to create user';
      
      if (errorMessage.includes('Database error') || errorMessage.includes('trigger')) {
        errorMessage = 'Database setup issue. Please run remove_triggers.sql in Supabase SQL Editor, then try again.';
      } else if (errorMessage.includes('already registered')) {
        errorMessage = 'This email is already registered. Please login instead.';
      } else if (errorMessage.includes('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      }
      
      return res.status(400).json({ 
        error: errorMessage,
        details: process.env.NODE_ENV === 'development' ? result.error : undefined
      });
    }

    if (!result.data || !result.data.user) {
      return res.status(400).json({ 
        error: 'Failed to create user. Please check your Supabase configuration and ensure database tables are set up correctly.' 
      });
    }

    res.json({
      user: result.data.user,
      session: result.data.session || null,
    });
  } catch (error) {
    console.error('Signup exception:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const validated = loginSchema.parse(req.body);
    const result = await login(validated.email, validated.password);

    if (result.error) {
      console.error('Login error:', result.error);
      const errorMessage = result.error.message || 'Invalid credentials';
      return res.status(401).json({ error: errorMessage });
    }

    if (!result.data || !result.data.user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Ensure wallet exists for user (create if missing)
    if (result.data.user.id) {
      try {
        const wallet = await getWallet(result.data.user.id);
        if (!wallet) {
          await createWallet(result.data.user.id);
        }
      } catch (walletError) {
        console.error('Wallet check/creation failed (non-critical):', walletError);
      }
    }

    res.json({
      user: result.data.user,
      session: result.data.session || null,
    });
  } catch (error) {
    console.error('Login exception:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

export { router as authRouter };

