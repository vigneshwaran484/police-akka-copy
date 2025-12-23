import 'package:flutter/material.dart';
import '../widgets/watermark_base.dart';
import '../services/firebase_service.dart';

class WriteToUsScreen extends StatefulWidget {
  final String userName;
  final String phone;
  final String? initialType; // Optional pre-selected type

  const WriteToUsScreen({
    super.key,
    required this.userName,
    required this.phone,
    this.initialType,
  });

  @override
  State<WriteToUsScreen> createState() => _WriteToUsScreenState();
}

class _WriteToUsScreenState extends State<WriteToUsScreen> {
  final TextEditingController _queryController = TextEditingController();
  String? _selectedType;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category (Query or Feedback)')),
      );
      return;
    }

    final message = _queryController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await FirebaseService.submitQuery(
        userId: widget.phone,
        name: widget.userName,
        phone: widget.phone,
        type: _selectedType!,
        message: message,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_selectedType} Submitted'),
          content: Text('Your ${_selectedType!.toLowerCase()} has been sent successfully to the TN Police Gov. We will get back to you soon.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to Home
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      appBar: AppBar(
        title: const Text('Write To Us'),
        backgroundColor: const Color(0xFFDC2626), 
        foregroundColor: Colors.white,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // Logo header
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Image.asset('assets/images/tn_police_logo.png'),
              ),
            ),
            const SizedBox(height: 20),
            // Divider
            Container(height: 3, color: const Color(0xFF8B0000), margin: const EdgeInsets.symmetric(horizontal: 20)),
            const SizedBox(height: 30),
            
            // Category Selection
            const Text(
              'Select Category:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildCategoryButton('Query', Icons.question_answer),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildCategoryButton('Feedback', Icons.thumb_up),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Text input field (Chatbox)
            Container(
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
                border: Border.all(color: const Color(0xFF1E3A8A), width: 1.5),
              ),
              child: TextField(
                controller: _queryController,
                maxLines: 6,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  hintText: _selectedType == 'Query' 
                      ? 'Type your query here...' 
                      : _selectedType == 'Feedback'
                          ? 'Type your feedback here...'
                          : 'Select a category and type here...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: Center(
                  child: _submitting 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'SUBMIT',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String type, IconData icon) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1E3A8A),
            width: 2,
          ),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              type.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}