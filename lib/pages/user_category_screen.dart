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

  @override
  Widget build(BuildContext context) {
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
                  setState(() {
                    selectedSortOption = SortOptions.sortOptionsList[0];
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: selectedSortOption == SortOptions.sortOptionsList[0]
                      ? Colors.black38
                      : Colors.white30,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  'Rating',
                  style: TextStyle(
                    color: selectedSortOption == SortOptions.sortOptionsList[0]
                        ? Colors.white
                        : Colors.black54,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSortOption = SortOptions.sortOptionsList[1];
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: selectedSortOption == SortOptions.sortOptionsList[1]
                      ? Colors.black38
                      : Colors.white30,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  'Price',
                  style: TextStyle(
                      color: selectedSortOption == SortOptions.sortOptionsList[1]
                          ? Colors.white
                          : Colors.black54,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSortOption = SortOptions.sortOptionsList[2];
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: selectedSortOption == SortOptions.sortOptionsList[2]
                      ? Colors.black38
                      : Colors.white30,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  'Oldest First',
                  style: TextStyle(
                    color: selectedSortOption == SortOptions.sortOptionsList[2]
                        ? Colors.white
                        : Colors.black54,
                  ),
                ),
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