import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile'; // Groq Llama 3 Model
  static const String _systemPrompt = 
    'You are a helpful Virtual Police Guide for Tamil Nadu Police. '
    'Assist citizens with information about police services, filing reports, '
    'legal procedures, safety tips, and guidance. Be professional, concise, and helpful. '
    'When users ask about how to use the app, explain clearly using steps, reference feature names, and keep answers short.';

  // Send a message to Groq AI
  static Future<String> sendMessage(
    String userMessage,
    List<Map<String, dynamic>> history,
  ) async {
    try {
      if (AppConfig.groqApiKey.isEmpty) {
        return 'Please configure the Groq API Key in app_config.dart';
      }

      // Local handling for app usage/tutor questions
      if (_isAppHelpQuery(userMessage)) {
        return _buildAppHelpResponse(userMessage);
      }

      // Prepare messages for Groq API (OpenAI format)
      final List<Map<String, dynamic>> messages = [];

      // Add System Prompt
      messages.add({
        'role': 'system',
        'content': '$_systemPrompt\n\nApp Guide:\n${AppConfig.appUsageGuide}'
      });

      // Add History
      for (var msg in history) {
        messages.add({
          'role': msg['sender'] == 'user' ? 'user' : 'assistant',
          'content': msg['message'] ?? ''
        });
      }

      // Add Current User Message
      messages.add({
        'role': 'user',
        'content': userMessage
      });

      print('🤖 [AI DEBUG] Sending request to Groq...');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]['message']?['content'] ?? 'No response received.';
        print('🤖 [AI DEBUG] Received response: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
        return content;
      } else {
        print('❌ [AI ERROR] API Error: ${response.statusCode} - ${response.body}');
        return 'I apologize, but I am having trouble connecting to the AI server. Please try again later.';
      }
    } catch (e) {
      print('❌ [AI ERROR] Exception: $e');
      return 'I apologize, but an unexpected error occurred. Please check your internet connection.';
    }
  }

  static Future<void> _debugListModels() async {
    // Not implemented for Groq yet
  }

  static bool _isAppHelpQuery(String text) {
    final t = text.toLowerCase();
    final keywords = [
      'how to use',
      'using this app',
      'use this app',
      'how do i use',
      'help with app',
      'guide',
      'tutorial',
      'how to report',
      'how to send sos',
      'how to ask',
      'how to file',
      'how to update profile',
      'app features',
    ];
    return keywords.any((k) => t.contains(k));
  }

  static String _buildAppHelpResponse(String userMessage) {
    // Tailor response based on intent
    final t = userMessage.toLowerCase();
    if (t.contains('report')) {
      return 'To report an incident:\n1) Home → Report Incident\n2) Pick type and describe details\n3) Add location and media\n4) Submit to notify police';
    }
    if (t.contains('sos')) {
      return 'To send SOS:\n1) Open Home → SOS\n2) Tap SOS to alert nearest station\n3) Your location is shared automatically';
    }
    if (t.contains('profile')) {
      return 'To update profile:\n1) Home → Profile\n2) Edit name, phone, Aadhaar\n3) Save changes';
    }
    if (t.contains('rules') || t.contains('traffic')) {
      return 'To read rules:\n1) Home → Guidance & Rules\n2) Browse traffic rules, penalties, and safety tips';
    }
    if (t.contains('query') || t.contains('ask')) {
      return 'To ask a question:\n1) Home → My Queries or use the Chatbot\n2) Type your doubt and send\n3) Police will review and respond';
    }
    // General app usage response
    return AppConfig.appUsageGuide.trim();
  }
}
