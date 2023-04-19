import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../Services/global_variables.dart';
import 'package:workwiz/Services/global_methods.dart';

class RatingScreen extends StatefulWidget {
  final String uploadedBy;
  final String serviceId;
  final String bookingId;

  const RatingScreen({
    super.key,
    required this.uploadedBy,
    required this.serviceId,
    required this.bookingId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final TextEditingController _reviewController = TextEditingController();
  String? authorName;
  String? userImageUrl;
  String? serviceCategory;
  String? providerId;
  String? serviceDescription;
  String? serviceTitle;
  String? city = '';
  String? email = '';
  String? phoneNumber = '';
  String? servicePrice;
  double _rating = 1;

  bool _isLoading = false;

  void getServiceData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('providers')
        .doc(widget.uploadedBy)
        .get();

    // ignore: unnecessary_null_comparison
    if (userDoc == null) {
      return;
    } else {
      setState(() {
        _isLoading = true;
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }

    final DocumentSnapshot serviceDatabase = await FirebaseFirestore.instance
        .collection('services')
        .doc(widget.serviceId)
        .get();
    // ignore: unnecessary_null_comparison
    if (serviceDatabase == null) {
      return;
    } else {
      setState(() {
        serviceTitle = serviceDatabase.get('serviceTitle');
        providerId = serviceDatabase.get('uploadedBy');
        city = serviceDatabase.get('city');
        email = serviceDatabase.get('email');
        servicePrice = serviceDatabase.get('servicePrice');
        phoneNumber = serviceDatabase.get('phoneNumber');

        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    getServiceData();
    getMyData();
  }

  void updateReviewStatus() {
    FirebaseFirestore.instance.collection('bookings')
        .doc(widget.bookingId)
        .update({'reviewAdded': 'true'})
        .catchError((error) => GlobalMethod.showErrorDialog(error: error.toString(), ctx: context));
    Navigator.pop(context);
  }

  Widget dividerWidget() {
    return Column(
      children: const [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(
            'Rate & Review',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white70,
                  //change card color to white with opacity
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              serviceTitle == null ? '' : serviceTitle!,
                              maxLines: 3,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
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
                                    userImageUrl == null
                                        ? 'https://static.thenounproject.com/png/5034901-200.png'
                                        : userImageUrl!,
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
                                  authorName == null ? '' : authorName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      city!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        dividerWidget(),
                        const SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.zero,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.cyan,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 3,
                              child: TextField(
                                controller: _reviewController,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                maxLength: 200,
                                keyboardType: TextInputType.text,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Theme
                                      .of(context)
                                      .scaffoldBackgroundColor,
                                  enabledBorder:
                                  const UnderlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder:
                                  const OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.cyan),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8),
                          child: Center(
                            child: MaterialButton(
                              onPressed: () async {
                                final generatedId =
                                const Uuid().v4();
                                await FirebaseFirestore.instance
                                    .collection('services')
                                    .doc(widget.serviceId)
                                    .update({
                                  'serviceComments':
                                  FieldValue.arrayUnion([
                                    {
                                      'userId': FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .uid,
                                      'commentId': generatedId,
                                      'name': name,
                                      'rating': _rating,
                                      'userImageUrl':
                                      userImage,
                                      'commentBody':
                                      _reviewController
                                          .text,
                                      'time': Timestamp.now(),
                                    }
                                  ]),
                                });
                                await Fluttertoast.showToast(
                                  msg:
                                  'Your review has been added',
                                  toastLength:
                                  Toast.LENGTH_LONG,
                                  backgroundColor: Colors.grey,
                                  fontSize: 18,
                                );
                                _reviewController.clear();
                                _rating = 1;
                                updateReviewStatus();
                              },
                              color: Colors.cyan,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Post',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
      city = userDoc.get('city');
      phoneNumber = userDoc.get('phoneNumber');
    });
  }
}