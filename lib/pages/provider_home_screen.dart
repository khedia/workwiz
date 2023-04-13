import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workwiz/Services/global_methods.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:workwiz/widgets/chat_user_card.dart';

import 'package:workwiz/widgets/provider_bottom_nav_bar.dart';
import 'package:workwiz/Services/global_variables.dart';
import 'provider_review_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {

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

  double averageRating = 23.0;
  num totalRatings = 0;

  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('providers').doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
      city = userDoc.get('city');
      phoneNumber = userDoc.get('phoneNumber');
    });
  }

  void updateProviderRating(double avgRating) {
    FirebaseFirestore.instance.collection('providers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'avgRating': avgRating})
        .catchError((error) => GlobalMethod.showErrorDialog(error: error.toString(), ctx: context));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBarForProvider(indexNum: 0),
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('name', isEqualTo: name)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data?.docs.isNotEmpty == true) {
              final documents = snapshot.data!.docs;
              final comments = <dynamic>[];
              documents.forEach((doc) {
                final serviceComments = doc['serviceComments'] as List<dynamic>;
                if (serviceComments.isNotEmpty) {
                  comments.addAll(serviceComments);
                }
              });

              final ratings = comments
                  .map((comment) => comment['rating'])
                  .toList();
              final ratingSum = ratings.fold<double>(0.0, (a, b) => a + b.toDouble());
              double averageRating = ratings.isNotEmpty ? ratingSum / ratings.length.toDouble() : 0.0;

              updateProviderRating(averageRating);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Your Current Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 125,
                        height: 125,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                              vertical: 12.0,
                            ),
                          ),
                          child: const Text(
                            'Read all reviews',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                          child: StreamBuilder(
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
                                      if (key.contains(FirebaseAuth.instance.currentUser!.uid)) {
                                        final String senderId = FirebaseAuth.instance.currentUser!.uid;
                                        final String receiverId = getReceiverId(key, senderId);
                                        chatUserCards.add(
                                          ChatUserCard(
                                            senderId: senderId,
                                            receiverId: receiverId,
                                          ),
                                        );
                                      }
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
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'There are no ratings available',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            }
          }
          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          );
        },
      ),
    );
  }
}
