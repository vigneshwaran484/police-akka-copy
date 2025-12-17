import 'package:flutter/material.dart';

class PoliceDashboardScreen extends StatefulWidget {
  final String officerName;
  final String badgeNumber;
  final String station;

  const PoliceDashboardScreen({
    super.key,
    required this.officerName,
    required this.badgeNumber,
    required this.station,
  });

  @override
  State<PoliceDashboardScreen> createState() => _PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState extends State<PoliceDashboardScreen> {
  int _selectedIndex = 0;

  // Demo incident data
  final List<Map<String, dynamic>> _incidents = [
    {
      'id': 'INC-001',
      'type': 'Theft',
      'location': 'Anna Nagar, Chennai',
      'time': '2 hours ago',
      'status': 'pending',
      'priority': 'high',
      'reporter': 'Citizen #1234',
    },
    {
      'id': 'INC-002',
      'type': 'Traffic Violation',
      'location': 'Mount Road, Chennai',
      'time': '4 hours ago',
      'status': 'investigating',
      'priority': 'medium',
      'reporter': 'Citizen #5678',
    },
    {
      'id': 'INC-003',
      'type': 'Noise Complaint',
      'location': 'T. Nagar, Chennai',
      'time': '6 hours ago',
      'status': 'resolved',
      'priority': 'low',
      'reporter': 'Citizen #9012',
    },
    {
      'id': 'INC-004',
      'type': 'SOS Alert',
      'location': 'Adyar, Chennai',
      'time': '30 mins ago',
      'status': 'pending',
      'priority': 'critical',
      'reporter': 'Citizen #3456',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // Sidebar
          if (isWide) _buildSidebar(),
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
      drawer: isWide ? null : Drawer(child: _buildSidebar()),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFF1E3A8A),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_police, color: Color(0xFF1E3A8A), size: 30),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TN POLICE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Dashboard', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          _buildNavItem(Icons.dashboard, 'Dashboard', 0),
          _buildNavItem(Icons.report, 'Incidents', 1),
          _buildNavItem(Icons.sos, 'SOS Alerts', 2),
          _buildNavItem(Icons.people, 'Citizens', 3),
          _buildNavItem(Icons.analytics, 'Analytics', 4),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.officerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Badge: ${widget.badgeNumber}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(widget.station, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Logout', style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.amber : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width <= 800)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Text('Police Control Room', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700, size: 18),
                const SizedBox(width: 8),
                Text('${_incidents.where((i) => i['priority'] == 'critical').length} Critical', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundColor: Color(0xFF1E3A8A),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildIncidentsContent();
      case 2:
        return _buildSOSContent();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildStatCard('Total Incidents', '${_incidents.length}', Icons.report, Colors.blue),
              _buildStatCard('Pending', '${_incidents.where((i) => i['status'] == 'pending').length}', Icons.pending, Colors.orange),
              _buildStatCard('Investigating', '${_incidents.where((i) => i['status'] == 'investigating').length}', Icons.search, Colors.purple),
              _buildStatCard('Resolved', '${_incidents.where((i) => i['status'] == 'resolved').length}', Icons.check_circle, Colors.green),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Recent Incidents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._incidents.take(3).map((incident) => _buildIncidentCard(incident)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildIncidentsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All Incidents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._incidents.map((incident) => _buildIncidentCard(incident)),
        ],
      ),
    );
  }

  Widget _buildSOSContent() {
    final sosAlerts = _incidents.where((i) => i['priority'] == 'critical').toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.sos, color: Colors.red.shade700, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active SOS Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                      Text('${sosAlerts.length} alerts require immediate attention', style: TextStyle(color: Colors.red.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...sosAlerts.map((incident) => _buildIncidentCard(incident)),
          if (sosAlerts.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No active SOS alerts', style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> incident) {
    Color priorityColor;
    switch (incident['priority']) {
      case 'critical':
        priorityColor = Colors.red;
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      case 'medium':
        priorityColor = Colors.blue;
        break;
      default:
        priorityColor = Colors.grey;
    }

    Color statusColor;
    switch (incident['status']) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'investigating':
        statusColor = Colors.blue;
        break;
      case 'resolved':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(incident['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(incident['priority'].toUpperCase(), style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(incident['type'], style: const TextStyle(fontSize: 14)),
                Text('${incident['location']} • ${incident['time']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(incident['status'].toUpperCase(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

