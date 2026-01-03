# Supabase Setup Guide - Tamil Nadu Police App

This guide will walk you through setting up Supabase for the TN Police application.

## Step 1: Create Supabase Account

1. Go to [https://supabase.com](https://supabase.com)
2. Click **"Start your project"** or **"Sign In"**
3. Sign up using:
   - GitHub account (recommended)
   - Google account
   - Email/Password

## Step 2: Create New Project

1. After signing in, click **"New Project"**
2. Fill in the project details:
   - **Name**: `tn-police-app` (or any name you prefer)
   - **Database Password**: Create a strong password (SAVE THIS - you'll need it!)
   - **Region**: Choose closest to your location
     - For India: Select **"Mumbai (ap-south-1)"**
   - **Pricing Plan**: Select **"Free"** (includes 1GB storage!)
3. Click **"Create new project"**
4. Wait 2-3 minutes for the project to be provisioned

## Step 3: Get Your Project Credentials

Once your project is ready:

1. Go to **Project Settings** (gear icon in left sidebar)
2. Click on **"API"** section
3. You'll see:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **Project API keys**:
     - `anon` `public` key (safe to use in your app)
     - `service_role` key (keep this SECRET!)

**IMPORTANT**: Copy these values - you'll need them later!

```
Project URL: https://xxxxxxxxxxxxx.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eHh4eHh4eHh4eHh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2Nzg4ODg4ODgsImV4cCI6MTk5NDQ2NDg4OH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Step 4: Create Database Tables

1. In your Supabase dashboard, click on **"SQL Editor"** (in left sidebar)
2. Click **"New query"**
3. Copy and paste the following SQL script:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Citizens Table
CREATE TABLE citizens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    aadhar TEXT UNIQUE NOT NULL,
    photo TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Incidents Table
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    type TEXT NOT NULL,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    address TEXT NOT NULL,
    time TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved')),
    severity TEXT DEFAULT 'low' CHECK (severity IN ('low', 'medium', 'high')),
    images TEXT[] DEFAULT '{}',
    videos TEXT[] DEFAULT '{}',
    audios TEXT[] DEFAULT '{}',
    has_media BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SOS Alerts Table
CREATE TABLE sos_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    location TEXT NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'resolved')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- Citizen Queries Table
CREATE TABLE citizen_queries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    citizen TEXT NOT NULL,
    phone TEXT NOT NULL,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'responded')),
    response TEXT,
    date TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    responded_at TIMESTAMPTZ
);

-- AI Chat History Table
CREATE TABLE ai_chat_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    sender TEXT NOT NULL CHECK (sender IN ('user', 'ai')),
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_incidents_user_id ON incidents(user_id);
CREATE INDEX idx_incidents_status ON incidents(status);
CREATE INDEX idx_incidents_created_at ON incidents(created_at DESC);
CREATE INDEX idx_sos_alerts_user_id ON sos_alerts(user_id);
CREATE INDEX idx_sos_alerts_status ON sos_alerts(status);
CREATE INDEX idx_citizen_queries_user_id ON citizen_queries(user_id);
CREATE INDEX idx_citizen_queries_status ON citizen_queries(status);
CREATE INDEX idx_ai_chat_user_id ON ai_chat_history(user_id);
CREATE INDEX idx_ai_chat_created_at ON ai_chat_history(created_at DESC);

-- Create updated_at trigger for incidents
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_incidents_updated_at
    BEFORE UPDATE ON incidents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

4. Click **"Run"** (or press Ctrl+Enter)
5. You should see: **"Success. No rows returned"**

## Step 5: Enable Row Level Security (RLS)

Now we need to set up security policies so users can only access their own data.

1. In SQL Editor, create a **new query**
2. Copy and paste this SQL:

```sql
-- Enable RLS on all tables
ALTER TABLE citizens ENABLE ROW LEVEL SECURITY;
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE sos_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE citizen_queries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_history ENABLE ROW LEVEL SECURITY;

-- Citizens Policies
-- Users can read and update their own profile
CREATE POLICY "Users can view own profile"
    ON citizens FOR SELECT
    USING (auth.uid()::text = username OR auth.jwt()->>'phone' = phone);

CREATE POLICY "Users can insert own profile"
    ON citizens FOR INSERT
    WITH CHECK (auth.uid()::text = username);

CREATE POLICY "Users can update own profile"
    ON citizens FOR UPDATE
    USING (auth.uid()::text = username);

-- Incidents Policies
-- Anyone authenticated can read incidents
CREATE POLICY "Authenticated users can view incidents"
    ON incidents FOR SELECT
    USING (auth.role() = 'authenticated');

-- Users can create incidents
CREATE POLICY "Users can create incidents"
    ON incidents FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Users can update their own incidents
CREATE POLICY "Users can update own incidents"
    ON incidents FOR UPDATE
    USING (user_id = auth.uid()::text);

-- SOS Alerts Policies
CREATE POLICY "Authenticated users can view SOS alerts"
    ON sos_alerts FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can create SOS alerts"
    ON sos_alerts FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own SOS alerts"
    ON sos_alerts FOR UPDATE
    USING (user_id = auth.uid()::text);

-- Citizen Queries Policies
CREATE POLICY "Authenticated users can view queries"
    ON citizen_queries FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can create queries"
    ON citizen_queries FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own queries"
    ON citizen_queries FOR UPDATE
    USING (user_id = auth.uid()::text);

-- AI Chat History Policies
CREATE POLICY "Users can view own chat history"
    ON ai_chat_history FOR SELECT
    USING (user_id = auth.uid()::text);

CREATE POLICY "Users can create own chat messages"
    ON ai_chat_history FOR INSERT
    WITH CHECK (user_id = auth.uid()::text);
```

3. Click **"Run"**
4. You should see: **"Success. No rows returned"**

## Step 6: Configure Storage for Incident Media

1. Click on **"Storage"** in the left sidebar
2. Click **"Create a new bucket"**
3. Fill in:
   - **Name**: `incident-media`
   - **Public bucket**: Toggle **ON** (so police can view media)
4. Click **"Create bucket"**

### Set Storage Policies

1. Click on the `incident-media` bucket
2. Click on **"Policies"** tab
3. Click **"New Policy"**
4. Select **"For full customization"**
5. Add this policy for uploads:

```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload incident media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'incident-media');
```

6. Add another policy for reading:

```sql
-- Anyone can view incident media
CREATE POLICY "Anyone can view incident media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'incident-media');
```

## Step 7: Enable Phone Authentication

1. Click on **"Authentication"** in the left sidebar
2. Click on **"Providers"**
3. Find **"Phone"** and click to expand
4. Toggle **"Enable Phone provider"** to ON
5. You'll need to configure an SMS provider:
   - **Twilio** (recommended for production)
   - **MessageBird**
   - For development, Supabase provides test OTPs

**For Development/Testing:**
- Leave the default settings
- Supabase will show OTP codes in the console for testing

**For Production (Twilio Setup):**
1. Create account at [twilio.com](https://www.twilio.com)
2. Get your Account SID and Auth Token
3. Get a Twilio phone number
4. Enter these in Supabase Phone Auth settings

6. Click **"Save"**

## Step 8: Create Police Account

Police officers will use email/password authentication.

1. Go to **"Authentication"** → **"Users"**
2. Click **"Add user"** → **"Create new user"**
3. Fill in:
   - **Email**: `officer@tnpolice.gov.in`
   - **Password**: `Police@123` (or your preferred password)
   - **Auto Confirm User**: Toggle **ON**
4. Click **"Create user"**

## Step 9: Verify Setup

Let's verify everything is set up correctly:

1. Go to **"Table Editor"** in left sidebar
2. You should see all 5 tables:
   - ✅ citizens
   - ✅ incidents
   - ✅ sos_alerts
   - ✅ citizen_queries
   - ✅ ai_chat_history

3. Go to **"Storage"**
   - ✅ You should see `incident-media` bucket

4. Go to **"Authentication"** → **"Users"**
   - ✅ You should see the police officer account

## Step 10: Save Your Credentials

Create a file to save your credentials (DON'T commit this to Git!):

**Create**: `police_app/lib/config/supabase_config.dart`

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

**Replace**:
- `YOUR_PROJECT_URL_HERE` with your actual Project URL
- `YOUR_ANON_KEY_HERE` with your actual Anon key

## Next Steps

Once you've completed all these steps, you're ready for me to:
1. Update the Flutter app code to use Supabase
2. Test the integration
3. Remove Firebase dependencies

---

## Troubleshooting

### Can't see tables in Table Editor?
- Refresh the page
- Check SQL Editor for any error messages

### Phone auth not working?
- For testing, check the Supabase logs for OTP codes
- For production, verify Twilio credentials

### Storage upload fails?
- Check that bucket is public
- Verify storage policies are created

### RLS blocking queries?
- Check that policies are created correctly
- Verify user is authenticated

---

## Free Tier Limits

Your Supabase free tier includes:
- ✅ 500MB database space
- ✅ 1GB file storage
- ✅ 2GB bandwidth
- ✅ 50,000 monthly active users
- ✅ Unlimited API requests

This is more than enough for development and small-scale deployment!

---

## Need Help?

- Supabase Docs: [https://supabase.com/docs](https://supabase.com/docs)
- Supabase Discord: [https://discord.supabase.com](https://discord.supabase.com)
- Flutter Supabase Docs: [https://supabase.com/docs/guides/getting-started/tutorials/with-flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
