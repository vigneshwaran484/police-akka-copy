import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'edit_profile_screen.dart';
import '../widgets/watermark_base.dart';
import 'current_reports_screen.dart';
import 'previous_reports_screen.dart';


class ProfileScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String aadhar;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.aadhar,
  });

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top Header with Logo
                _buildHeader(),
                
                const SizedBox(height: 30),
                
                // User Avatar and Name
                _buildAvatarSection(context),
                
                const SizedBox(height: 30),
                
                // User Info Card
                _buildInfoCard(),
                
                const SizedBox(height: 40),
                
                // Action Buttons
                _buildActionButtons(context),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/tn_police_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 3,
            color: const Color(0xFF8B0000),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1E3A8A), width: 3),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 80, color: Color(0xFFB0B0B0)),
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToEdit(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          name.toUpperCase(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_android, 'PHONE NUMBER', phone),
          const Divider(height: 30),
          _buildInfoRow(Icons.badge, 'AADHAR NUMBER', aadhar),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          _buildActionButton(
            label: 'CURRENT REPORTS',
            subtitle: 'Check ongoing complaints',
            icon: Icons.pending_actions,
            color: const Color(0xFF1E3A8A),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CurrentReportsScreen(userId: phone)),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            label: 'PREVIOUS REPORTS',
            subtitle: 'View your history',
            icon: Icons.history,
            color: const Color(0xFFDC2626),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PreviousReportsScreen(userId: phone)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          userId: phone,
          name: name,
          phone: phone,
          aadhar: aadhar,
          photo: null,
        ),
      ),
    );
  }
}
