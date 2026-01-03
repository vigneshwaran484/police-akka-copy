# Supabase SQL Scripts - Copy & Paste Guide

> **IMPORTANT:** When copying SQL code below, do NOT copy the ```sql and ``` lines - those are just markdown formatting. Only copy the actual SQL code between them!

## Step 1: Create Database Tables

**Where:** Supabase Dashboard → SQL Editor → New Query

**What to copy:** Everything AFTER the line that says ```sql and BEFORE the line that says ```

**Copy this SQL code (without the ```sql and ``` markers):**

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

**Expected Result:** "Success. No rows returned"

---

## Step 2: Enable Row Level Security (RLS)

**Where:** SQL Editor → New Query

**Copy this entire script and paste it, then click "Run":**

```sql
-- Enable RLS on all tables
ALTER TABLE citizens ENABLE ROW LEVEL SECURITY;
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE sos_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE citizen_queries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_history ENABLE ROW LEVEL SECURITY;

-- Citizens Policies
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
CREATE POLICY "Authenticated users can view incidents"
    ON incidents FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can create incidents"
    ON incidents FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

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

**Expected Result:** "Success. No rows returned"

---

## Step 3: Set Up Storage Policies

**Where:** Storage → incident-media bucket → Policies → New Policy → For full customization

**Policy 1 - Allow Uploads:**
```sql
CREATE POLICY "Authenticated users can upload incident media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'incident-media');
```

**Policy 2 - Allow Public Viewing:**
```sql
CREATE POLICY "Anyone can view incident media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'incident-media');
```

---

## Verification

After running all scripts, verify in Supabase:

1. **Table Editor** → You should see 5 tables:
   - ✅ citizens
   - ✅ incidents
   - ✅ sos_alerts
   - ✅ citizen_queries
   - ✅ ai_chat_history

2. **Storage** → You should see:
   - ✅ incident-media bucket (public)

3. **Authentication** → Providers:
   - ✅ Phone auth enabled

---

## That's It!

Once you've run these 3 SQL scripts, your Supabase database is ready! 

The Flutter app code is already updated to use Supabase - I'm finishing that now.
