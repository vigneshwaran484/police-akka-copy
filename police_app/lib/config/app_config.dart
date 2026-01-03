class AppConfig {
  // Gemini AI API Key (Legacy)
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  // Groq API Key
  static const String groqApiKey = 'YOUR_GROQ_API_KEY';
  
  // App Configuration
  static const String appName = 'Police Akka';
  static const String virtualGuideTitle = 'Virtual Police Guide';

  // App Usage Guide (used by AI to tutor users about the app)
  static const String appUsageGuide = '''
Welcome to Police Akka, your Virtual Police Guide.

Key features:
- Report Incident: File complaints with details, photos, videos, or audio.
- SOS: Send emergency alert with location to nearest police station.
- Guidance & Rules: Read common laws, traffic rules, and safety tips.
- My Queries: Send non-urgent questions and view responses.
- Profile: Manage your name, phone, and Aadhaar.
- Chatbot: Ask for help and get guidance instantly.

How to use:
1) Report an Incident
   - Open Home → Report Incident
   - Select type, describe what happened, add location and media
   - Submit to notify police
2) Send SOS (Emergency)
   - Tap SOS on Home when you need immediate help
   - Your location is shared with police
3) Ask a Question
   - Open My Queries or use Chatbot
   - Type your message; police can review and respond
4) See Rules
   - Open Guidance to learn traffic rules, penalties, and safety tips
5) Update Profile
   - Open Profile to edit your details

Tips:
- Use SOS only for urgent emergencies; use Report Incident for formal complaints.
- Add clear descriptions and evidence for faster action.
- Keep your phone number up to date in Profile.
''';
}
