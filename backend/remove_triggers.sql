-- Remove any problematic triggers that might be causing signup failures
-- Run this in Supabase SQL Editor if you're getting "Database error saving new user"

-- Remove the trigger that auto-creates wallet (if it exists)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Remove the function (optional - only if you want to clean up)
-- DROP FUNCTION IF EXISTS handle_new_user();

-- Verify triggers are removed
SELECT 
    trigger_name, 
    event_manipulation, 
    event_object_table 
FROM information_schema.triggers 
WHERE event_object_table = 'users' 
AND trigger_schema = 'auth';

