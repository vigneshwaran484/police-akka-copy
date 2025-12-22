import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class CurrentReportsScreen extends StatelessWidget {
  final String userId;
  const CurrentReportsScreen({super.key, required this.userId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Reports'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getCitizenIncidents(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          final incidents = docs.map((d) => d.data() as Map<String, dynamic>).toList()
            ..sort((a, b) {
              final ta = a['timestamp'];
              final tb = b['timestamp'];
              if (ta is Timestamp && tb is Timestamp) {
                return tb.compareTo(ta);
              }
              final sa = (a['time'] ?? '').toString();
              final sb = (b['time'] ?? '').toString();
              return sb.compareTo(sa);
            });
          final pending = incidents.where((i) => (i['status'] ?? 'pending') != 'resolved').toList();
          final current = pending.isNotEmpty ? pending.first : null;
          if (current == null) {
            return const Center(child: Text('No pending reports'));
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((current['type'] ?? 'INCIDENT').toString().toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 8),
                  Text('status: ${current['status'] ?? 'pending'}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('location: ${current['address'] ?? current['location'] ?? ''}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('time: ${current['time'] ?? ''}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  if ((current['description'] ?? '').toString().isNotEmpty) Text(current['description'], style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
