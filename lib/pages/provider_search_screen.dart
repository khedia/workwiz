// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:workwiz/pages/provider_home_screen.dart';
//
// import 'package:workwiz/widgets/provider_bottom_nav_bar.dart';
// import 'package:workwiz/widgets/service_widget.dart';
//
// class ProviderSearchScreen extends StatefulWidget {
//   const ProviderSearchScreen({super.key});
//
//   @override
//   State<ProviderSearchScreen> createState() => _ProviderSearchScreenState();
// }
//
// class _ProviderSearchScreenState extends State<ProviderSearchScreen> {
//
//   final TextEditingController _searchQueryController = TextEditingController();
//   String searchQuery = '';
//
//   Widget _buildSearchField() {
//     return TextField(
//       controller: _searchQueryController,
//       autocorrect: true,
//       decoration: const InputDecoration(
//         hintText: 'Search for a service provider...',
//         border: InputBorder.none,
//         hintStyle: TextStyle(color: Colors.white),
//       ),
//       style: const TextStyle(color: Colors.white, fontSize: 16.0),
//       onChanged: (query) => updateSearchQuery(query),
//     );
//   }
//
//   List<Widget> _buildActions() {
//     return <Widget>[
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           _clearSearchQuery();
//           },
//       )
//     ];
//   }
//
//   void _clearSearchQuery() {
//     setState(() {
//       _searchQueryController.clear();
//       updateSearchQuery('');
//     });
//   }
//
//   void updateSearchQuery(String newQuery) {
//     setState(() {
//       searchQuery = newQuery.toLowerCase();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationBarForProvider(indexNum: 1),
//       appBar: AppBar(
//         title: _buildSearchField(),
//         actions: _buildActions(),
//       ),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance
//             .collection('services')
//             .snapshots(),
//         builder: (context, AsyncSnapshot snapshot) {
//           if(snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(),);
//           } else if(snapshot.connectionState == ConnectionState.active) {
//             final List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredDocs = snapshot.data?.docs.where((doc) {
//               final String name = doc.get('name').toString().toLowerCase();
//               final String email = doc.get('email').toString().toLowerCase();
//               final String serviceTitle = doc.get('serviceTitle').toString().toLowerCase();
//               final String serviceDescription = doc.get('serviceDescription').toString().toLowerCase();
//               final String city = doc.get('city').toString().toLowerCase();
//
//               return name.contains(searchQuery) ||
//                   email.contains(searchQuery) ||
//                   serviceTitle.contains(searchQuery) ||
//                   serviceDescription.contains(searchQuery) ||
//                   city.contains(searchQuery);
//             }).toList();
//             if(filteredDocs.isNotEmpty == true) {
//               return ListView.builder(
//                   itemCount: filteredDocs.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return ServiceWidget(
//                       serviceCategory: filteredDocs[index]['serviceCategory'],
//                       serviceTitle: filteredDocs[index]['serviceTitle'],
//                       serviceDescription: filteredDocs[index]['serviceDescription'],
//                       serviceId: filteredDocs[index]['serviceId'],
//                       uploadedBy: filteredDocs[index]['uploadedBy'],
//                       userImage: filteredDocs[index]['userImage'],
//                       name: filteredDocs[index]['name'],
//                       email: filteredDocs[index]['email'],
//                       city: filteredDocs[index]['city'],
//                       phoneNumber: filteredDocs[index]['phoneNumber'],
//                     );
//                 }
//               );
//             } else {
//               return const Center(
//                 child: Text('There is no service available'),
//               );
//             }
//           }
//           return const Center(
//             child: Text(
//               'Something went wrong',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 30.0,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
