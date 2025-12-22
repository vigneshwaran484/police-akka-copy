import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const bool storageUploadsDisabled = true;

  // Authentication
  static Future<User?> signInWithPhone(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Create/Update Citizen Profile
  static Future<void> saveCitizenProfile({
    required String userId,
    required String name,
    required String phone,
    required String aadhar,
  }) async {
    await _firestore.collection('citizens').doc(userId).set({
      'name': name,
      'phone': phone,
      'aadhar': aadhar,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Report Incident
  static Future<String> reportIncident({
    required String userId,
    required String type,
    required String description,
    required String location,
  }) async {
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
      } catch (_) {}
    }
    final now = DateTime.now().toString().substring(0, 16);
    DocumentReference doc = await _firestore.collection('incidents').add({
      'userId': userId,
      'type': type,
      'description': description,
      'location': location,
      'address': location,
      'time': now,
      'status': 'pending',
      'severity': _getSeverity(type),
      'timestamp': FieldValue.serverTimestamp(),
      'images': [],
      'videos': [],
      'audios': [],
    });
    return doc.id;
  }

  static Future<void> uploadIncidentMedia({
    required String incidentId,
    List<String> imagePaths = const [],
    List<String> videoPaths = const [],
    List<String> audioPaths = const [],
  }) async {
    if (storageUploadsDisabled) {
      final images = imagePaths.map((p) {
        final parts = p.split(Platform.pathSeparator);
        return parts.isNotEmpty ? parts.last : p;
      }).toList();
      final videos = videoPaths.map((p) {
        final parts = p.split(Platform.pathSeparator);
        return parts.isNotEmpty ? parts.last : p;
      }).toList();
      final audios = audioPaths.map((p) {
        final parts = p.split(Platform.pathSeparator);
        return parts.isNotEmpty ? parts.last : p;
      }).toList();
      await _firestore.collection('incidents').doc(incidentId).set({
        if (images.isNotEmpty) 'images': images,
        if (videos.isNotEmpty) 'videos': videos,
        if (audios.isNotEmpty) 'audios': audios,
        'hasMedia': images.isNotEmpty || videos.isNotEmpty || audios.isNotEmpty,
        'mediaMode': 'filenames',
      }, SetOptions(merge: true));
      return;
    }
    final storage = FirebaseStorage.instance;
    final images = <String>[];
    final videos = <String>[];
    final audios = <String>[];

    Future<void> uploadList(List<String> paths, String folder, List<String> out) async {
      final tasks = <Future<void>>[];
      for (final p in paths) {
        if (p.isEmpty) continue;
        final file = File(p);
        if (!file.existsSync()) continue;
        tasks.add(() async {
          final name = p.split(Platform.pathSeparator).isNotEmpty
              ? p.split(Platform.pathSeparator).last
              : 'file_${DateTime.now().millisecondsSinceEpoch}';
          final ref = storage.ref().child('incidents/$incidentId/$folder/${DateTime.now().millisecondsSinceEpoch}_$name');
          final uploadTask = await ref.putFile(file);
          final url = await uploadTask.ref.getDownloadURL();
          out.add(url);
        }());
      }
      await Future.wait(tasks);
    }

    await uploadList(imagePaths, 'images', images);
    await uploadList(videoPaths, 'videos', videos);
    await uploadList(audioPaths, 'audios', audios);

    await _firestore.collection('incidents').doc(incidentId).set({
      if (images.isNotEmpty) 'images': images,
      if (videos.isNotEmpty) 'videos': videos,
      if (audios.isNotEmpty) 'audios': audios,
      'hasMedia': images.isNotEmpty || videos.isNotEmpty || audios.isNotEmpty,
    }, SetOptions(merge: true));
  }

  // Send SOS Alert
  static Future<void> sendSOS({
    required String userId,
    required String location,
  }) async {
    await _firestore.collection('sos_alerts').add({
      'userId': userId,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
    });
  }

  // Submit Query/Review
  static Future<void> submitQuery({
    required String userId,
    required String name,
    required String phone,
    required String type,
    required String message,
  }) async {
    final now = DateTime.now().toString().substring(0, 16);
    await _firestore.collection('citizen_queries').add({
      'userId': userId,
      'citizen': name,
      'phone': phone,
      'type': type,
      'message': message,
      'status': 'pending',
      'date': now,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get Citizen Incidents
  static Stream<QuerySnapshot> getCitizenIncidents(String userId) {
    return _firestore
        .collection('incidents')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static String _getSeverity(String type) {
    if (type.toLowerCase().contains('accident') || 
        type.toLowerCase().contains('assault') ||
        type.toLowerCase().contains('theft')) {
      return 'high';
    } else if (type.toLowerCase().contains('vandalism')) {
      return 'medium';
    }
    return 'low';
  }

  // Sign Out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Current User
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // AI Chat Methods
  static Future<void> saveAIChatMessage({
    required String userId,
    required String userName,
    required String sender,
    required String message,
  }) async {
    await _firestore.collection('ai_chat_history').add({
      'userId': userId,
      'userName': userName,
      'sender': sender,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getAIChatStream(String userId) {
    return _firestore
        .collection('ai_chat_history')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  static Future<List<Map<String, dynamic>>> getRecentAIChatHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('ai_chat_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList().reversed.toList();
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }
}

