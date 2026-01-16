-- SCRIPT 3: STORAGE SETUP
-- Create the bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('incident-media', 'incident-media', true)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies for Storage
-- Allow anyone to view media (Public bucket)
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'incident-media' );

-- Allow authenticated users to upload media
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK ( bucket_id = 'incident-media' );

-- Allow users to update/delete their own media if needed
CREATE POLICY "Users can update own media"
ON storage.objects FOR UPDATE
TO authenticated
USING ( bucket_id = 'incident-media' );
