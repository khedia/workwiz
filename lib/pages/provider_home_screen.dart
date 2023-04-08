import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workwiz/Services/global_methods.dart';
import 'package:workwiz/pages/chat_list_screen.dart';

import 'package:workwiz/widgets/provider_bottom_nav_bar.dart';
import 'package:workwiz/Services/global_variables.dart';
import 'provider_review_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {

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
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white,),
            onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ChatListScreen(
                    currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  )));
            },
          ),
        ],
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

              final ratingCountMap = {
                5: ratings.where((rating) => rating == 5).length,
                4: ratings.where((rating) => rating == 4).length,
                3: ratings.where((rating) => rating == 3).length,
                2: ratings.where((rating) => rating == 2).length,
                1: ratings.where((rating) => rating == 1).length,
              };

              updateProviderRating(averageRating);

              return Padding(
                padding: const EdgeInsets.all(16.0),
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
                    ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final entry = ratingCountMap.entries.elementAt(index);
                        final starCount = entry.value;
                        final starRating = entry.key;
                        return ListTile(
                          title: Text(
                            '$starRating star',
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: totalRatings > 0
                              ? LinearProgressIndicator(
                            value: starCount / totalRatings,
                          )
                              : const LinearProgressIndicator(
                            value: 0,
                          ),
                          trailing: Text(
                            '$starCount',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 0);
                      },
                      itemCount: ratingCountMap.length,
                    ),
                  ],
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
