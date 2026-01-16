-- SCRIPT 3: STORAGE POLICY 1 (Upload)
CREATE POLICY "Authenticated users can upload incident media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'incident-media');
