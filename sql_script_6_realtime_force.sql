-- FORCE REALTIME AND RLS FOR AI CHAT & DASHBOARD

-- 1. Ensure the publication exists and is clean
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime;

-- 2. Add ALL tables to Realtime (This makes it work like Firebase)
ALTER PUBLICATION supabase_realtime ADD TABLE incidents;
ALTER PUBLICATION supabase_realtime ADD TABLE sos_alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE citizen_queries;
ALTER PUBLICATION supabase_realtime ADD TABLE ai_chat_history;
ALTER PUBLICATION supabase_realtime ADD TABLE citizens;

-- 3. Fix AI Chat RLS (Allow users to see their own history and Police to see all)
ALTER TABLE ai_chat_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own chat history" ON ai_chat_history;
CREATE POLICY "Users can view own chat history"
ON ai_chat_history FOR SELECT TO authenticated
USING (auth.uid()::text = user_id OR user_id = auth_uid_text());

DROP POLICY IF EXISTS "Public authenticated can view all" ON ai_chat_history;
CREATE POLICY "Public authenticated can view all"
ON ai_chat_history FOR SELECT TO authenticated
USING (true); -- Police (and anyone auth'd) can view logs on dashboard

DROP POLICY IF EXISTS "Users can insert own chat" ON ai_chat_history;
CREATE POLICY "Users can insert own chat"
ON ai_chat_history FOR INSERT TO authenticated
WITH CHECK (true); -- Allow insertion, we handle user_id in app

-- 4. Fix Citizen Profiles RLS
ALTER TABLE citizens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can view citizen profiles" ON citizens;
CREATE POLICY "Authenticated users can view citizen profiles"
ON citizens FOR SELECT TO authenticated
USING (true);

-- 5. Final check on Incidents/SOS (Enable Realtime requires Replica Identity)
ALTER TABLE incidents REPLICA IDENTITY FULL;
ALTER TABLE sos_alerts REPLICA IDENTITY FULL;
ALTER TABLE citizen_queries REPLICA IDENTITY FULL;
ALTER TABLE ai_chat_history REPLICA IDENTITY FULL;
