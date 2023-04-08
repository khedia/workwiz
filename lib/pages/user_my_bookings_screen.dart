// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workwiz/widgets/user_bottom_nav_bar.dart';

import 'package:workwiz/Service/user_booking_details_screen.dart';

class UserMyBookingsScreen extends StatefulWidget {
  const UserMyBookingsScreen({Key? key}) : super(key: key);

  @override
  _UserMyBookingsScreenState createState() => _UserMyBookingsScreenState();
}

class _UserMyBookingsScreenState extends State<UserMyBookingsScreen> {
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
      bottomNavigationBar: BottomNavigationBarForUser(indexNum: 2),
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('bookedBy', isEqualTo: _userId)
              .orderBy('bookedAt', descending: true)
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
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
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
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                    UserBookingDetailsScreen(bookingId: bookingData['bookingId'],)));
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
      ),
    );
  }
}
