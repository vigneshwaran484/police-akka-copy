import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _sidebarExpanded = false;
  int _selectedIndex = 0;

  // Citizen queries now come from Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/tn_police_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('தமிழ்நாடு காவல்துறை', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('TAMIL NADU POLICE', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('location of\npolice station', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return MouseRegion(
      onEnter: (_) => setState(() => _sidebarExpanded = true),
      onExit: (_) => setState(() => _sidebarExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _sidebarExpanded ? 220 : 70,
        color: const Color(0xFF5A6A7A),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              _buildSidebarItem(0, Icons.dashboard, 'Dashboard'),
              _buildSidebarItem(1, Icons.description, 'Reported Incidents'),
              _buildSidebarItem(5, Icons.sos, 'Reported SOS'),
              _buildSidebarItem(2, Icons.check_circle_outline, 'Solved cases'),
              _buildSidebarItem(3, Icons.people_outline, 'Citizen data'),
              _buildSidebarItem(4, Icons.feedback_outlined, 'Citizen Queries'),
              _buildSidebarItem(6, Icons.chat_bubble_outline, 'AI Chatbot Replies'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A5A6A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 1:
        return _buildPendingReportsView();
      case 2:
        return _buildSolvedCasesView();
      case 3:
        return _buildCitizenDataView();
      case 4:
        return _buildCitizenQueriesView();
      case 5:
        return _buildReportedSOSView();
      case 6:
        return _buildAIChatbotsView();
      default:
        return _buildMainDashboard();
    }
  }

  Widget _buildMainDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        
        return Container(
          color: const Color(0xFFE8EBF0),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.local_police, size: constraints.maxHeight * 0.5, color: Colors.grey),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: isWide
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildIncidentReportsSection(constraints)),
                              const SizedBox(width: 60),
                              Expanded(child: _buildSOSSection(constraints)),
                            ],
                          ),
                          // Temporarily commented out to fix Firestore streaming errors
                          // const SizedBox(height: 60),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Expanded(flex: 2, child: _buildSolvedCasesSection(constraints)),
                          //     const SizedBox(width: 60),
                          //     Expanded(child: _buildResolvedSOSSection(constraints)),
                          //   ],
                          // ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIncidentReportsSection(constraints),
                          const SizedBox(height: 30),
                          _buildSOSSection(constraints),
                          // Temporarily commented out to fix Firestore streaming errors
                          // const SizedBox(height: 60),
                          // _buildSolvedCasesSection(constraints),
                          // const SizedBox(height: 30),
                          // _buildResolvedSOSSection(constraints),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncidentReportsSection(BoxConstraints constraints) {
    return StreamBuilder<QuerySnapshot>(
      stream: PoliceFirebaseService.getPendingIncidents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading incidents');
        }
        final docs = snapshot.data?.docs ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PENDING INCIDENT REPORTS',
              style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No Pending Incident Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (docs.isNotEmpty)
              ...docs.take(3).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildIncidentCard({
                  'id': doc.id,
                  'status': data['status'],
                  'type': (data['type'] ?? 'INCIDENT').toString(),
                  'color': _getSeverityColor((data['severity'] ?? 'low') as String),
                  'description': (data['description'] ?? '').toString(),
                  'address': data['address'] ?? data['location'],
                  'location': data['location'],
                  'timestamp': data['timestamp'],
                  'time': data['time'],
                });
              }),
          ],
        );
      },
    );
  }

  Widget _buildSOSSection(BoxConstraints constraints) {
    return StreamBuilder<QuerySnapshot>(
      stream: PoliceFirebaseService.getSOSAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading SOS alerts');
        }
        final docs = snapshot.data?.docs ?? [];
        final sorted = List<QueryDocumentSnapshot>.from(docs);
        sorted.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          final ta = da['timestamp'];
          final tb = db['timestamp'];
          final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
          final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });
        final latestDoc = sorted.isNotEmpty ? sorted.first : null;
        final latest = latestDoc != null ? latestDoc.data() as Map<String, dynamic> : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SOS', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: latest == null
                  ? const Text('No active SOS alerts', style: TextStyle(color: Colors.white, fontSize: 18))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Active SOS Alert', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20)),
                        const SizedBox(height: 12),
                        Text('location: ${latest['location'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('time: ${_formatTimestamp(latest['timestamp'] ?? latest['time'])}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('person: ${latest['userId'] ?? 'Citizen'}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (latestDoc != null) {
                              await PoliceFirebaseService.resolveSOSAlert(latestDoc.id);
                            }
                          },
                          child: const Text('Mark Done', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> incident) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (incident['type'] ?? 'INCIDENT').toString().toUpperCase(),
            style: TextStyle(color: incident['color'] ?? Colors.grey, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if ((incident['description'] ?? '').toString().isNotEmpty)
            Text(incident['description'], style: TextStyle(color: Colors.grey[800], fontSize: 16))
          else
            Text('No description provided', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 8),
          Text('address: ${incident['address'] ?? incident['location'] ?? 'Unknown'}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 4),
          Text('time: ${_formatTimestamp(incident['timestamp'] ?? incident['time'])}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 12),
          if ((incident['status'] ?? '') != 'resolved' && (incident['id'] ?? '') != '')
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final id = (incident['id'] ?? '').toString();
                  if (id.isEmpty) return;
                  await PoliceFirebaseService.updateIncidentStatus(id, 'resolved');
                },
                child: const Text('Mark Done', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingReportsView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 800) crossAxisCount = 2;
        if (constraints.maxWidth < 500) crossAxisCount = 1;

        return StreamBuilder<QuerySnapshot>(
          stream: PoliceFirebaseService.getPendingIncidents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading reports'));
            }
            final docs = snapshot.data?.docs ?? [];
            final sorted = List<QueryDocumentSnapshot>.from(docs);
            sorted.sort((a, b) {
              final da = a.data() as Map<String, dynamic>;
              final db = b.data() as Map<String, dynamic>;
              final ta = da['timestamp'];
              final tb = db['timestamp'];
              final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
              final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
              return mb.compareTo(ma);
            });

            return Container(
              color: const Color(0xFFE8EBF0),
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.local_police, size: constraints.maxHeight * 0.5, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENDING INCIDENT REPORTS',
                          style: TextStyle(
                            color: const Color(0xFF1E3A8A),
                            fontSize: constraints.maxWidth * 0.025 > 28 ? 28 : constraints.maxWidth * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (docs.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text('No pending incident reports'),
                            ),
                          ),
                        if (docs.isNotEmpty)
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: sorted.length,
                              itemBuilder: (context, index) {
                                final data = sorted[index].data() as Map<String, dynamic>;
                                final severity = (data['severity'] ?? 'low') as String;
                                final color = _getSeverityColor(severity);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        (data['type'] ?? 'INCIDENT').toString().toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'address: ${data['address'] ?? data['location'] ?? 'Unknown'}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        'time: ${_formatTimestamp(data['timestamp'] ?? data['time'])}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black54),
                                        onPressed: () async {
                                          final id = sorted[index].id;
                                          try {
                                            await PoliceFirebaseService.updateIncidentStatus(id, 'resolved');
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Incident marked resolved')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to resolve: $e')),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('Mark Done', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportedSOSView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 800) crossAxisCount = 2;
        if (constraints.maxWidth < 500) crossAxisCount = 1;

        return StreamBuilder<QuerySnapshot>(
          stream: PoliceFirebaseService.getSOSAlerts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading SOS alerts'));
            }
            final docs = snapshot.data?.docs ?? [];
            final sorted = List<QueryDocumentSnapshot>.from(docs);
            sorted.sort((a, b) {
              final da = a.data() as Map<String, dynamic>;
              final db = b.data() as Map<String, dynamic>;
              final ta = da['timestamp'];
              final tb = db['timestamp'];
              final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
              final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
              return mb.compareTo(ma);
            });

            return Container(
              color: const Color(0xFFE8EBF0),
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.sos, size: constraints.maxHeight * 0.5, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REPORTED SOS ALERTS',
                          style: TextStyle(
                            color: const Color(0xFF1E3A8A),
                            fontSize: constraints.maxWidth * 0.025 > 28 ? 28 : constraints.maxWidth * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (docs.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text('No active SOS alerts'),
                            ),
                          ),
                        if (docs.isNotEmpty)
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: sorted.length,
                              itemBuilder: (context, index) {
                                final data = sorted[index].data() as Map<String, dynamic>;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'location: ${data['location'] ?? 'Unknown'}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        'time: ${_formatTimestamp(data['timestamp'] ?? data['time'])}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        'person: ${data['userId'] ?? 'Citizen'}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black54),
                                        onPressed: () async {
                                          final id = sorted[index].id;
                                          try {
                                            await PoliceFirebaseService.resolveSOSAlert(id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('SOS marked resolved')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to resolve: $e')),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('Mark Done', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate().toLocal();
      final s = d.toString();
      return s.length >= 16 ? s.substring(0, 16) : s;
    }
    if (value is String) {
      return value;
    }
    return '';
  }
  // _buildReportCard removed - pending reports now use live Firestore data above.

  Widget _buildSolvedCasesView() {
    return Container(
      color: const Color(0xFFE8EBF0),
      child: Stack(
        children: [
          const Center(
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.local_police, size: 300, color: Colors.grey),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOLVED CASES HISTORY',
                  style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: PoliceFirebaseService.getSolvedCases(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Error loading solved cases');
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No Solved Cases Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: docs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildSolvedCaseCard({
                          'id': 'CASE-${(index + 1).toString().padLeft(3, '0')}',
                          'type': (data['type'] ?? 'INCIDENT').toString(),
                          'location': (data['address'] ?? data['location'] ?? 'Unknown').toString(),
                          'date': _formatTimestamp(data['timestamp'] ?? data['time']),
                          'citizen': (data['userName'] ?? data['name'] ?? 'Citizen').toString(),
                          'status': 'Resolved',
                        });
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
                const Text(
                  'RESOLVED SOS ALERTS',
                  style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: PoliceFirebaseService.getResolvedSOSAlerts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Error loading resolved SOS');
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No Resolved SOS Alerts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: docs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildSolvedCaseCard({
                          'id': 'SOS-${(index + 1).toString().padLeft(3, '0')}',
                          'type': 'SOS ALERT',
                          'location': (data['location'] ?? 'Unknown').toString(),
                          'date': _formatTimestamp(data['timestamp'] ?? data['time']),
                          'citizen': (data['userName'] ?? data['name'] ?? 'Citizen').toString(),
                          'status': 'Resolved',
                        });
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolvedCaseCard(Map<String, dynamic> caseData) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(caseData['id'], style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(caseData['status'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Type: ${caseData['type']}', style: const TextStyle(fontSize: 16)),
                Text('Location: ${caseData['location']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text('Date: ${caseData['date']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text('Citizen: ${caseData['citizen']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitizenDataView() {
    return StreamBuilder<QuerySnapshot>(
      stream: PoliceFirebaseService.getAllIncidents(),
      builder: (context, incSnapshot) {
        if (incSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (incSnapshot.hasError) {
          return const Center(child: Text('Error loading citizen data'));
        }
        final incDocs = incSnapshot.data?.docs ?? [];
        return StreamBuilder<QuerySnapshot>(
          stream: PoliceFirebaseService.getAllSOSAlerts(),
          builder: (context, sosSnapshot) {
            if (sosSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (sosSnapshot.hasError) {
              return const Center(child: Text('Error loading citizen data'));
            }
            final sosDocs = sosSnapshot.data?.docs ?? [];
            final Map<String, Map<String, dynamic>> reporters = {};
            for (final doc in incDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = (data['userId'] ?? '').toString();
              if (uid.isEmpty) continue;
              final name = (data['userName'] ?? data['name'] ?? uid).toString();
              final entry = reporters.putIfAbsent(uid, () {
                return {
                  'name': name,
                  'phone': uid,
                  'aadhar': 'N/A',
                  'address': (data['address'] ?? data['location'] ?? 'Unknown').toString(),
                  'cases': 0,
                };
              });
              entry['cases'] = (entry['cases'] as int) + 1;
            }
            for (final doc in sosDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = (data['userId'] ?? '').toString();
              if (uid.isEmpty) continue;
              final name = (data['userName'] ?? data['name'] ?? uid).toString();
              final entry = reporters.putIfAbsent(uid, () {
                return {
                  'name': name,
                  'phone': uid,
                  'aadhar': 'N/A',
                  'address': (data['location'] ?? 'Unknown').toString(),
                  'cases': 0,
                };
              });
              entry['cases'] = (entry['cases'] as int) + 1;
            }
            final reporterList = reporters.values.toList()
              ..sort((a, b) => (b['cases'] as int).compareTo(a['cases'] as int));
            return Container(
              color: const Color(0xFFE8EBF0),
              child: Stack(
                children: [
                  const Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.local_police, size: 300, color: Colors.grey),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CITIZEN DATA',
                          style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Citizens who reported: ${reporterList.length}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        const SizedBox(height: 30),
                        ...reporterList.map((citizen) => _buildCitizenCard(citizen)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCitizenCard(Map<String, dynamic> citizen) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Color(0xFF1E3A8A), size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(citizen['name'], style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${citizen['cases']} cases', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(citizen['phone'], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    const SizedBox(width: 24),
                    const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Aadhar: ${citizen['aadhar']}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(citizen['address'], style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitizenQueriesView() {
    return StreamBuilder<QuerySnapshot>(
      stream: PoliceFirebaseService.getCitizenQueries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading queries'));
        }
        final docs = snapshot.data?.docs ?? [];

        return Container(
          color: const Color(0xFFE8EBF0),
          child: Stack(
            children: [
              const Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.local_police, size: 300, color: Colors.grey),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CITIZEN QUERIES & REQUESTS',
                      style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Reviews and change requests from citizens',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 30),
                    if (docs.isEmpty)
                      const Text('No queries yet.')
                    else
                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildQueryCard(data);
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueryCard(Map<String, dynamic> query) {
    final isPending = query['status'] == 'pending';
    Color typeColor;
    IconData typeIcon;
    
    switch (query['type']) {
      case 'Review':
        typeColor = Colors.blue;
        typeIcon = Icons.rate_review;
        break;
      case 'Change Request':
        typeColor = Colors.orange;
        typeIcon = Icons.edit_note;
        break;
      case 'Feedback':
        typeColor = Colors.green;
        typeIcon = Icons.thumb_up;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.message;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: typeColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(query['citizen'], style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(query['type'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(isPending ? 'PENDING' : 'RESOLVED', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(query['message'], style: const TextStyle(fontSize: 16, height: 1.4)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(query['date'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    if (isPending) ...[
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text('Respond', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Removed unused _buildSolvedCasesSection

  // Removed unused _buildResolvedSOSSection

  Widget _buildAIChatbotsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: PoliceFirebaseService.getAllAIChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading AI chats'));
        }
        final docs = snapshot.data?.docs ?? [];

        return Container(
          color: const Color(0xFFE8EBF0),
          child: Stack(
            children: [
              const Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.chat_bubble, size: 300, color: Colors.grey),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI CHATBOT REPLY',
                      style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Total conversations: ${docs.length}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 30),
                    if (docs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No AI chat conversations yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ),
                      ),
                    if (docs.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final userName = (data['userName'] ?? 'user').toString();
                            final userId = doc.id;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showChatDialog(context, userId, userName);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E3A8A),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text(
                                      'view user chat and response',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Conversation with $userName',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: PoliceFirebaseService.getAIChatMessages(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading messages'));
                    }
                    final messages = snapshot.data?.docs ?? [];

                    if (messages.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index].data() as Map<String, dynamic>;
                        final isUser = data['sender'] == 'user';
                        final message = data['message'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isUser)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.support_agent, size: 24, color: Color(0xFF1E3A8A)),
                                ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? const Color(0xFF1E3A8A)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      color: isUser ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (isUser)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(Icons.person, size: 24, color: Colors.grey),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
