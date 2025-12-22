import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Incident Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: incidentTypes.length,
              itemBuilder: (context, index) {
                final type = incidentTypes[index];
                final isSelected = selectedType == type['name'];
                return GestureDetector(
                  onTap: () => setState(() => selectedType = type['name']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? type['color'] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? type['color'] : Colors.grey, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(type['icon'], size: 30, color: isSelected ? Colors.white : type['color']),
                        const SizedBox(height: 5),
                        Text(type['name'], textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter location or use current location',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(icon: const Icon(Icons.my_location), onPressed: () {}),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the incident...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Add Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 44),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickVideos,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Add Video'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 44),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAudios,
                    icon: const Icon(Icons.mic),
                    label: const Text('Add Audio'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 44),
                      visualDensity: VisualDensity.compact,
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SUBMIT REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
