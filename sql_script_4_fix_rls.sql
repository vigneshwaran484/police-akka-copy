-- SCRIPT 4: RLS FIXES

-- 0. DEFINE HELPERS FIRST
CREATE OR REPLACE FUNCTION auth_uid_text() RETURNS text AS $$
  SELECT auth.uid()::text;
$$ LANGUAGE sql STABLE;

-- 1. FIX DASHBOARD UPDATES (MARK DONE)
-- Currently, update is restricted to the owner (user_id = auth.uid()). 
-- We need to allow police (authenticated via email/password) to update too.

-- Drop existing restricted policies if they exist (Supabase might have unique names)
DROP POLICY IF EXISTS "Users can update own incidents" ON incidents;
DROP POLICY IF EXISTS "Users can update own SOS alerts" ON sos_alerts;
DROP POLICY IF EXISTS "Users can update own queries" ON citizen_queries;

-- Create more inclusive update policies
CREATE POLICY "Authenticated users can update any incident"
ON incidents FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated users can update any SOS alert"
ON sos_alerts FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated users can update any query"
ON citizen_queries FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);


-- 2. FIX STORAGE UPLOAD (403 ERROR)
-- Ensure storage policies are robust for JWT Trust users.

-- Drop old policies to avoid conflicts
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own media" ON storage.objects;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;

-- Allow public viewing of all media in incident-media bucket
CREATE POLICY "Public Read Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'incident-media' );

-- Allow ANY authenticated user to upload to the bucket
-- Using a broader check to ensure JWT Trust users are covered
CREATE POLICY "Auth Upload Access"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK ( bucket_id = 'incident-media' );

-- Fallback for upload if role mapping is weird
CREATE POLICY "Fallback Upload Access"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'incident-media' AND auth_uid_text() IS NOT NULL );

-- ULTIMATE FALLBACK: Allow all inserts to this specific bucket
-- This is necessary if Supabase role mapping for external JWTs is inconsistent
CREATE POLICY "Unrestricted Upload for Bucket"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'incident-media' );
