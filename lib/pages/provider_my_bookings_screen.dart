// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:workwiz/widgets/provider_bottom_nav_bar.dart';

import '../Service/provider_booking_details_screen.dart';

class ProviderMyBookingsScreen extends StatefulWidget {
  const ProviderMyBookingsScreen({Key? key}) : super(key: key);

  @override
  _ProviderMyBookingsScreenState createState() => _ProviderMyBookingsScreenState();
}

class _ProviderMyBookingsScreenState extends State<ProviderMyBookingsScreen> {
  late String _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBarForProvider(indexNum: 2),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('providerId', isEqualTo: _userId)
            .orderBy('bookingDate', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data?.docs.isNotEmpty == true) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final bookingData = snapshot.data!.docs[index].data();
                    final jobStatus = bookingData['bookingState'] ?? '';
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          bookingData['serviceTitle'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Booked by: ${bookingData['userName']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Booked on: ${bookingData['bookingDate']} at ${bookingData['bookingTime']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bookingData['bookingState'],
                              style: TextStyle(
                                fontSize: 14,
                                color: jobStatus == 'Confirmation Pending'
                                    ? Colors.orange
                                    : jobStatus == 'Completed'
                                    ? Colors.green
                                    : jobStatus == 'Booking Accepted'
                                    ? Colors.green
                                    : jobStatus == 'Booking Cancelled'
                                    ? Colors.red
                                    : Colors.cyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderBookingDetailsScreen(bookingId: bookingData['bookingId'],)));
                        },
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                child: Text('You have no bookings yet.'),
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
