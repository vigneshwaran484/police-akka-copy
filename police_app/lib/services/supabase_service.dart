import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';

import 'package:firebase_auth/firebase_auth.dart' as fa;

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Authentication

  /// Verify phone number and send OTP (Firebase Auth)
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      // Ensure phone number has country code
      String formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+91$phoneNumber';
      
      await fa.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (fa.PhoneAuthCredential credential) async {
          // Auto-resolution (Android only usually)
          // We can handle this, but for consistency we might just let the user enter OTP
          // Or we can auto-sign in here and notify UI? 
          // For now let's just log it. The UI expects manual OTP entry flow.
          print('Auto verification completed');
        },
        verificationFailed: (fa.FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Sign in with phone and OTP code (Hybrid: Firebase Auth)
  /// The Supabase client in main.dart will automatically use the Firebase token via the accessToken callback.
  static Future<fa.User?> signInWithPhone(String phoneNumber, String otpCode, {String? verificationId}) async {
    try {
      // 1. Sign in with Firebase
      fa.PhoneAuthCredential credential = fa.PhoneAuthProvider.credential(
        verificationId: verificationId ?? '',
        smsCode: otpCode,
      );

      final firebaseUserCredential = await fa.FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = firebaseUserCredential.user;
      
      if (firebaseUser == null) throw 'Firebase sign in failed';

      print('FIREBASE_AUTH: Signed in to Firebase. User: ${firebaseUser.uid}');
      
      // We don't need to manually exchange tokens anymore.
      // The accessToken callback in main.dart handles this automatically.
      
      return firebaseUser;
    } catch (e) {
      print('CRITICAL_LOGIN_ERROR: $e');
      rethrow; 
    }
  }

  // Get User by ID (Firebase UID)
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('citizens')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error fetching user by id: $e');
      return null;
    }
  }

  // Check if username exists
  static Future<bool> checkUsernameExists(String username) async {
    try {
      final response = await _client
          .from('citizens')
          .select('username')
          .eq('username', username)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Get User by Aadhar
  static Future<Map<String, dynamic>?> getUserByAadhar(String aadhar) async {
    try {
      final response = await _client
          .from('citizens')
          .select()
          .eq('aadhar', aadhar)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error fetching user by aadhar: $e');
      return null;
    }
  }

  // Get User by Phone
  static Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      // Try with the phone as provided
      var response = await _client
          .from('citizens')
          .select()
          .eq('phone', phone)
          .maybeSingle();
      
      if (response != null) return response;
      
      // Try with/without +91 just in case
      String altPhone = phone.startsWith('+91') 
          ? phone.substring(3) 
          : '+91$phone';
      
      response = await _client
          .from('citizens')
          .select()
          .eq('phone', altPhone)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error fetching user by phone: $e');
      return null;
    }
  }

  // Create/Update Citizen Profile
  static Future<void> saveCitizenProfile({
    required String userId,
    required String username,
    required String name,
    required String phone,
    required String aadhar,
    String? photo,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'username': username,
        'name': name,
        'phone': phone,
        'aadhar': aadhar,
        if (photo != null) 'photo': photo,
      };

      print('💾 [Supabase DEBUG] Saving profile for userId: $userId');
      print('Data: $data');

      // Try to update first by userId
      final response = await _client
          .from('citizens')
          .update(data)
          .eq('user_id', userId)
          .select();

      if (response.isNotEmpty) {
        print('✅ [Supabase] Profile updated successfully via user_id');
      } else {
        print('⚠️ [Supabase] No record found for user_id: $userId. Trying username: $username');
        // Fallback check by username
        final responseByUsername = await _client
            .from('citizens')
            .update(data)
            .eq('username', username)
            .select();
            
        if (responseByUsername.isNotEmpty) {
          print('✅ [Supabase] Profile updated successfully via username');
        } else {
          print('🆕 [Supabase] No record found by user_id or username. Inserting new record.');
          await _client.from('citizens').insert(data);
        }
      }
    } catch (e) {
      print('Error saving citizen profile: $e');
      rethrow;
    }
  }

  // Report Incident
  static Future<String> reportIncident({
    required String userId,
    required String userName,
    required String type,
    required String description,
    required String location,
  }) async {
    try {
      final now = DateTime.now().toString().substring(0, 16);
      
      final authId = fa.FirebaseAuth.instance.currentUser?.uid ?? userId;
      final response = await _client.from('incidents').insert({
        'user_id': authId,
        'user_name': userName,
        'type': type,
        'description': description,
        'location': location,
        'address': location,
        'time': now,
        'status': 'pending',
        'severity': _getSeverity(type),
        'images': [],
        'videos': [],
        'audios': [],
        'has_media': false,
      }).select('id').single();
      
      return response['id'] as String;
    } catch (e) {
      print('Error reporting incident: $e');
      rethrow;
    }
  }

  // Upload Incident Media
  static Future<void> uploadIncidentMedia({
    required String incidentId,
    List<String> imagePaths = const [],
    List<String> videoPaths = const [],
    List<String> audioPaths = const [],
  }) async {
    try {
      final List<String> imageUrls = [];
      final List<String> videoUrls = [];
      final List<String> audioUrls = [];

      // Upload images
      for (final path in imagePaths) {
        if (path.isEmpty) continue;
        final file = File(path);
        if (!file.existsSync()) continue;
        
        final fileName = '${incidentId}/images/${DateTime.now().millisecondsSinceEpoch}_${path.split(Platform.pathSeparator).last}';
        print('Attempting to upload image: $fileName');
        
        await _client.storage
            .from('incident-media')
            .upload(fileName, file);
        
        final url = _client.storage
            .from('incident-media')
            .getPublicUrl(fileName);
        
        imageUrls.add(url);
      }

      // Upload videos
      for (final path in videoPaths) {
        if (path.isEmpty) continue;
        final file = File(path);
        if (!file.existsSync()) continue;
        
        final fileName = '${incidentId}/videos/${DateTime.now().millisecondsSinceEpoch}_${path.split(Platform.pathSeparator).last}';
        
        await _client.storage
            .from('incident-media')
            .upload(fileName, file);
        
        final url = _client.storage
            .from('incident-media')
            .getPublicUrl(fileName);
        
        videoUrls.add(url);
      }

      // Upload audios
      for (final path in audioPaths) {
        if (path.isEmpty) continue;
        final file = File(path);
        if (!file.existsSync()) continue;
        
        final fileName = '${incidentId}/audios/${DateTime.now().millisecondsSinceEpoch}_${path.split(Platform.pathSeparator).last}';
        
        await _client.storage
            .from('incident-media')
            .upload(fileName, file);
        
        final url = _client.storage
            .from('incident-media')
            .getPublicUrl(fileName);
        
        audioUrls.add(url);
      }

      // Update incident with media URLs
      final response = await _client.from('incidents').update({
        if (imageUrls.isNotEmpty) 'images': imageUrls,
        if (videoUrls.isNotEmpty) 'videos': videoUrls,
        if (audioUrls.isNotEmpty) 'audios': audioUrls,
        'has_media': imageUrls.isNotEmpty || videoUrls.isNotEmpty || audioUrls.isNotEmpty,
      }).eq('id', incidentId).select();
      
      print('Update incident media response: $response');
      if (response.isEmpty) {
        print('Warning: No rows updated when attaching media to incident $incidentId. Check RLS policies.');
      }
      
    } catch (e) {
      print('Error uploading media: $e');
      rethrow;
    }
  }

  // Send SOS Alert
  static Future<void> sendSOS({
    required String userId,
    String? userName,
    required String location,
  }) async {
    try {
      final authId = fa.FirebaseAuth.instance.currentUser?.uid ?? userId;
      await _client.from('sos_alerts').insert({
        'user_id': authId,
        'user_name': userName ?? 'Unknown',
        'location': location,
        'status': 'active',
      });
    } catch (e) {
      print('Error sending SOS: $e');
      rethrow;
    }
  }

  // Submit Query/Review
  static Future<void> submitQuery({
    required String userId,
    required String name,
    required String phone,
    required String type,
    required String message,
  }) async {
    try {
      final now = DateTime.now().toString().substring(0, 16);
      
      final authId = fa.FirebaseAuth.instance.currentUser?.uid ?? userId;
      await _client.from('citizen_queries').insert({
        'user_id': authId,
        'citizen': name,
        'phone': phone,
        'type': type,
        'message': message,
        'status': 'pending',
        'date': now,
      });
    } catch (e) {
      print('Error submitting query: $e');
      rethrow;
    }
  }

  // Get Citizen Queries (Real-time Stream)
  static Stream<List<Map<String, dynamic>>> getCitizenQueries(String userId) {
    return _client
        .from('citizen_queries')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // Get Citizen Incidents (Real-time Stream)
  static Stream<List<Map<String, dynamic>>> getCitizenIncidents(String userId) {
    return _client
        .from('incidents')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // Get Citizen SOS Alerts (Real-time Stream)
  static Stream<List<Map<String, dynamic>>> getCitizenSOSAlerts(String userId) {
    return _client
        .from('sos_alerts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // Helper: Get severity based on incident type
  static String _getSeverity(String type) {
    if (type.toLowerCase().contains('accident') || 
        type.toLowerCase().contains('assault') ||
        type.toLowerCase().contains('harassment') ||
        type.toLowerCase().contains('theft')) {
      return 'high';
    } else if (type.toLowerCase().contains('vandalism') ||
        type.toLowerCase().contains('theft'))  {
      return 'medium';
    }
    return 'low';
  }

  // Sign Out
  static Future<void> signOut() async {
    await fa.FirebaseAuth.instance.signOut();
    await _client.auth.signOut();
  }

  // Get Current User (Firebase User)
  static fa.User? getCurrentUser() {
    return fa.FirebaseAuth.instance.currentUser;
  }

  // Profile Photo Upload
  static Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) throw 'File does not exist';

      final fileExt = filePath.split('.').last;
      final fileName = 'profiles/${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      print('Uploading profile photo: $fileName');
      
      await _client.storage
          .from('incident-media')
          .upload(fileName, file);
      
      final url = _client.storage
          .from('incident-media')
          .getPublicUrl(fileName);
      
      return url;
    } catch (e) {
      print('Error uploading profile photo: $e');
      rethrow;
    }
  }

  // AI Chat Methods

  /// Save AI chat message
  static Future<void> saveAIChatMessage({
    required String userId,
    required String userName,
    required String sender,
    required String message,
  }) async {
    try {
      final authId = fa.FirebaseAuth.instance.currentUser?.uid ?? userId;
      await _client.from('ai_chat_history').insert({
        'user_id': authId,
        'user_name': userName,
        'sender': sender,
        'message': message,
      });
    } catch (e) {
      print('Error saving AI chat message: $e');
      rethrow;
    }
  }

  /// Get AI chat stream (real-time)
  static Stream<List<Map<String, dynamic>>> getAIChatStream(String userId) {
    return _client
        .from('ai_chat_history')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: true);
  }

  /// Get AI chat history (real-time stream)
  static Stream<List<Map<String, dynamic>>> getAIChatHistory(String userId) {
    return _client
        .from('ai_chat_history')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: true);
  }

  /// Get recent AI chat history (one-time fetch)
  static Future<List<Map<String, dynamic>>> getRecentAIChatHistory(String userId) async {
    try {
      final response = await _client
          .from('ai_chat_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);
      
      return (response as List).cast<Map<String, dynamic>>().reversed.toList();
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }
}
