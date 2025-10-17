import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              child: Icon(
                Icons.person,
                color: Colors.white,
              ), // Default icon if no image
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('David', style: TextStyle(color: Colors.white)),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                BubbleNormal(
                  text: 'Hello, There!',
                  isSender: false,
                  color: const Color(0xFF1B97F3),
                  tail: true,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                BubbleNormal(
                  text: 'General Kenobi!',
                  isSender: true,
                  color: const Color(0xFFE8E8EE),
                  tail: true,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                DateChip(date: DateTime(now.year, now.month, now.day - 2)),
                BubbleNormal(
                  text: 'bubble normal without tail',
                  isSender: false,
                  color: const Color(0xFF1B97F3),
                  tail: false,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                BubbleNormal(
                  text: 'bubble normal without tail',
                  isSender: true,
                  color: const Color(0xFFE8E8EE),
                  tail: false,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          MessageBar(onSend: (message) => print(message), actions: []),
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

  const MessageBar({super.key, this.onSend, this.actions});

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
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
                          controller: _controller,
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
