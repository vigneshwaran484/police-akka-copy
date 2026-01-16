-- Citizens Table - Ultimate Permissive RLS for Hybrid Auth (Firebase + Supabase)
-- This allows both 'anon' and 'authenticated' roles to manage citizen profiles.

-- 1. Drop existing policies to start clean
DROP POLICY IF EXISTS "Allow select for all" ON citizens;
DROP POLICY IF EXISTS "Allow insert for all" ON citizens;
DROP POLICY IF EXISTS "Allow update for all" ON citizens;
DROP POLICY IF EXISTS "Citizen Select Policy" ON citizens;
DROP POLICY IF EXISTS "Citizen Insert Policy" ON citizens;
DROP POLICY IF EXISTS "Citizen Update Policy" ON citizens;

-- 2. Create wide-open policies (Required for Firebase-only JWT secrets)
CREATE POLICY "Allow select for all" ON citizens FOR SELECT USING (true);
CREATE POLICY "Allow insert for all" ON citizens FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update for all" ON citizens FOR UPDATE USING (true);

-- 3. Ensure the table has RLS enabled
ALTER TABLE citizens ENABLE ROW LEVEL SECURITY;

-- 4. Set permissions for anon and authenticated
GRANT ALL ON citizens TO anon, authenticated, postgres;
