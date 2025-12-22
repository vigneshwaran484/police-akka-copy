import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant'; // Fast and efficient model

  static const String _systemPrompt = 
    'You are a helpful Virtual Police Guide for Tamil Nadu Police. '
    'Assist citizens with information about police services, filing reports, '
    'legal procedures, safety tips, and guidance. Be professional, concise, and helpful.';

  // Send a message to Groq AI
  static Future<String> sendMessage(
    String userMessage,
    List<Map<String, dynamic>> history,
  ) async {
    try {
      if (AppConfig.groqApiKey.isEmpty) {
        return 'Please configure the Groq API Key in app_config.dart';
      }

      // Prepare messages list with system prompt first
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
      ];

      // Add history
      for (var msg in history) {
        messages.add({
          'role': msg['sender'] == 'user' ? 'user' : 'assistant',
          'content': msg['message'] ?? '',
        });
      }

      // Add current message
      messages.add({'role': 'user', 'content': userMessage});

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
        final content = data['choices'][0]['message']['content'];
        print('🤖 [AI DEBUG] Received response: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
        return content;
      } else {
        print('❌ [AI ERROR] API Error: ${response.statusCode} - ${response.body}');
        return 'I apologize, but I am having trouble connecting to the server. Please try again later.';
      }
    } catch (e) {
      print('❌ [AI ERROR] Exception: $e');
      return 'I apologize, but an unexpected error occurred. Please check your internet connection.';
    }
  }
}
