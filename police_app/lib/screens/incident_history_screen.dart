import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/watermark_base.dart';

class IncidentHistoryScreen extends StatefulWidget {
  final String userId;
  const IncidentHistoryScreen({super.key, required this.userId});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Reported Incidents'),
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(_selectedDate != null ? Icons.filter_alt : Icons.filter_alt_off),
                onPressed: _pickDate,
                tooltip: 'Filter by Date',
              ),
              if (_selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => setState(() => _selectedDate = null),
                  tooltip: 'Clear Filter',
                ),
            ],
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'CURRENT'),
                Tab(text: 'PAST'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (_selectedDate != null)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 16, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 8),
                      Text(
                        'Filtering by: ${_selectedDate.toString().split(' ')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: const Text('Clear', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildIncidentList(context, true), // Current
                    _buildIncidentList(context, false), // Past
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentList(BuildContext context, bool isCurrent) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService.getCitizenIncidents(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final docs = snapshot.data ?? [];
        final items = docs.where((data) {
          final status = data['status'] ?? 'pending';
          final isResolved = status == 'resolved' || status == 'closed';
          
          if (_selectedDate != null) {
            final timestamp = data['created_at'];
            if (timestamp is String) {
              final date = DateTime.parse(timestamp);
              final isSameDay = date.year == _selectedDate!.year && 
                                date.month == _selectedDate!.month && 
                                date.day == _selectedDate!.day;
              if (!isSameDay) return false;
            } else {
              // Try to parse string time if timestamp not available
              try {
                final timeStr = data['time'] as String?;
                if (timeStr != null) {
                   // "YYYY-MM-DD HH:MM"
                   final parts = timeStr.split(' ')[0].split('-');
                   if (parts.length == 3) {
                     final y = int.parse(parts[0]);
                     final m = int.parse(parts[1]);
                     final d = int.parse(parts[2]);
                     if (y != _selectedDate!.year || m != _selectedDate!.month || d != _selectedDate!.day) {
                       return false;
                     }
                   }
                }
              } catch (_) {}
            }
          }

          return isCurrent ? !isResolved : isResolved;
        }).toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCurrent ? Icons.pending_actions : Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  isCurrent ? 'No current reports found' : 'No past reports found',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        items.sort((a, b) {
          final ta = a['created_at'];
          final tb = b['created_at'];
          if (ta is String && tb is String) {
            return DateTime.parse(tb).compareTo(DateTime.parse(ta));
          }
          return 0;
        });

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final i = items[index];
            final status = i['status'] ?? 'pending';
            final type = i['type'] ?? 'INCIDENT';
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type.toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.orange.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'location: ${i['address'] ?? i['location'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'time: ${i['time'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  if ((i['description'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Description:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      i['description'],
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Builder(builder: (_) {
                    final images = (i['images'] is List) ? List.from(i['images']) : const [];
                    final videos = (i['videos'] is List) ? List.from(i['videos']) : const [];
                    final audios = (i['audios'] is List) ? List.from(i['audios']) : const [];
                    if (images.isEmpty && videos.isEmpty && audios.isEmpty) return const SizedBox.shrink();
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (images.isNotEmpty) _buildMediaChip(Icons.image, 'Images: ${images.length}'),
                        if (videos.isNotEmpty) _buildMediaChip(Icons.videocam, 'Videos: ${videos.length}'),
                        if (audios.isNotEmpty) _buildMediaChip(Icons.mic, 'Audios: ${audios.length}'),
                      ],
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMediaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
