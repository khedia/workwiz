import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:workwiz/Services/global_methods.dart';
import 'package:workwiz/Services/global_variables.dart';

class BookNowScreen extends StatefulWidget {
  final String serviceTitle;
  final String providerName;
  final String providerEmail;
  final String providerCity;
  final String providerId;
  final String providerImage;
  final String servicePrice;
  final String providerNumber;
  final String serviceId;

  const BookNowScreen({
    Key? key,
    required this.serviceTitle,
    required this.providerName,
    required this.providerEmail,
    required this.providerCity,
    required this.providerId,
    required this.providerImage,
    required this.servicePrice,
    required this.providerNumber,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _uploadBooking() async
  {
    final bookingId = const Uuid().v4();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      if (_dateController.text == '' || _timeController.text == '') {
        GlobalMethod.showErrorDialog(
            error: 'Please fill everything',
            ctx: context
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('bookings')
            .doc(bookingId)
            .set({
          'bookingId': bookingId,
          'bookedBy': uid,
          'serviceId' : widget.serviceId,
          'userName' : name,
          'userImage' : userImage,
          'userCity' : city,
          'userEmail': user.email,
          'userNumber': phoneNumber,
          'serviceTitle': widget.serviceTitle,
          'servicePrice': widget.servicePrice,
          'userAddress': _addressController.text,
          'bookingDate' : _dateController.text,
          'bookingTime' : _timeController.text,
          'bookingNotes' : _notesController.text,
          'bookedAt': Timestamp.now(),
          'providerId' : widget.providerId,
          'providerName': widget.providerName,
          'providerImage': widget.providerImage,
          'providerCity': widget.providerCity,
          'providerEmail' : widget.providerEmail,
          'providerNumber' : widget.providerNumber,
          'bookingState' : 'Confirmation Pending',
          'reviewAdded' : 'false'
        });
        await Fluttertoast.showToast(
          msg: 'The service has been booked',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _dateController.clear();
        _timeController.clear();
        setState(() {
          _dateController.text = '';
          _timeController.text = '';
          _addressController.text = '';
          _notesController.text = '';
        });
        Navigator.pop(context);
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(
          error: error.toString(),
          ctx: context,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    else {
      print('Its not valid');
    }
  }

  void getMyData() async
  {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Now'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Details',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0,),
                Row(
                  children: [
                    Container(
                      height: 120.0,
                      width: 120.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(widget.providerImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.providerName,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0,),
                        SizedBox(
                          width: 200,
                          child: Text(
                            widget.serviceTitle,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14.0,),
                        Text(
                          'Rs ${widget.servicePrice}',
                          style: TextStyle(
                            fontSize: 21.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40.0,),
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Booking Date',
                    hintText: 'DD/MM/YYYY',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    _dateController.text = date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the booking date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Booking Time',
                    hintText: 'HH:MM AM/PM',
                    prefixIcon: Icon(Icons.watch_later_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    final now = DateTime.now();
                    final selectedDateTime = DateTime(now.year, now.month, now.day, time!.hour, time.minute);
                    final DateFormat formatter = DateFormat('hh:mm a');
                    final String formatted = formatter.format(selectedDateTime);
                    _timeController.text = formatted;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the booking time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : MaterialButton(
                    onPressed: () => _uploadBooking(),
                    color: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

