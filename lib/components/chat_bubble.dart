import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Color bubbleColor;
  final Color messageColor;
  const ChatBubble({super.key, required this.message,
  required this.bubbleColor, required this.messageColor});

  @override
  Widget build(BuildContext context) {
    return Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: bubbleColor,
    boxShadow: const <BoxShadow> [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 20.0,
        offset: Offset(0.0, 15.0), // Change the Y-axis offset to control the shadow position
      ),
    ],
  ),
  child: Text(
    message,
    style: TextStyle(
      color: messageColor,
      fontSize: 16,
    ),
  ),
);

  }
}
