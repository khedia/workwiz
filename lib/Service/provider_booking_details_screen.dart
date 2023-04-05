// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:workwiz/Services/global_methods.dart';

class ProviderBookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const ProviderBookingDetailsScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  _ProviderBookingDetailsScreenState createState() =>
      _ProviderBookingDetailsScreenState();
}

class _ProviderBookingDetailsScreenState
    extends State<ProviderBookingDetailsScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _bookingStream;
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _bookingStream = _firestore.collection('bookings')
        .doc(widget.bookingId)
        .snapshots();
  }

  void updateJobStatus(String bookingId, String newStatus) {
    FirebaseFirestore.instance.collection('bookings')
        .doc(bookingId)
        .update({'bookingState': newStatus})
        .catchError((error) => GlobalMethod.showErrorDialog(error: error.toString(), ctx: context));
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff8FBFE0),
            Color(0xffC2E8E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Booking Details'),
            centerTitle: true,
          ),
          body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _bookingStream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.active) {
                  final bookingData = snapshot.data?.data() as Map<String,
                      dynamic>?;

                  if (bookingData == null) {
                    return const Center(
                      child: Text(
                        'Booking not found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    );
                  }

                  final serviceTitle = bookingData['serviceTitle'] ?? '';
                  final date = bookingData['bookingDate'] ?? '';
                  final time = bookingData['bookingTime'] ?? '';
                  final address = bookingData['userAddress'] ?? '';
                  final notes = bookingData['bookingNotes'] ?? '';
                  final jobStatus = bookingData['bookingState'] ?? '';
                  final userName = bookingData['userName'] ?? '';
                  final userNumber = bookingData['userNumber'] ?? '';
                  final userImage = bookingData['userImage'] ?? '';
                  final servicePrice = bookingData['servicePrice'] ?? '';

                  return SingleChildScrollView(
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white70,
                      margin: const EdgeInsets.all(25),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 18),
                            Text(
                              serviceTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.grey,
                                    ),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        userImage == null
                                            ? 'https://static.thenounproject.com/png/5034901-200.png'
                                            : userImage!,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName == null ? '' : userName!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Contact:  $userNumber',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 30,),
                            Text(
                              'Date:  $date',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Time:  $time',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Address:  $address',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Notes:  $notes',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Service Price:  Rs $servicePrice',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12,),
                            Row(
                              children: [
                                const Text(
                                  'Job Status: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  jobStatus,
                                  style: TextStyle(
                                    fontSize: 18,
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
                            const SizedBox(height: 36),
                            if (jobStatus == 'Confirmation Pending')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateJobStatus(widget.bookingId, 'Booking Accepted');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                      shadowColor: Colors.grey.withOpacity(0.5),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Accept Job'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      updateJobStatus(widget.bookingId, 'Booking Cancelled');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                      shadowColor: Colors.grey.withOpacity(0.5),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Reject Job'),
                                  ),
                                ],
                              ),
                            if (jobStatus == 'Booking Accepted')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateJobStatus(widget.bookingId, 'Service in Progress');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                      shadowColor: Colors.grey.withOpacity(0.5),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Start Job'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      updateJobStatus(widget.bookingId, 'Booking Cancelled');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                      shadowColor: Colors.grey.withOpacity(0.5),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Cancel Job'),
                                  ),
                                ],
                              ),
                            if (jobStatus == 'Service in Progress')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateJobStatus(widget.bookingId, 'Completed');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                      shadowColor: Colors.grey.withOpacity(0.5),
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('End Service'),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
          )
      ),
    );
  }
}
