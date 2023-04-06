import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Message extends StatelessWidget {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final int timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isSentByCurrentUser =
        senderId == FirebaseAuth.instance.currentUser?.uid;
    final messageBox = Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSentByCurrentUser
              ? [Color(0xff667EEA), Color(0xff64B6FF)]
              : [Colors.grey[200]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            offset: Offset(0.0, 1.0),
            blurRadius: 2.0,
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomLeft:
          isSentByCurrentUser ? Radius.circular(23) : Radius.circular(0),
          bottomRight:
          isSentByCurrentUser ? Radius.circular(0) : Radius.circular(23),
        ),
      ),
      child: Column(
        crossAxisAlignment: isSentByCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
                fontSize: 16.0,
                color: isSentByCurrentUser ? Colors.white : Colors.black),
          ),
          SizedBox(height: 5.0),
          Text(
            DateFormat('dd MMM kk:mm')
                .format(DateTime.fromMillisecondsSinceEpoch(timestamp)),
            style: TextStyle(fontSize: 10.0, color: Colors.grey.shade200),
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
      child: Row(
        mainAxisAlignment: isSentByCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          messageBox,
        ],
      ),
    );
  }
}

class MessagesList extends StatelessWidget {
  final List<Message> messages;

  MessagesList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 10.0);
      },
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        return messages[index];
      },
    );
  }
}
