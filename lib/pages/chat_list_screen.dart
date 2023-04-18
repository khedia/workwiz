import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:workwiz/widgets/chat_user_card.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  const ChatListScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final DatabaseReference _conversationRef = FirebaseDatabase.instance.ref().child('conversations');

  String getChatId(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  String getReceiverId(String chatId, String senderId) {
    final List<String> chatIdParts = chatId.split('_');
    if (chatIdParts.length == 2) {
      if (chatIdParts[0] == senderId) {
        return chatIdParts[1];
      } else if (chatIdParts[1] == senderId) {
        return chatIdParts[0];
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.canPop(context) ? Navigator.pop(context) : null;
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder(
        stream: _conversationRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final Map<dynamic, dynamic>? conversations =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
            final List<ChatUserCard> chatUserCards = [];
            if (conversations != null) {
              conversations.forEach((key, value) {
                if (value != null) {
                  if (key.contains(widget.currentUserId)) {
                    final String senderId = widget.currentUserId;
                    final String receiverId = getReceiverId(key, senderId);
                    final Map<dynamic, dynamic> chat = value as Map<dynamic, dynamic>;
                    final List<Map<dynamic, dynamic>> messages = chat.values.toList().cast<Map<dynamic, dynamic>>();
                    messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
                    final String lastMessage = messages.isNotEmpty ? messages.first['message'] : '';
                    final int timestamp = messages.isNotEmpty ? messages.first['timestamp'] : 0;
                    chatUserCards.add(
                      ChatUserCard(
                        senderId: senderId,
                        receiverId: receiverId,
                        lastMessage: lastMessage,
                        timestamp: timestamp,
                      ),
                    );
                  }
                  chatUserCards.sort((a, b) => (b).timestamp.compareTo((a).timestamp));
                }
              });
            }
            if (chatUserCards.isNotEmpty) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: chatUserCards.length,
                itemBuilder: (context, index) => chatUserCards[index],
              );
            }
          }
          return const Center(
            child: Text('No chats found.'),
          );
        },
      ),
    );
  }
}
