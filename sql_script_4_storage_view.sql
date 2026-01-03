-- SCRIPT 4: STORAGE POLICY 2 (View)
CREATE POLICY "Anyone can view incident media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'incident-media');
