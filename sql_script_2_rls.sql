-- SCRIPT 2: ROW LEVEL SECURITY
ALTER TABLE citizens ENABLE ROW LEVEL SECURITY;
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE sos_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE citizen_queries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON citizens FOR SELECT
    USING (auth.uid()::text = username OR auth.jwt()->>'phone' = phone);

CREATE POLICY "Users can insert own profile"
    ON citizens FOR INSERT
    WITH CHECK (auth.uid()::text = username);

CREATE POLICY "Users can update own profile"
    ON citizens FOR UPDATE
    USING (auth.uid()::text = username);

CREATE POLICY "Authenticated users can view incidents"
    ON incidents FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can create incidents"
    ON incidents FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own incidents"
    ON incidents FOR UPDATE
    USING (user_id = auth.uid()::text);

CREATE POLICY "Authenticated users can view SOS alerts"
    ON sos_alerts FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can create SOS alerts"
    ON sos_alerts FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own SOS alerts"
    ON sos_alerts FOR UPDATE
    USING (user_id = auth.uid()::text);

CREATE POLICY "Authenticated users can view queries"
    ON citizen_queries FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can create queries"
    ON citizen_queries FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own queries"
    ON citizen_queries FOR UPDATE
    USING (user_id = auth.uid()::text);

CREATE POLICY "Users can view own chat history"
    ON ai_chat_history FOR SELECT
    USING (user_id = auth.uid()::text);

CREATE POLICY "Users can create own chat messages"
    ON ai_chat_history FOR INSERT
    WITH CHECK (user_id = auth.uid()::text);
