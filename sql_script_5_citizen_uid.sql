-- SCRIPT 5: CITIZEN UID and AI RLS FIXES

-- 1. Add user_id column to citizens if it doesn't exist
-- This links Firebase UIDs to citizen profiles correctly.
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='citizens' AND column_name='user_id') THEN
        ALTER TABLE citizens ADD COLUMN user_id TEXT;
    END IF;
END $$;

-- 2. Create index for performance
CREATE INDEX IF NOT EXISTS idx_citizens_user_id ON citizens(user_id);

-- 3. Update RLS policies for Citizens table
-- Allow anyone authenticated (including police) to view citizen profiles
DROP POLICY IF EXISTS "Users can view own profile" ON citizens;
CREATE POLICY "Authenticated users can view citizen profiles"
ON citizens FOR SELECT
TO authenticated
USING (true);

-- Ensure users can only insert/update their own profile (linked by user_id or username)
DROP POLICY IF EXISTS "Users can insert own profile" ON citizens;
CREATE POLICY "Users can insert own profile"
ON citizens FOR INSERT
WITH CHECK (auth_uid_text() = user_id OR auth.uid()::text = username);

DROP POLICY IF EXISTS "Users can update own profile" ON citizens;
CREATE POLICY "Users can update own profile"
ON citizens FOR UPDATE
USING (auth_uid_text() = user_id OR auth.uid()::text = username);

-- 4. Update RLS policies for AI Chat History
-- Allow police (authenticated) to view all logs for the dashboard
DROP POLICY IF EXISTS "Users can view own chat history" ON ai_chat_history;
CREATE POLICY "Authenticated users can view all chat history"
ON ai_chat_history FOR SELECT
TO authenticated
USING (true);

-- Ensure users can still only insert their own messages
DROP POLICY IF EXISTS "Users can create own chat messages" ON ai_chat_history;
CREATE POLICY "Users can create own chat messages"
ON ai_chat_history FOR INSERT
WITH CHECK (auth_uid_text() = user_id OR user_id = auth.uid()::text);
