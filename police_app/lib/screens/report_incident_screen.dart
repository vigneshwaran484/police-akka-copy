import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

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

  final List<Map<String, dynamic>> incidentTypes = [
    {'name': 'ACCIDENT', 'icon': Icons.car_crash, 'color': Colors.red},
    {'name': 'THEFT', 'icon': Icons.warning, 'color': Colors.orange},
    {'name': 'VANDALISM', 'icon': Icons.broken_image, 'color': Colors.purple},
    {'name': 'LOST ITEM', 'icon': Icons.search_off, 'color': Colors.blue},
    {'name': 'HARASSMENT', 'icon': Icons.report_problem, 'color': Colors.red},
    {'name': 'OTHER', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  Future<void> _submitReport() async {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an incident type')),
      );
      return;
    }

    await FirebaseService.reportIncident(
      userId: widget.phone,
      type: selectedType!,
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
    );

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
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Add Photo'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam),
                    label: const Text('Add Video'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('SUBMIT REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

