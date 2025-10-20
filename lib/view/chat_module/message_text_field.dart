import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/constants.dart';

class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;

  const MessageTextField({
    super.key,
    required this.currentId,
    required this.friendId,
  });

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final TextEditingController _controller = TextEditingController();

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final chatData = {
      'senderId': widget.currentId,
      'receiverId': widget.friendId,
      'message': message,
      'type': 'text',
      'date': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .add(chatData);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .collection('messages')
          .doc(widget.currentId)
          .collection('chats')
          .add(chatData);
    } catch (e) {
      log("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: grey300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                cursorColor: pink,
                decoration: const InputDecoration(
                  hintText: "  Type your message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () async {
                  final msg = _controller.text.trim();
                  if (msg.isNotEmpty) {
                    await sendMessage(msg);
                    _controller.clear();
                  }
                },
                child: const Icon(
                  Icons.send,
                  color: pink,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
