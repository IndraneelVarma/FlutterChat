import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.lightBlue),
      child: Text(
        message,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
