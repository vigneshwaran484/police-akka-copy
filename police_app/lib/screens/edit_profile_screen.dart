import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_service.dart';

class EditProfileScreen extends StatefulWidget {
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
        userId: widget.userId,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Transform.scale(
                      scale: 1.05,
                      child: Image.asset('assets/images/tn_police_logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('TN Police Gov', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_camera),
              label: Text(_photoFileName != null ? 'Photo: $_photoFileName' : 'Choose Profile Photo'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
