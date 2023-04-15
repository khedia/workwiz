import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:workwiz/widgets/user_bottom_nav_bar.dart';
import 'package:workwiz/widgets/service_widget.dart';
import 'package:workwiz/Persistent/sort_options.dart';

class UserCategoryScreen extends StatefulWidget {

  final String categoryName;
  const UserCategoryScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<UserCategoryScreen> createState() => _UserCategoryScreenState();
}

class _UserCategoryScreenState extends State<UserCategoryScreen> {

  String selectedSortOption = SortOptions.sortOptionsList[0];

  Future<double> getProviderRating(String providerId) async {
    double rating = 0;
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .get();
      if (snapshot.exists) {
        rating = snapshot.data()!['avgRating'] ?? 0;
      }
    } catch (error) {
      print('Error getting provider rating: $error');
    }
    return rating;
  }

  void _showSortOptionsDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Sort according to',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          content: SizedBox(
            width: size.width * 0.9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: SortOptions.sortOptionsList.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedSortOption = SortOptions.sortOptionsList[index];
                    });
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          SortOptions.sortOptionsList[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForUser(indexNum: 0),
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.canPop(context) ? Navigator.pop(context) : null;
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showSortOptionsDialog(size: size);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  'Sort',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Filter',
                style: TextStyle(
                  color: Colors.black54
                ),),
              ),
            ],
          ),
      SizedBox(height: 10,),
      Expanded(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('services')
              .where('serviceCategory', isEqualTo: widget.categoryName)
              .orderBy(selectedSortOption == SortOptions.sortOptionsList[0] ?
          'avgRating' :
          selectedSortOption == SortOptions.sortOptionsList[1] ? 'servicePrice' : 'createdAt',
              descending: selectedSortOption == SortOptions.sortOptionsList[0])
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData && snapshot.data?.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FutureBuilder(
                      future: getProviderRating(snapshot.data?.docs[index]['uploadedBy']),
                      builder: (BuildContext context, AsyncSnapshot<double> ratingSnapshot) {
                        if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else {
                          final double rating = ratingSnapshot.data ?? 0;
                          return ServiceWidget(
                            serviceCategory:
                            snapshot.data?.docs[index]['serviceCategory'],
                            serviceTitle: snapshot.data?.docs[index]['serviceTitle'],
                            serviceDescription:
                            snapshot.data?.docs[index]['serviceDescription'],
                            serviceId: snapshot.data?.docs[index]['serviceId'],
                            uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                            userImage: snapshot.data?.docs[index]['userImage'],
                            name: snapshot.data?.docs[index]['name'],
                            email: snapshot.data?.docs[index]['email'],
                            city: snapshot.data?.docs[index]['city'],
                            phoneNumber: snapshot.data?.docs[index]['phoneNumber'],
                            rating: rating,
                          );
                        }
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('There is no service available in this category'),
                );
              }
            }
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
        ),
      ),
      ],
      ),
    );
  }
}