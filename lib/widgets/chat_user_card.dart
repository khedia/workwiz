import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:workwiz/pages/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const ChatUserCard({Key? key,
    required this.senderId,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  String? receiverName;
  String? receiverImageUrl;

  void getReceiverData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('providers')
        .doc(widget.receiverId)
        .get();

    // ignore: unnecessary_null_comparison
    if (userDoc == null) {
      return;
    } else {
      setState(() {
        receiverName = userDoc.get('name');
        receiverImageUrl = userDoc.get('userImage');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReceiverData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
            receiverId: widget.receiverId,
            senderId: widget.senderId,
          )));
        },
        child: ListTile(
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              border: Border.all(
                width: 3,
                color: Colors.grey,
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  receiverImageUrl == null
                      ? 'https://static.thenounproject.com/png/5034901-200.png'
                      : receiverImageUrl!,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            receiverName == null ? '' : receiverName!,
          ),
          subtitle: const Text('Last user message', maxLines: 1),
          trailing: const Text(
            '12:00 PM',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
