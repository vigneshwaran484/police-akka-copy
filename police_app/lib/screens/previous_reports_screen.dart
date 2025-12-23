import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../widgets/watermark_base.dart';

class PreviousReportsScreen extends StatelessWidget {
  final String userId;
  const PreviousReportsScreen({super.key, required this.userId});
  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: const Text('Previous Reports'),
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
          if (docs.isEmpty) {
            return const Center(child: Text('No previous reports'));
          }
          final items = docs.map((d) => d.data() as Map<String, dynamic>).toList()
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
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final i = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text((i['type'] ?? 'INCIDENT').toString().toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                          child: Text((i['status'] ?? 'pending').toString().toUpperCase(), style: const TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('location: ${i['address'] ?? i['location'] ?? ''}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('time: ${i['time'] ?? ''}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    if ((i['description'] ?? '').toString().isNotEmpty) Text(i['description'], style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Builder(builder: (_) {
                      final images = (i['images'] is List) ? List.from(i['images']) : const [];
                      final videos = (i['videos'] is List) ? List.from(i['videos']) : const [];
                      final audios = (i['audios'] is List) ? List.from(i['audios']) : const [];
                      if (images.isEmpty && videos.isEmpty && audios.isEmpty) return const SizedBox.shrink();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (images.isNotEmpty) Chip(label: Text('images: ${images.length}')),
                          if (videos.isNotEmpty) Chip(label: Text('videos: ${videos.length}')),
                          if (audios.isNotEmpty) Chip(label: Text('audios: ${audios.length}')),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }
}
