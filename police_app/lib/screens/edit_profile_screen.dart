import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_service.dart';
import '../widgets/watermark_base.dart';

class EditProfileScreen extends StatefulWidget {
  // ... existing fields ...
  final String userId;
  final String name;
  final String phone;
  final String aadhar;
  final String? photo;
  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.phone,
    required this.aadhar,
    this.photo,
  });
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _phoneController;
  String? _photoFileName;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phone);
  }
  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final path = result.paths.first;
      if (path != null) {
        final parts = path.split('/');
        setState(() {
          _photoFileName = parts.isNotEmpty ? parts.last : path;
        });
      }
    }
  }
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseService.saveCitizenProfile(
        username: widget.userId,
        name: widget.name,
        phone: _phoneController.text.trim(),
        aadhar: widget.aadhar,
        photo: _photoFileName ?? widget.photo,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFDC2626), // Match branded AppBar color
        foregroundColor: Colors.white,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/tn_police_logo.png'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TN Police Gov',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Update Phone Number',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                ),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF1E3A8A)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_camera, color: Color(0xFF1E3A8A)),
                label: Text(
                  _photoFileName != null ? 'Photo: $_photoFileName' : 'CHOOSE PROFILE PHOTO',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: _saving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'SAVE CHANGES',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
