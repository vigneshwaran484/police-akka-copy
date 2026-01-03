-- SCRIPT 8: FIX LOGIN (ALLOW ANON AADHAR CHECK)
-- This script allows the app to check if an Aadhar exists before the user is logged in.

-- 1. DROP the restrictive policy
DROP POLICY IF EXISTS "Authenticated users can view citizen profiles" ON citizens;

-- 2. CREATE a more inclusive policy that allows 'anon' role (Login Screen)
DROP POLICY IF EXISTS "Allow Aadhar check for all" ON citizens;
CREATE POLICY "Allow profile check for login"
ON citizens FOR SELECT
TO anon, authenticated
USING (true);

-- 3. Verify ai_chat_history is also accessible to police (already in script 7, but double check)
-- This ensures the AI chat works on the dashboard.
DROP POLICY IF EXISTS "Public authenticated can view all" ON ai_chat_history;
CREATE POLICY "Public authenticated can view all"
ON ai_chat_history FOR SELECT
TO authenticated
USING (true);
