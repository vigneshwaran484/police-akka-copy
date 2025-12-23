import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/watermark_base.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

class ReportIncidentScreen extends StatefulWidget {
  final String userName;
  final String phone;
  final String aadhar;

  const ReportIncidentScreen({
    super.key,
    required this.userName,
    required this.phone,
    required this.aadhar,
  });

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  String? selectedType;
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _submitting = false;
  List<String> _imagePaths = [];
  List<String> _videoPaths = [];
  List<String> _audioPaths = [];

  final List<Map<String, dynamic>> incidentTypes = [
    {'name': 'ACCIDENT', 'icon': Icons.car_crash, 'color': Colors.red},
    {'name': 'THEFT', 'icon': Icons.warning, 'color': Colors.orange},
    {'name': 'VANDALISM', 'icon': Icons.broken_image, 'color': Colors.purple},
    {'name': 'LOST ITEM', 'icon': Icons.search_off, 'color': Colors.blue},
    {'name': 'HARASSMENT', 'icon': Icons.report_problem, 'color': Colors.red},
    {'name': 'OTHER', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _imagePaths = result.paths.whereType<String>().toList();
      });
    }
  }

  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _videoPaths = result.paths.whereType<String>().toList();
      });
    }
  }

  Future<void> _pickAudios() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _audioPaths = result.paths.whereType<String>().toList();
      });
    }
  }

  Future<void> _submitReport() async {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an incident type')),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter location')),
      );
      return;
    }
    setState(() => _submitting = true);

    try {
      final incidentId = await FirebaseService.reportIncident(
        userId: widget.phone,
        type: selectedType!,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
      ).timeout(const Duration(seconds: 20));
      if (!mounted) return;
      if (_imagePaths.isNotEmpty || _videoPaths.isNotEmpty || _audioPaths.isNotEmpty) {
        if (!FirebaseService.storageUploadsDisabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading media in background...')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attachments saved without upload (test mode)')),
          );
        }
        FirebaseService.uploadIncidentMedia(
          incidentId: incidentId,
          imagePaths: _imagePaths,
          videoPaths: _videoPaths,
          audioPaths: _audioPaths,
        ).then((_) {
          if (!mounted) return;
          if (!FirebaseService.storageUploadsDisabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Media uploaded')),
            );
          }
        }).catchError((e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Media upload failed: $e')),
          );
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report successfully submitted')),
        );
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Submitted'),
          content: Text('Your $selectedType report has been submitted successfully. You will receive updates on your registered phone number.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network is slow. Please try again.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Report Incident'),
          backgroundColor: const Color(0xFFDC2626), // Branded Red
          foregroundColor: Colors.white,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Incident Type', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: incidentTypes.length,
              itemBuilder: (context, index) {
                final type = incidentTypes[index];
                final isSelected = selectedType == type['name'];
                return GestureDetector(
                  onTap: () => setState(() => selectedType = type['name']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? type['color'] : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? type['color'] : Colors.grey[400]!, 
                        width: 2.5
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(color: type['color'].withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(type['icon'], size: 36, color: isSelected ? Colors.white : type['color']),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            type['name'], 
                            textAlign: TextAlign.center, 
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.bold, 
                              color: isSelected ? Colors.white : Colors.black87
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.95),
                hintText: 'Enter location or use current location',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Color(0xFF1E3A8A)), 
                  onPressed: () {}
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.95),
                hintText: 'Describe the incident in detail...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF1E3A8A)),
                    label: const Text('Add Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickVideos,
                    icon: const Icon(Icons.videocam, color: Color(0xFF1E3A8A)),
                    label: const Text('Add Video'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAudios,
                    icon: const Icon(Icons.mic, color: Color(0xFF1E3A8A)),
                    label: const Text('Add Audio'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            if (_imagePaths.isNotEmpty || _videoPaths.isNotEmpty || _audioPaths.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_imagePaths.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.image, size: 18),
                      label: Text('${_imagePaths.length} image(s) selected'),
                    ),
                  if (_videoPaths.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.videocam, size: 18),
                      label: Text('${_videoPaths.length} video(s) selected'),
                    ),
                  if (_audioPaths.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.mic, size: 18),
                      label: Text('${_audioPaths.length} audio file(s) selected'),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: _submitting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'SUBMIT REPORT', 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18, 
                          letterSpacing: 1
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
