import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/view/chat_module/message_text_field.dart';
import 'package:women_safety_app/view/chat_module/single_message.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String friendId;
  final String friendName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.friendId,
    required this.friendName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? type;
  String? myName;

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  // Fetch current user info
  Future<void> getStatus() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

    if (snapshot.exists && mounted) {
      setState(() {
        type = snapshot.data()?['type'] ?? '';
        myName = snapshot.data()?['name'] ?? '';
      });
    }
  }

  // Safe SnackBar
  void showSafeSnackBar(String msg) {
    if (!mounted) return; // Check if widget is still in tree
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: pink,
        title: Text(
          widget.friendName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentUserId)
                  .collection('messages')
                  .doc(widget.friendId)
                  .collection('chats')
                  .orderBy('date', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        type == "parent"
                            ? "TALK WITH CHILD"
                            : "TALK WITH PARENT",
                        style: const TextStyle(fontSize: 30),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index];
                      bool isMe = data['senderId'] == widget.currentUserId;

                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) async {
                          try {
                            // Delete message from current user
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.currentUserId)
                                .collection('messages')
                                .doc(widget.friendId)
                                .collection('chats')
                                .doc(data.id)
                                .delete();

                            // Delete message from friend
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.friendId)
                                .collection('messages')
                                .doc(widget.currentUserId)
                                .collection('chats')
                                .doc(data.id)
                                .delete();

                            // Show snack bar safely
                            showSafeSnackBar('Message deleted successfully');
                          } catch (e) {
                            showSafeSnackBar('Failed to delete message');
                          }
                        },
                        child: SingleMessage(
                          message: data['message'],
                          date: data['date'],
                          isMe: isMe,
                          friendName: widget.friendName,
                          myName: myName,
                          type: data['type'],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          MessageTextField(
            currentId: widget.currentUserId,
            friendId: widget.friendId,
          ),
        ],
      ),
    );
  }
}
