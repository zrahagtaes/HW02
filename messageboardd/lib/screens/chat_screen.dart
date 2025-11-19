import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String boardId;
  final String boardName;
  final String displayName;

  const ChatScreen({
    super.key,
    required this.boardId,
    required this.boardName,
    required this.displayName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  Future<void> _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('boards')
        .doc(widget.boardId)
        .collection('messages')
        .add({
      'text': _msgCtrl.text.trim(),
      'userName': widget.displayName,
      'createdAt': DateTime.now().toIso8601String(),
    });

    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('boards')
        .doc(widget.boardId)
        .collection('messages')
        .orderBy('createdAt');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                    docs[index].data() as Map<String, dynamic>;
                    final date =
                    DateTime.parse(data['createdAt'] as String);

                    return ListTile(
                      title: Text(data['text'] as String),
                      subtitle: Text(
                          '${data['userName']} • ${date.toLocal()}'),
                    );
                  },
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
                    controller: _msgCtrl,
                    decoration:
                    const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
