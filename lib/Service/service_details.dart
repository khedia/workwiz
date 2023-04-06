import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workwiz/pages/book_now_screen.dart';
import 'package:workwiz/widgets/review_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import '../Services/global_variables.dart';
import 'package:workwiz/pages/chat_screen.dart';

class ServiceDetails extends StatefulWidget {
  final String uploadedBy;
  final String serviceId;
  final double rating;

  const ServiceDetails({
    super.key,
    required this.uploadedBy,
    required this.serviceId,
    required this.rating,
  });

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isCommenting = false;
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
  bool showReview = false;
  double _rating = 0;

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
        serviceCategory = serviceDatabase.get('serviceCategory');
        serviceDescription = serviceDatabase.get('serviceDescription');
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

  Widget _contactBy
      ({
    required Color color, required Function fct, required IconData icon
  })
  {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }

  void _mailTo() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Write subject here, Please&body=Hello, please write details here',
    );
    final url = params.toString();
    launchUrlString(url);
  }

  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  void _openChatScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
      receiverId: widget.uploadedBy,
      senderId: FirebaseAuth.instance.currentUser!.uid,
    )));
  }

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    getServiceData();
    getMyData();
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
            'Service Details',
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
                        Padding(
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
                        const SizedBox(
                          height: 20,
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
                                    Text(
                                      'Rating: ${widget.rating}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Price:  Rs',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              servicePrice == null ? '' : servicePrice!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
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
                        const Text(
                          'Service Description',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          serviceDescription == null ? '' : serviceDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        dividerWidget(),
                        const Text(
                          'Contact Details',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'email: ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              email == null ? '' : email!,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'phone no: ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              phoneNumber == null ? '' : phoneNumber!,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _contactBy(
                              color: Colors.green,
                              fct: () {
                                _openChatScreen();
                              },
                              icon: FontAwesome.chat,
                            ),
                            _contactBy(
                              color: Colors.black,
                              fct: () {
                                _mailTo();
                              },
                              icon: Icons.mail_outline,
                            ),
                            _contactBy(
                              color: Colors.blue,
                              fct: () {
                                _callPhoneNumber();
                              },
                              icon: FontAwesome.phone,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Center(
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        BookNowScreen(
                            serviceTitle: serviceTitle ?? '',
                            providerName: authorName ?? '',
                            providerEmail: email ?? '',
                            providerCity: city ?? '',
                            providerId : providerId ?? '',
                            providerImage: userImageUrl ?? '',
                            servicePrice: servicePrice ?? '',
                            providerNumber : phoneNumber ?? '',
                            serviceId: widget.serviceId,
                        )
                    ));
                  },
                  color: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white70,
                  //change card color to white with opacity
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 500,
                          ),
                          child: _isCommenting
                              ? Column(
                                children: [
                                  RatingBar.builder(
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
                                  const SizedBox(height: 8),
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
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
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
                                              _rating = 0;
                                              setState(() {
                                                showReview = true;
                                              });
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
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                              showReview = false;
                                            });
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.cyan,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                                ],
                              )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isCommenting = !_isCommenting;
                                    showReview = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.add_comment,
                                  color: Color(0xff8FBFE0),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    showReview = !showReview;
                                  });
                                },
                                icon: const Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Color(0xff8FBFE0),
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showReview == false)
                          Container()
                        else
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('services')
                                  .doc(widget.serviceId)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  if (snapshot.data!['serviceComments'].length == 0) {
                                    return const Center(
                                      child: Text(
                                        'No reviews available',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return ReviewWidget(
                                          commentId: snapshot
                                              .data!['serviceComments'][index]['commentId'],
                                          userId: snapshot
                                              .data!['serviceComments'][index]['userId'],
                                          name: snapshot
                                              .data!['serviceComments'][index]['name'],
                                          commentBody: snapshot
                                              .data!['serviceComments'][index]['commentBody'],
                                          userImageUrl: snapshot
                                              .data!['serviceComments'][index]['userImageUrl'],
                                          rating: snapshot.data!['serviceComments'][index]['rating'].toDouble(),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const Divider(
                                          thickness: 1,
                                          color: Colors.grey,
                                        );
                                      },
                                      itemCount:
                                      snapshot.data!['serviceComments'].length,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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