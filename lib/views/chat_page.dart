import 'package:flutter/material.dart';
import 'package:safe_chat_app/services/auth_service.dart';
import 'package:safe_chat_app/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverId;
  const ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  List<Map<String, dynamic>> _messages = [];

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final messageText = _messageController.text.trim();
      try {
        await _chatService.sendMessage(widget.recieverId, messageText);
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  void _fetchMessages() {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) return;

    _chatService.getMessages(currentUserId, widget.recieverId).listen((
      snapshot,
    ) {
      setState(() {
        _messages = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return {'text': '', 'isSender': false};

          final text = data['message'] ?? ''; // Use 'message' field for content
          final senderId = data['senderId'] ?? '';

          return {'text': text, 'isSender': senderId == currentUserId};
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.recieverEmail,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for (var message in _messages)
                    BubbleNormal(
                      text: message['text'],
                      isSender: message['isSender'],
                      color: message['isSender']
                          ? const Color(0xFFE8E8EE)
                          : const Color(0xFF1B97F3),
                      tail: true,
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: message['isSender']
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          MessageBar(
            controller: _messageController,
            onSend: (message) => sendMessage(),
            actions: [],
          ),
        ],
      ),
    );
  }
}

/// Simple chat bubble implementation used by this page.
class BubbleNormal extends StatelessWidget {
  final String text;
  final bool isSender;
  final Color color;
  final bool tail;
  final TextStyle? textStyle;

  const BubbleNormal({
    super.key,
    required this.text,
    required this.isSender,
    required this.color,
    this.tail = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;
    final radius = Radius.circular(12);
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: isSender ? radius : Radius.zero,
            bottomRight: isSender ? Radius.zero : radius,
          ),
        ),
        child: Text(
          text,
          style: textStyle ?? const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Simple date chip used in the conversation.
class DateChip extends StatelessWidget {
  final DateTime date;
  const DateChip({super.key, required this.date});

  String _formatDate(DateTime d) {
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Chip(
          backgroundColor: Colors.grey.shade300,
          label: Text(
            _formatDate(date),
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

/// Minimal message bar with actions and a send button.
class MessageBar extends StatefulWidget {
  final ValueChanged<String>? onSend;
  final List<Widget>? actions;
  final TextEditingController controller;

  const MessageBar({
    super.key,
    this.onSend,
    this.actions,
    required this.controller,
  });

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    widget.controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: Colors.white,
          child: Row(
            children: [
              if (widget.actions != null) ...widget.actions!,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _handleSend,
                      ),
                    ],
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
