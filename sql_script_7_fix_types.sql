-- SCRIPT 7: FIX COLUMN TYPES (WITH ROBUST POLICY CLEANUP)
-- This script uses an automated loop to drop ALL policies that block the type change.

-- 1. DROP ALL BLOCKING POLICIES AUTOMATICALLY
DO $$ 
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname, tablename 
        FROM pg_policies 
        WHERE schemaname = 'public' 
          AND tablename IN ('citizens', 'ai_chat_history', 'incidents', 'sos_alerts', 'citizen_queries')
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- 2. ALTER THE COLUMNS TO TEXT (Supports Firebase UIDs)
ALTER TABLE citizens ALTER COLUMN user_id TYPE TEXT USING user_id::text;
ALTER TABLE ai_chat_history ALTER COLUMN user_id TYPE TEXT USING user_id::text;
ALTER TABLE incidents ALTER COLUMN user_id TYPE TEXT USING user_id::text;
ALTER TABLE sos_alerts ALTER COLUMN user_id TYPE TEXT USING user_id::text;
ALTER TABLE citizen_queries ALTER COLUMN user_id TYPE TEXT USING user_id::text;

-- 3. RECREATE POLICIES

-- citizens
CREATE POLICY "Users can insert own profile" ON citizens FOR INSERT TO authenticated WITH CHECK (auth_uid_text() = user_id OR auth.uid()::text = username);
CREATE POLICY "Users can update own profile" ON citizens FOR UPDATE TO authenticated USING (auth_uid_text() = user_id OR auth.uid()::text = username);
CREATE POLICY "Authenticated users can view citizen profiles" ON citizens FOR SELECT TO authenticated USING (true);

-- ai_chat_history
CREATE POLICY "Users can view own chat history" ON ai_chat_history FOR SELECT TO authenticated USING (auth.uid()::text = user_id OR user_id = auth_uid_text());
CREATE POLICY "Public authenticated can view all" ON ai_chat_history FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert own chat" ON ai_chat_history FOR INSERT TO authenticated WITH CHECK (true);

-- updates (for dashboard & app)
CREATE POLICY "Authenticated users can update any incident" ON incidents FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can update any SOS alert" ON sos_alerts FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can update any query" ON citizen_queries FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- viewing (for app and dashboard)
CREATE POLICY "Authenticated select access" ON incidents FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated select access SOS" ON sos_alerts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated select access queries" ON citizen_queries FOR SELECT TO authenticated USING (true);


