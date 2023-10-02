import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Color bubbleColor;
  final Color messageColor;
  final String timeStamp;
  final double? width;
  final BoxConstraints constraints;
  ChatBubble({
    Key? key,
    required this.message,
    required this.bubbleColor,
    required this.messageColor,
    required this.timeStamp,
    this.width,
  })  : constraints = BoxConstraints(
          minWidth: width ?? 120, // Use the specified width or default to 120
          maxWidth: 250, // Adjust the maximum width as needed
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: bubbleColor,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20.0,
              offset: Offset(0.0,
                  15.0), // Change the Y-axis offset to control the shadow position
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 16,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeStamp,
                  style: TextStyle(
                    color: messageColor,
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Icons.check,
                  size: 20,
                  color: messageColor,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
