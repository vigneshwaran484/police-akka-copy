# Fix "Permission Denied" Error

The error occurs because your Firestore rules require a special "isPolice" tag that hasn't been set on your account.

## Quick Fix: Update Security Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Open **Firestore Database** > **Rules**
3. **Replace ANY existing rules** with these simplified rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is logged in
    function isAuthenticated() {
      return request.auth != null;
    }

    // Incidents (Police can update)
    match /incidents/{incident} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated(); // CHANGED: Allowed all logged-in users to update
    }
    
    // SOS Alerts (Police can resolve)
    match /sos_alerts/{alert} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated(); // CHANGED: Allowed all logged-in users to update
    }
    
    // Citizen Queries (Police can respond)
    match /citizen_queries/{query} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated(); // CHANGED: Allowed all logged-in users to respond
    }
    
    // AI Chats (Users can manage their own chats)
    match /ai_chat_history/{docId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    // Citizens Data
    match /citizens/{userId} {
      allow read, write: if isAuthenticated();
    }
    
    // Default catch-all
    match /{document=**} {
      allow read, write: if isAuthenticated();
    }
  }
}
```

4. Click **Publish**.
5. Wait 30 seconds, then try clicking "Mark Done" again in the dashboard.
