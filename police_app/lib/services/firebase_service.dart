import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    });
    return doc.id;
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
}

