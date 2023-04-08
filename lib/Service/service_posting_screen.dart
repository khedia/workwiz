import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:workwiz/Persistent/persistent.dart';
import 'package:workwiz/Services/global_methods.dart';
import 'package:workwiz/Services/global_variables.dart';
import 'package:workwiz/widgets/provider_bottom_nav_bar.dart';

class ServicePosting extends StatefulWidget {
  const ServicePosting({super.key});


  @override
  State<ServicePosting> createState() => _ServicePostingState();
}

class _ServicePostingState extends State<ServicePosting> {

  final TextEditingController _serviceCategoryController = TextEditingController(
      text: 'Select Service Category');
  final TextEditingController _serviceTitleController = TextEditingController();
  final TextEditingController _serviceDescriptionController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController(
      text: '');

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required TextInputType keyboardType
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 16,
          ),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: false,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.black87,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.cyan,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.red,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: valueKey,
            hintStyle: const TextStyle(
              color: Colors.black45,
              fontSize: 16,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
          ),
        ),
      ),
    );
  }


  void _showServiceCategoriesDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Service Category',
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
              itemCount: Persistent.serviceCategoryList.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _serviceCategoryController.text = Persistent
                          .serviceCategoryList[index];
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
                          Persistent.serviceCategoryList[index],
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

  void _uploadService() async
  {
    final serviceId = const Uuid().v4();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      if (_serviceCategoryController.text == 'Select Service Category') {
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
        await FirebaseFirestore.instance.collection('services')
            .doc(serviceId)
            .set({
          'serviceId': serviceId,
          'uploadedBy': uid,
          'email': user.email,
          'phoneNumber': phoneNumber,
          'serviceCategory': _serviceCategoryController.text,
          'serviceTitle': _serviceTitleController.text,
          'serviceDescription': _serviceDescriptionController.text,
          'servicePrice': _servicePriceController.text,
          'serviceComments': [],
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'city': city,
        });
        await Fluttertoast.showToast(
          msg: 'The service has been posted',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _serviceTitleController.clear();
        _serviceDescriptionController.clear();
        setState(() {
          _serviceCategoryController.text = 'Choose Service Category';
          _servicePriceController.text = '';
        });
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
        .collection('providers').doc(FirebaseAuth.instance.currentUser!.uid)
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

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForProvider(indexNum: 1),
      appBar: AppBar(
        title: const Text('Add a Service'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              const Center(
                child: Text(
                  'Please fill all fields',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12,),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(height: 18,),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textTitles(label: 'Service Category :'),
                    _textFormFields(
                      valueKey: 'ServiceCategory',
                      controller: _serviceCategoryController,
                      enabled: false,
                      fct: () => _showServiceCategoriesDialog(size: size),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 30,),
                    _textTitles(label: 'Service Title :'),
                    TextFormField(
                      controller: _serviceTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Service Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30,),
                    _textTitles(label: 'Service Description :'),
                    TextFormField(
                      controller: _serviceDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Service Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      maxLength: 300,
                      textAlignVertical: TextAlignVertical.top,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6,),
                    _textTitles(label: 'Price :'),
                    TextFormField(
                      controller: _servicePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Service Price',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20,),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                        onPressed: () => _uploadService(),
                        icon: const Icon(Icons.upload_file),
                        label: const Text(
                          'Post Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue, // Set the text color
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Set the button's padding
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Set the button's border radius
                          elevation: 5, // Set the button's elevation
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}