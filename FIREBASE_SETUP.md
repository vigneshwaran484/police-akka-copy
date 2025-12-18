# Firebase Setup Instructions

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Name it: **TN Police App**
4. Disable Google Analytics (optional)
5. Click "Create Project"

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Phone** authentication (for Citizen App)
3. Enable **Email/Password** authentication (for Police Dashboard)

## Step 3: Create Firestore Database

1. Go to **Firestore Database** → **Create Database**
2. Start in **Test mode** (we'll add security rules later)
3. Choose location closest to you (e.g., asia-south1 for India)

## Step 4: Add Android App (Citizen App)

1. In Firebase Console, click **Add App** → **Android**
2. Android package name: `com.example.police_app`
3. Download `google-services.json`
4. Place it in: `police_app/android/app/google-services.json`

## Step 5: Add Web App (Police Dashboard)

1. In Firebase Console, click **Add App** → **Web**
2. App nickname: **Police Dashboard**
3. Copy the Firebase configuration
4. I'll create a config file for you

## Step 6: Install Dependencies

Run these commands:

```bash
# Citizen App
cd police_app
flutter pub get

# Police Dashboard
cd ../police_dashboard
flutter pub get
```

## Step 7: Create Test Police Account

In Firebase Console → Authentication → Users:
1. Click "Add User"
2. Email: `officer@tnpolice.gov.in`
3. Password: `Police@123`

## Firestore Database Structure

The app will create these collections automatically:

### citizens
```json
{
  "userId": "string",
  "name": "string",
  "phone": "string",
  "aadhar": "string",
  "createdAt": "timestamp"
}
```

### incidents
```json
{
  "userId": "string",
  "type": "string",
  "description": "string",
  "location": "string",
  "status": "pending|investigating|resolved",
  "severity": "low|medium|high",
  "timestamp": "timestamp"
}
```

### sos_alerts
```json
{
  "userId": "string",
  "location": "string",
  "status": "active|resolved",
  "timestamp": "timestamp"
}
```

### citizen_queries
```json
{
  "userId": "string",
  "type": "Review|Change Request|Feedback",
  "message": "string",
  "status": "pending|resolved",
  "response": "string",
  "timestamp": "timestamp"
}
```

## Security Rules (Add Later)

After testing, update Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Citizens can read/write their own data
    match /citizens/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Citizens can create incidents
    match /incidents/{incident} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.token.isPolice == true;
    }
    
    // Only police can read queries
    match /citizen_queries/{query} {
      allow read: if request.auth.token.isPolice == true;
      allow create: if request.auth != null;
    }
    
    // Police can access everything
    match /{document=**} {
      allow read, write: if request.auth.token.isPolice == true;
    }
  }
}
```

## Next Steps

1. Complete Firebase Console setup
2. Download google-services.json
3. Run `flutterfire configure` (optional, for easier setup)
4. Test citizen registration
5. Test police login

## Testing

### Citizen App
- Register with phone number (use real phone for SMS OTP)
- Report incident
- Send SOS
- Submit query

### Police Dashboard
- Login with officer@tnpolice.gov.in
- View real-time incidents
- Update incident status
- Respond to queries

All data will sync in real-time between app and dashboard!

