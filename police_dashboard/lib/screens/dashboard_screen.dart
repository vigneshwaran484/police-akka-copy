import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _sidebarExpanded = false;
  int _selectedIndex = 0;
  int? _hoveredIncident;

  final List<Map<String, dynamic>> _incidents = [
    {'type': 'ACCIDENT', 'color': Colors.red, 'address': 'GANDHI STREET, TNAGAR', 'time': '10:40am'},
    {'type': 'Vandalism', 'color': Colors.orange, 'address': 'MG ROAD, CHENNAI', 'time': '11:20am'},
    {'type': 'LOST', 'color': Colors.green, 'address': 'ANNA NAGAR, CHENNAI', 'time': '09:15am'},
  ];

  final List<Map<String, dynamic>> _pendingReports = [
    {'type': 'ACCIDENT', 'address': 'GANDHI STREET, TNAGAR', 'time': '10:40am', 'severity': 'high'},
    {'type': 'Theft', 'address': 'MOUNT ROAD', 'time': '11:00am', 'severity': 'high'},
    {'type': 'Vandalism', 'address': 'ADYAR', 'time': '09:30am', 'severity': 'medium'},
    {'type': 'Lost Item', 'address': 'T NAGAR', 'time': '08:45am', 'severity': 'low'},
    {'type': 'Assault', 'address': 'MYLAPORE', 'time': '12:15pm', 'severity': 'high'},
    {'type': 'Noise', 'address': 'VELACHERY', 'time': '02:30pm', 'severity': 'low'},
  ];

  final _sosAlert = {
    'place': 'Anna Nagar',
    'time': '10:45 AM',
    'person': 'Citizen #1234',
  };

  final List<Map<String, dynamic>> _solvedCases = [
    {'id': 'CASE-001', 'type': 'Theft', 'location': 'Anna Nagar', 'date': '15 Dec 2025', 'citizen': 'Rajesh Kumar', 'status': 'Recovered'},
    {'id': 'CASE-002', 'type': 'Vandalism', 'location': 'T Nagar', 'date': '14 Dec 2025', 'citizen': 'Priya Sharma', 'status': 'Resolved'},
    {'id': 'CASE-003', 'type': 'Lost Item', 'location': 'Adyar', 'date': '13 Dec 2025', 'citizen': 'Mohammed Ali', 'status': 'Found'},
    {'id': 'CASE-004', 'type': 'Accident', 'location': 'Mount Road', 'date': '12 Dec 2025', 'citizen': 'Lakshmi Devi', 'status': 'Closed'},
    {'id': 'CASE-005', 'type': 'Noise Complaint', 'location': 'Velachery', 'date': '11 Dec 2025', 'citizen': 'Suresh Babu', 'status': 'Resolved'},
  ];

  final List<Map<String, dynamic>> _citizenData = [
    {'name': 'Rajesh Kumar', 'phone': '9876543210', 'aadhar': '1234-5678-9012', 'cases': 2, 'address': 'Anna Nagar, Chennai'},
    {'name': 'Priya Sharma', 'phone': '9876543211', 'aadhar': '2345-6789-0123', 'cases': 1, 'address': 'T Nagar, Chennai'},
    {'name': 'Mohammed Ali', 'phone': '9876543212', 'aadhar': '3456-7890-1234', 'cases': 3, 'address': 'Adyar, Chennai'},
    {'name': 'Lakshmi Devi', 'phone': '9876543213', 'aadhar': '4567-8901-2345', 'cases': 1, 'address': 'Mount Road, Chennai'},
    {'name': 'Suresh Babu', 'phone': '9876543214', 'aadhar': '5678-9012-3456', 'cases': 2, 'address': 'Velachery, Chennai'},
  ];

  final List<Map<String, dynamic>> _citizenQueries = [
    {'citizen': 'Rajesh Kumar', 'type': 'Review', 'message': 'Please update my case status, it has been pending for 3 days.', 'date': '17 Dec 2025', 'status': 'pending'},
    {'citizen': 'Priya Sharma', 'type': 'Change Request', 'message': 'Wrong address mentioned in my report. Please correct to T Nagar Main Road.', 'date': '16 Dec 2025', 'status': 'pending'},
    {'citizen': 'Mohammed Ali', 'type': 'Feedback', 'message': 'Thank you for quick resolution of my case. Excellent service!', 'date': '15 Dec 2025', 'status': 'resolved'},
    {'citizen': 'Lakshmi Devi', 'type': 'Review', 'message': 'Need more details about the investigation progress.', 'date': '15 Dec 2025', 'status': 'pending'},
    {'citizen': 'Suresh Babu', 'type': 'Change Request', 'message': 'Please change the incident time from 10:00 AM to 11:30 AM.', 'date': '14 Dec 2025', 'status': 'resolved'},
  ];

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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_police, size: 40, color: Color(0xFF1E3A8A)),
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
              color: const Color(0xFF4A90A4),
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
              _buildSidebarItem(2, Icons.check_circle_outline, 'Solved cases'),
              _buildSidebarItem(3, Icons.people_outline, 'Citizen data'),
              _buildSidebarItem(4, Icons.feedback_outlined, 'Citizen Queries'),
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
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildIncidentReportsSection(constraints)),
                          const SizedBox(width: 60),
                          Expanded(child: _buildSOSSection(constraints)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIncidentReportsSection(constraints),
                          const SizedBox(height: 30),
                          _buildSOSSection(constraints),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INCIDENT REPORTS',
          style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ..._incidents.map((incident) => _buildIncidentCard(incident)),
      ],
    );
  }

  Widget _buildSOSSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SOS', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('details such as', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20)),
              const SizedBox(height: 12),
              Text('place: ${_sosAlert['place']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('time: ${_sosAlert['time']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('person: ${_sosAlert['person']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
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
            incident['type'],
            style: TextStyle(color: incident['color'], fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('description of the incident\nsuch as place, time etc', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
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
                      style: TextStyle(color: const Color(0xFF1E3A8A), fontSize: constraints.maxWidth * 0.025 > 28 ? 28 : constraints.maxWidth * 0.025, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: _pendingReports.length,
                        itemBuilder: (context, index) => _buildReportCard(index),
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

  Widget _buildReportCard(int index) {
    final report = _pendingReports[index];
    final isHovered = _hoveredIncident == index;
    final severityColor = _getSeverityColor(report['severity']);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIncident = index),
      onExit: (_) => setState(() => _hoveredIncident = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isHovered ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: severityColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isHovered
              ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
              : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report['type'].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('address: ${report['address']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              Text('time: ${report['time']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

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
                const SizedBox(height: 8),
                Text('Total solved cases: ${_solvedCases.length}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                const SizedBox(height: 30),
                ..._solvedCases.map((caseData) => _buildSolvedCaseCard(caseData)),
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
                Text('Citizens with resolved cases: ${_citizenData.length}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                const SizedBox(height: 30),
                ..._citizenData.map((citizen) => _buildCitizenCard(citizen)),
              ],
            ),
          ),
        ],
      ),
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
    return Container(
      color: const Color(0xFFE8EBF0),
      child: Stack(
        children: [
          Center(
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
                Text('Reviews and change requests from citizens', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                const SizedBox(height: 30),
                ..._citizenQueries.map((query) => _buildQueryCard(query)),
              ],
            ),
          ),
        ],
      ),
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
}

