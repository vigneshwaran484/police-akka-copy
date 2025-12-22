# AI Chatbot Troubleshooting & Setup

## Issue: "Error loading AI chats" in Police Dashboard

### Root Cause
Your Firestore security rules don't allow access to the `ai_chats` collection yet.

### Fix (REQUIRED)

**Step 1: Update Firestore Rules**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to: **Firestore Database** → **Rules**
4. Click "Edit rules"
5. **Replace ALL the existing rules** with the updated rules from `FIREBASE_SETUP.md` (lines 118-157)
6. Click **"Publish"**

**Step 2: Test the AI Chatbot**

After updating the rules:
1. Hot restart the citizen app (`R` in terminal)
2. Open the app and click "ENTER YOUR QUERY HERE"
3. Send a test message like "How do I file a police report?"
4. Wait for AI response (should appear in 2-5 seconds)
5. Check police dashboard → "AI Chatbot Replies" to view the conversation

---

## Issue: AI Not Responding

### Possible Causes:

1. **Internet Connection**
   - Make sure emulator/device has internet access
   - Gemini API requires active internet

2. **API Key Issues**
   - Verify the API key is correct in `app_config.dart`
   - Make sure there are no extra spaces in the key

3. **Check Terminal for Errors**
   - Look for error messages like:
     - "Error getting AI response"
     - API key errors
     - Network errors

### Debug Steps:

1. **Check the terminal output** when you send a message
   - You should see debug logs from the AI service

2. **Test API Key Manually**
   - Go to [Google AI Studio](https://aistudio.google.com)
   - Try your API key there to confirm it works

3. **If still not working:**
   - Share the error message from the terminal
   - Check Firebase Console → Firestore →  Database
   - Verify `ai_chats` collection appears when you send a message

---

## Tamil Text "தமிழ்நாடு காவல்துறை"

This text is already correctly placed in:
- Police dashboard header
- AI chatbot screen header

If you see it displaying incorrectly, it might be a font issue. The text should render properly as Flutter supports Unicode Tamil characters.

---

## Police Logo Image

The current logo is using a generic police icon. To use a custom Tamil Nadu Police logo:

1. **Get the logo file** (PNG or JPG):
   - Download official TN Police logo
   - Save as `tn_police_logo.png`

2. **Place in assets**:
   ```
   police_app/assets/images/tn_police_logo.png
   police_dashboard/assets/images/tn_police_logo.png
   ```

3. **Update the code** - I can help you replace all Icon widgets with the image

Let me know if you want me to update the logo implementation!
