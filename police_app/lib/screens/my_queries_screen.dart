import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/watermark_base.dart';

class MyQueriesScreen extends StatefulWidget {
  final String userId;
  const MyQueriesScreen({super.key, required this.userId});

  @override
  State<MyQueriesScreen> createState() => _MyQueriesScreenState();
}

class _MyQueriesScreenState extends State<MyQueriesScreen> {
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
            title: const Text('My Queries & Feedback'),
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
                Tab(text: 'PENDING'),
                Tab(text: 'RESPONDED'),
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
                    _buildQueryList(context, false), // Not responded (Pending)
                    _buildQueryList(context, true),  // Responded
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueryList(BuildContext context, bool showResponded) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService.getCitizenQueries(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data ?? [];
        
        final filteredDocs = docs.where((data) {
          final status = data['status'] ?? 'pending';
          final isRes = status == 'responded' || status == 'resolved';
          
          if (_selectedDate != null) {
            final timestamp = data['created_at'];
            if (timestamp is String) {
              final date = DateTime.parse(timestamp);
              final isSameDay = date.year == _selectedDate!.year && 
                                date.month == _selectedDate!.month && 
                                date.day == _selectedDate!.day;
              if (!isSameDay) return false;
            } else {
               // Try text date if timestamp missing
               try {
                 final dateStr = data['date']; // "YYYY-MM-DD HH:MM"
                 if (dateStr != null && dateStr is String) {
                   final ymd = dateStr.split(' ')[0];
                   if (ymd != _selectedDate.toString().split(' ')[0]) return false;
                 }
               } catch(_) {}
            }
          }

          return showResponded ? isRes : !isRes;
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showResponded ? Icons.mark_chat_read_outlined : Icons.pending_actions,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  showResponded 
                    ? (_selectedDate != null ? 'No responded queries on date' : 'No responded queries yet.') 
                    : (_selectedDate != null ? 'No pending queries on date' : 'No pending queries.'),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final items = filteredDocs.toList()
          ..sort((a, b) {
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
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = items[index];
            final status = data['status'] ?? 'pending';
            final isResponded = status == 'responded' || status == 'resolved';
            final type = data['type'] ?? 'Query';
            
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type.toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isResponded ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isResponded ? 'RESPONDED' : status.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isResponded ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['message'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${data['date'] ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  
                  if (isResponded && data.containsKey('response')) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.reply, size: 16, color: Color(0xFF1E3A8A)),
                              SizedBox(width: 6),
                              Text(
                                'POLICE RESPONSE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['response'],
                            style: const TextStyle(fontSize: 14, color: Colors.black, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
