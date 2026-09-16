import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HostGuestChatScreen extends StatefulWidget {
  const HostGuestChatScreen({Key? key}) : super(key: key);

  @override
  State<HostGuestChatScreen> createState() => _HostGuestChatScreenState();
}

class _HostGuestChatScreenState extends State<HostGuestChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello Manohar! Is early check-in available at 11 AM?', 'isMe': false, 'time': '10:05 am'},
    {'text': 'Yes, Anjali! Early check-in is available.', 'isMe': true, 'time': '10:05 am'},
    {'text': 'Thank you! Looking forward to the stay.', 'isMe': false, 'time': '10:05 am'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': '10:06 am',
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text('Anjali Sharma', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Online', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bottom Background Graphic
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/image 31.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20.0),
                itemCount: _messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['isMe'] as bool;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EDF7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 18),
                          ),
                        Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary : const Color(0xFFF3EDF7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                msg['text'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isMe ? Colors.white : AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(msg['time'], style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        if (isMe)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EDF7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 18),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Message Input Container matching 70.png
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF7F5FE),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}
