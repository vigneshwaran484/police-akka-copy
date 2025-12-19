import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class CitizenChatScreen extends StatefulWidget {
  final String userName;
  final String phone;
  final String aadhar;

  const CitizenChatScreen({
    super.key,
    required this.userName,
    required this.phone,
    required this.aadhar,
  });

  @override
  State<CitizenChatScreen> createState() => _CitizenChatScreenState();
}

class _CitizenChatScreenState extends State<CitizenChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(
        fromPolice: true,
        text:
            'Vanakkam! I am your virtual police guide.\n\nDescribe your problem and I will share it with the nearest police station.',
      ),
    );
  }

  String _generateReply(String userText) {
    final text = userText.toLowerCase();

    if (text.contains('sos') ||
        text.contains('help') && (text.contains('now') || text.contains('immediately'))) {
      return
          'This sounds urgent.\n\nFor any emergency, please use the SOS button in the app or dial 112 immediately so that officers can reach you faster.';
    }

    if (text.contains('accident') || text.contains('crash')) {
      return
          'I am sorry to hear about the accident.\n\n1. If anyone is injured, call 108 for ambulance and 112 for emergency police help.\n'
          '2. If it is safe, note the vehicle numbers and take photos.\n'
          '3. You can also use the REPORT INCIDENT page in this app to file an official report.';
    }

    if (text.contains('theft') ||
        text.contains('stolen') ||
        text.contains('robbery')) {
      return
          'For theft cases:\n\n1. Stay safe and do not confront suspects alone.\n'
          '2. Note down place, time and any CCTV / witnesses.\n'
          '3. File a complaint at the nearest police station or through REPORT INCIDENT in this app.\n'
          '4. Keep any evidence like photos, bills and serial numbers safe.';
    }

    if (text.contains('harass') ||
        text.contains('abuse') ||
        text.contains('threat')) {
      return
          'Harassment and threats are serious.\n\nIf you feel unsafe right now, use the SOS button or call 112.\n'
          'You can also describe the incident in REPORT INCIDENT so that police can officially register and follow up.';
    }

    if (text.contains('lost') || text.contains('missing')) {
      return
          'For lost items or missing documents:\n\n1. Try to remember the exact place and time you last had them.\n'
          '2. File a lost property report through REPORT INCIDENT or at the nearest police station.\n'
          '3. For important documents (Aadhaar, PAN, etc.), also inform the issuing authority.';
    }

    if (text.contains('traffic') ||
        text.contains('signal') ||
        text.contains('helmet') ||
        text.contains('fine')) {
      return
          'For traffic and road safety questions, Tamil Nadu Police follows the Motor Vehicles Act and state rules.\n'
          'You can also look at GUIDANCE AND RULES in the app for common traffic rules and penalties.\n'
          'If you see a serious traffic violation causing danger, you can report it through REPORT INCIDENT.';
    }

    return
        'Thank you for sharing your concern.\n\nYour message has been sent to the police for review. '
        'For emergencies, please use the SOS button or call 112.\n'
        'For detailed follow‑up, you can also use REPORT INCIDENT to file an official complaint.';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add(_ChatMessage(fromPolice: false, text: text));
      _messageController.clear();
    });

    await FirebaseService.submitQuery(
      userId: widget.phone,
      name: widget.userName,
      phone: widget.phone,
      type: 'Query',
      message: text,
    );

    setState(() {
      _isSending = false;
      _messages.add(_ChatMessage(
        fromPolice: true,
        text: _generateReply(text),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: const Text('Virtual Police Guide', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.fromPolice ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: msg.fromPolice
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe your problem here...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(Icons.send),
                    color: const Color(0xFF1E3A8A),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool fromPolice;
  final String text;

  const _ChatMessage({
    required this.fromPolice,
    required this.text,
  });
}


