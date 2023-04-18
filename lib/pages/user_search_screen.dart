import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:workwiz/widgets/user_bottom_nav_bar.dart';
import 'package:workwiz/widgets/service_widget.dart';
import 'package:workwiz/Persistent/sort_options.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';

  String selectedSortOption = SortOptions.sortOptionsList[0];

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for a service provider...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _clearSearchQuery();
        },
      )
    ];
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery.toLowerCase();
    });
  }

  Future<double> getProviderRating(String providerId) async {
    double rating = 0;
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
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
      bottomNavigationBar: BottomNavigationBarForUser(indexNum: 1),
      appBar: AppBar(
        leading: Icon(Icons.search_outlined),
        title: _buildSearchField(),
        actions: _buildActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
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
            SizedBox(
              height: 12,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('services')
                    .orderBy(selectedSortOption == SortOptions.sortOptionsList[0] ?
                'avgRating' :
                selectedSortOption == SortOptions.sortOptionsList[1] ? 'servicePrice' : 'createdAt',
                    descending: selectedSortOption == SortOptions.sortOptionsList[0])
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.connectionState == ConnectionState.active) {
                    final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        filteredDocs = snapshot.data?.docs.where((doc) {
                      final String name =
                          doc.get('name').toString().toLowerCase();
                      final String email =
                          doc.get('email').toString().toLowerCase();
                      final String serviceTitle =
                          doc.get('serviceTitle').toString().toLowerCase();
                      final String serviceDescription =
                          doc.get('serviceDescription').toString().toLowerCase();
                      final String city =
                          doc.get('city').toString().toLowerCase();

                      return name.contains(searchQuery) ||
                          email.contains(searchQuery) ||
                          serviceTitle.contains(searchQuery) ||
                          serviceDescription.contains(searchQuery) ||
                          city.contains(searchQuery);
                    }).toList();
                    if (filteredDocs.isNotEmpty == true) {
                      return FutureBuilder(
                        future: Future.wait(filteredDocs
                            .map((doc) => getProviderRating(doc['uploadedBy']))),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<double>> ratingSnapshot) {
                          if (ratingSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return ListView.builder(
                              itemCount: filteredDocs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final double rating =
                                    ratingSnapshot.data?[index] ?? 0;
                                return ServiceWidget(
                                  serviceCategory: filteredDocs[index]
                                      ['serviceCategory'],
                                  serviceTitle: filteredDocs[index]
                                      ['serviceTitle'],
                                  serviceDescription: filteredDocs[index]
                                      ['serviceDescription'],
                                  serviceId: filteredDocs[index]['serviceId'],
                                  uploadedBy: filteredDocs[index]['uploadedBy'],
                                  userImage: filteredDocs[index]['userImage'],
                                  name: filteredDocs[index]['name'],
                                  email: filteredDocs[index]['email'],
                                  city: filteredDocs[index]['city'],
                                  phoneNumber: filteredDocs[index]['phoneNumber'],
                                  rating: rating,
                                );
                              },
                            );
                          }
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('There is no service available'),
                      );
                    }
                  }
                  return const Center(
                    child: Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
