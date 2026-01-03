-- AI Chat History
DROP POLICY IF EXISTS "Allow select for all" ON ai_chat_history;
CREATE POLICY "Allow select for all" ON ai_chat_history FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow insert for all" ON ai_chat_history;
CREATE POLICY "Allow insert for all" ON ai_chat_history FOR INSERT WITH CHECK (true);

-- Incidents
DROP POLICY IF EXISTS "Allow select for all" ON incidents;
CREATE POLICY "Allow select for all" ON incidents FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow insert for all" ON incidents;
CREATE POLICY "Allow insert for all" ON incidents FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow update for all" ON incidents;
CREATE POLICY "Allow update for all" ON incidents FOR UPDATE USING (true);

-- SOS Alerts
DROP POLICY IF EXISTS "Allow select for all" ON sos_alerts;
CREATE POLICY "Allow select for all" ON sos_alerts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow insert for all" ON sos_alerts;
CREATE POLICY "Allow insert for all" ON sos_alerts FOR INSERT WITH CHECK (true);

-- Citizen Queries
DROP POLICY IF EXISTS "Allow select for all" ON citizen_queries;
CREATE POLICY "Allow select for all" ON citizen_queries FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow insert for all" ON citizen_queries;
CREATE POLICY "Allow insert for all" ON citizen_queries FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow update for all" ON citizen_queries;
CREATE POLICY "Allow update for all" ON citizen_queries FOR UPDATE USING (true);
