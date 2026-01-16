-- Storage Policies for incident-media bucket
DROP POLICY IF EXISTS "Public Select Access" ON storage.objects;
CREATE POLICY "Public Select Access" ON storage.objects FOR SELECT USING (bucket_id = 'incident-media');

DROP POLICY IF EXISTS "Authenticated Insert Access" ON storage.objects;
CREATE POLICY "Authenticated Insert Access" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'incident-media');

DROP POLICY IF EXISTS "Authenticated Update Access" ON storage.objects;
CREATE POLICY "Authenticated Update Access" ON storage.objects FOR UPDATE USING (bucket_id = 'incident-media');

-- Additional Permissive Policies for Anon (Hybrid Auth Support)
DROP POLICY IF EXISTS "Anon Insert Access" ON storage.objects;
CREATE POLICY "Anon Insert Access" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'incident-media');

DROP POLICY IF EXISTS "Anon Update Access" ON storage.objects;
CREATE POLICY "Anon Update Access" ON storage.objects FOR UPDATE USING (bucket_id = 'incident-media');
