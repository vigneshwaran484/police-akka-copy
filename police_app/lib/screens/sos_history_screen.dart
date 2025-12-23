import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../widgets/watermark_base.dart';

class SOSHistoryScreen extends StatelessWidget {
  final String userId;
  const SOSHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('SOS Alert History'),
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'ACTIVE'),
                Tab(text: 'RESOLVED'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildSOSList(context, 'active'),
              _buildSOSList(context, 'resolved'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOSList(BuildContext context, String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getCitizenSOSAlerts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final docs = snapshot.data?.docs ?? [];
        final items = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['status'] ?? 'active') == statusFilter;
        }).toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  statusFilter == 'active' ? Icons.notification_important_outlined : Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  statusFilter == 'active' ? 'No active SOS alerts' : 'No previous SOS alerts',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        items.sort((a, b) {
          final ta = (a.data() as Map<String, dynamic>)['timestamp'];
          final tb = (b.data() as Map<String, dynamic>)['timestamp'];
          if (ta is Timestamp && tb is Timestamp) {
            return tb.compareTo(ta);
          }
          return 0;
        });

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = items[index].data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;
            final timeStr = timestamp != null 
                ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                : 'Unknown Time';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: statusFilter == 'active' ? Colors.red.shade100 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.sos, color: Colors.red, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'SOS ALERT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusFilter == 'active' ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusFilter.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusFilter == 'active' ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data['location'] ?? 'Unknown Location',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
