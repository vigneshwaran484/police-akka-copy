import 'package:supabase_flutter/supabase_flutter.dart';

class PoliceSupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Police Login with Email/Password
  static Future<User?> signInPolice(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Get All Incidents (Real-time)
  static Stream<List<Map<String, dynamic>>> getAllIncidents() {
    return _client
        .from('incidents')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Get Pending Incidents
  static Stream<List<Map<String, dynamic>>> getPendingIncidents() {
    return _client
        .from('incidents')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Get Solved Cases
  static Stream<List<Map<String, dynamic>>> getSolvedCases() {
    return _client
        .from('incidents')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Get All Citizens
  static Stream<List<Map<String, dynamic>>> getCitizens() {
    return _client
        .from('citizens')
        .stream(primaryKey: ['id']);
  }

  // Get Citizen Queries
  static Stream<List<Map<String, dynamic>>> getCitizenQueries() {
    return _client
        .from('citizen_queries')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Get Active SOS Alerts
  static Stream<List<Map<String, dynamic>>> getSOSAlerts() {
    return _client
        .from('sos_alerts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Get Resolved SOS Alerts
  static Stream<List<Map<String, dynamic>>> getSolvedSOSAlerts() {
    return _client
        .from('sos_alerts')
        .stream(primaryKey: ['id']);
  }

  // Get All SOS Alerts
  static Stream<List<Map<String, dynamic>>> getAllSOSAlerts() {
    return _client
        .from('sos_alerts')
        .stream(primaryKey: ['id']);
  }

  // Update Incident Status
  static Future<void> updateIncidentStatus(String incidentId, String status) async {
    try {
      final response = await _client
          .from('incidents')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', incidentId)
          .select();
      
      if (response.isEmpty) {
        throw Exception('No incident found or permission denied (RLS).');
      }
    } catch (e) {
      print('Error updating incident status: $e');
      rethrow;
    }
  }

  // Respond to Query
  static Future<void> respondToQuery(String queryId, String response) async {
    try {
      final res = await _client
          .from('citizen_queries')
          .update({
            'response': response,
            'status': 'responded',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', queryId)
          .select();
      
      if (res.isEmpty) {
        throw Exception('No query found or permission denied (RLS).');
      }
    } catch (e) {
      print('Error responding to query: $e');
      rethrow;
    }
  }

  // Resolve SOS Alert
  static Future<void> resolveSOSAlert(String alertId) async {
    try {
      final response = await _client
          .from('sos_alerts')
          .update({
            'status': 'resolved',
            'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', alertId)
          .select();
      
      if (response.isEmpty) {
        throw Exception('No SOS alert found or permission denied (RLS).');
      }
    } catch (e) {
      print('Error resolving SOS alert: $e');
      rethrow;
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Check if user has police privileges
  static Future<bool> hasPolicePrivileges() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    
    // In Supabase, you can check user metadata or roles
    // For now, we'll assume any authenticated user in the dashboard is police
    return true;
  }

  // Get Current User
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Get AI Chat Logs (Flat collection)
  static Stream<List<Map<String, dynamic>>> getAIChatLogs() {
    return _client
        .from('ai_chat_history')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
