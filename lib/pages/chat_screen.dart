import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:workwiz/widgets/message_widget.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;

  ChatScreen({required this.senderId, required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final DatabaseReference _conversationRef =
  FirebaseDatabase.instance.reference().child('conversations');

  String getChatId(String senderId, String receiverId) {
    // Generate a unique chat ID by concatenating the two user IDs and sorting them alphabetically
    List<String> ids = [senderId, receiverId];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId(widget.senderId, widget.receiverId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _conversationRef.child(chatId).orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                print(snapshot.data?.snapshot.value);
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic>? messages =
                  snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                  List<Widget> messageWidgets = [];
                  if (messages != null) {
                    messages.entries.forEach((entry) {
                      messageWidgets.add(
                        Message(
                          id: entry.key,
                          senderId: entry.value['senderId'],
                          receiverId: entry.value['receiverId'],
                          message: entry.value['message'],
                          timestamp: entry.value['timestamp'],
                        ),
                      );
                    });
                    messageWidgets.sort((a, b) =>
                        (b as Message).timestamp.compareTo((a as Message).timestamp));
                  }
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    reverse: true,
                    children: messageWidgets,
                  );
                } else {
                  return Center(
                    child: Text('No messages yet'),
                  );
                }
              },
            )
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: IconButton(
                    onPressed: () {
                      String message = _textController.text.trim();
                      if (message.isNotEmpty) {
                        String senderId = widget.senderId;
                        String receiverId = widget.receiverId;
                        int timestamp = int.parse(DateTime.now().millisecondsSinceEpoch.toString());
                        DatabaseReference messageRef =
                        _conversationRef.child(chatId).push();
                        messageRef.set({
                          'senderId': senderId,
                          'receiverId': receiverId,
                          'message': message,
                          'timestamp': timestamp,
                        });

                        // Clear the message text field
                        _textController.clear();
                      }
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
