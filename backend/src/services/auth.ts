import { supabase } from './supabase';
import { createWallet } from './wallet';

export interface AuthResponse {
  data: {
    user: any;
    session: any;
  } | null;
  error: any;
}

export async function signUp(email: string, password: string): Promise<AuthResponse> {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        // Disable email confirmation for testing (enable in production)
        emailRedirectTo: undefined,
        // Don't auto-verify email
        data: {}
      }
    });

    // If there's an error, check if it's a database trigger issue
    if (error) {
      console.error('Supabase signup error:', error);
      // If it's a database error, provide more helpful message
      if (error.message?.includes('Database error') || error.message?.includes('trigger')) {
        return {
          data: null,
          error: {
            message: 'Database configuration issue. Please ensure database_setup_simple.sql has been run and triggers are removed.',
            originalError: error.message
          }
        };
      }
    }

    return { data, error };
  } catch (err: any) {
    console.error('Signup exception:', err);
    return {
      data: null,
      error: {
        message: err.message || 'Failed to create user account',
        originalError: err.toString()
      }
    };
  }
}

export async function login(email: string, password: string): Promise<AuthResponse> {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  return { data, error };
}

export async function getCurrentUser(token: string) {
  const { data, error } = await supabase.auth.getUser(token);
  if (error) {
    console.error('Get user error:', error.message);
    return null;
  }
  return data?.user;
}

