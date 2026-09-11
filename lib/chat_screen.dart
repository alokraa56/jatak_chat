import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('chat').add({
      'text': _messageController.text.trim(),
      'createdAt': Timestamp.now(),
      'userId': user?.uid,
      'userEmail': user?.email,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jatak Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chatDocs = chatSnapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text(chatDocs[index]['userEmail'] ?? ''),
                    subtitle: Text(chatDocs[index]['text']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Send a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
