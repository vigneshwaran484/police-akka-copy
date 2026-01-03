import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../widgets/watermark_base.dart';

class SOSHistoryScreen extends StatefulWidget {
  final String userId;
  const SOSHistoryScreen({super.key, required this.userId});

  @override
  State<SOSHistoryScreen> createState() => _SOSHistoryScreenState();
}

class _SOSHistoryScreenState extends State<SOSHistoryScreen> {
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
              primary: Color(0xFFDC2626), // Branded Red for SOS
              onPrimary: Colors.white,
              onSurface: Color(0xFFDC2626),
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
            title: const Text('SOS Alert History'),
            backgroundColor: const Color(0xFFDC2626),
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
                Tab(text: 'ACTIVE'),
                Tab(text: 'RESOLVED'),
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
                      const Icon(Icons.filter_list, size: 16, color: Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      Text(
                        'Filtering by: ${_selectedDate.toString().split(' ')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: const Text('Clear', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildSOSList(context, 'active'),
                    _buildSOSList(context, 'resolved'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOSList(BuildContext context, String statusFilter) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService.getCitizenSOSAlerts(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final docs = snapshot.data ?? [];
        final items = docs.where((data) {
          
          if (_selectedDate != null) {
            final timestamp = data['created_at'];
            if (timestamp is String) {
              final date = DateTime.parse(timestamp);
              final isSameDay = date.year == _selectedDate!.year && 
                                date.month == _selectedDate!.month && 
                                date.day == _selectedDate!.day;
              if (!isSameDay) return false;
            }
          }

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
                  statusFilter == 'active' 
                    ? (_selectedDate != null ? 'No active SOS on this date' : 'No active SOS alerts') 
                    : (_selectedDate != null ? 'No resolved SOS on this date' : 'No previous SOS alerts'),
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
            final data = items[index];
            final timestamp = data['created_at'] as String?;
            final timeStr = timestamp != null 
                ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(timestamp))
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
