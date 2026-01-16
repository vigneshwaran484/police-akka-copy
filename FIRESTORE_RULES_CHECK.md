# Quick Firestore Rules Check

## CRITICAL: Did you update your Firestore security rules?

**You MUST do this for AI to work!**

### Step-by-Step:

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Click on your project
3. Go to **Firestore Database** (left sidebar)
4. Click **Rules** tab (at the top)
5. You should see something like this:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 1, 15);
    }
  }
}
```

6. **Replace it with the rules from FIREBASE_SETUP.md** (lines 118-157)
7. Click **"Publish"** button (top right)
8. You should see "Rules published successfully"

### How to test if it worked:

1. After publishing rules, **hot restart the citizen app** (press `R` in terminal)
2. Open AI chatbot
3. Send message: "test"
4. **Check the terminal for debug messages** starting with 🤖 [AI DEBUG]
5. You should see:
   - "Starting sendMessage..."
   - "Initializing Gemini..."  
   - "Sending request to Gemini API..."
   - "Received response from Gemini"

### If you see errors:

Share the error message from the terminal that starts with ❌ [AI ERROR]

---

## For the Image Error:

The dashboard needs to be restarted:
1. Stop the dashboard (if running)
2. Run: `flutter run -d chrome`
3. The logo should load now

The citizen app logo was already working, right?
