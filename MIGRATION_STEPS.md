# Supabase Migration - Manual Steps

## Important: Flutter Dependencies

Since Flutter is not in your PATH, you'll need to install the Supabase dependencies manually:

### For Citizen App:
1. Open a terminal in `I:\dart\police-akka-copy\police_app`
2. Run: `flutter pub get`

### For Police Dashboard:
1. Open a terminal in `I:\dart\police-akka-copy\police_dashboard`
2. Run: `flutter pub get`

## Screen Files to Update

I've created the Supabase service layers, but the screen files still import and use the old Firebase services. Here's what needs to be updated:

### Citizen App Screens

All these files need to:
1. Replace `import '../services/firebase_service.dart'` with `import '../services/supabase_service.dart'`
2. Replace `FirebaseService` with `SupabaseService`
3. Update stream handling from `QuerySnapshot` to `List<Map<String, dynamic>>`

**Files to update:**
- `lib/screens/login_screen.dart`
- `lib/screens/otp_screen.dart`
- `lib/screens/register_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/report_incident_screen.dart`
- `lib/screens/incident_history_screen.dart`
- `lib/screens/sos_history_screen.dart`
- `lib/screens/my_queries_screen.dart`
- `lib/screens/ai_chatbot_screen.dart`
- `lib/screens/citizen_chat_screen.dart`
- `lib/screens/edit_profile_screen.dart`

### Police Dashboard Screens

**Files to update:**
- `lib/screens/login_screen.dart`
- `lib/screens/dashboard_screen.dart`

## Next Steps

I can update these files automatically for you. Would you like me to proceed?

The changes will be:
1. Update all imports
2. Replace service calls
3. Update data type handling for streams
4. Remove Firebase-specific code

This is a safe operation - I'll update the code to use the Supabase service layer I've already created.
