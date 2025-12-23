import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PoliceFirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Police Login with Email/Password
  static Future<User?> signInPolice(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Get All Incidents (Real-time)
  static Stream<QuerySnapshot> getAllIncidents() {
    return _firestore
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get Pending Incidents
  // Note: Removed .where() to avoid composite index requirement
  // Filter on client side instead
  static Stream<QuerySnapshot> getPendingIncidents() {
    return _firestore
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get Solved Cases
  // Note: Removed .where() to avoid composite index requirement
  // Filter on client side instead
  static Stream<QuerySnapshot> getSolvedCases() {
    return _firestore
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get All Citizens
  static Stream<QuerySnapshot> getCitizens() {
    return _firestore.collection('citizens').snapshots();
  }

  // Get Citizen Queries
  static Stream<QuerySnapshot> getCitizenQueries() {
    return _firestore
        .collection('citizen_queries')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get Active SOS Alerts
  // Note: Removed .where() to avoid composite index requirement
  // Filter on client side instead
  static Stream<QuerySnapshot> getSOSAlerts() {
    return _firestore
        .collection('sos_alerts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get Resolved SOS Alerts
  // Note: Removed .where() to avoid composite index requirement
  // Filter on client side instead
  static Stream<QuerySnapshot> getSolvedSOSAlerts() {
    return _firestore
        .collection('sos_alerts')
        .snapshots();
  }
 
   // Get All SOS Alerts
   static Stream<QuerySnapshot> getAllSOSAlerts() {
     return _firestore.collection('sos_alerts').snapshots();
   }

  // Update Incident Status
  static Future<void> updateIncidentStatus(String incidentId, String status) async {
    await _firestore.collection('incidents').doc(incidentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Respond to Query
  static Future<void> respondToQuery(String queryId, String response) async {
    await _firestore.collection('citizen_queries').doc(queryId).update({
      'response': response,
      'status': 'responded',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  // Resolve SOS Alert
  static Future<void> resolveSOSAlert(String alertId) async {
    await _firestore.collection('sos_alerts').doc(alertId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign Out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check custom claim isPolice on current user
  static Future<bool> hasPolicePrivileges() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims ?? {};
    final v = claims['isPolice'];
    return v == true;
  }

  // Get Current User
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get AI Chat Logs (Flat collection)
  static Stream<QuerySnapshot> getAIChatLogs() {
    return _firestore
        .collection('ai_chat_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

