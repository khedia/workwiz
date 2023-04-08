import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import 'package:workwiz/widgets/provider_bottom_nav_bar.dart';
import 'package:workwiz/user_state.dart';

class ProviderProfileScreen extends StatefulWidget {

  final String userID;

  const ProviderProfileScreen({super.key, required this.userID});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String email = '';
  String phoneNumber = '';
  String imageUrl = '';
  String city = '';
  bool _isLoading = false;
  bool _isSameUser = false;

  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(widget.userID)
          .get();
      // ignore: unnecessary_null_comparison
      if(userDoc == null) {
        return;
      } else {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          city = userDoc.get('city');
        });
        User? user = _auth.currentUser;
        final uid = user!.uid;
        setState(() {
          _isSameUser = uid == widget.userID;
        });
      }
    } finally {
      _isLoading = false;
    }
  }

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    getUserData();
  }

  Widget userInfo({required IconData icon, required String content}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 15
            ),
          ),
        ),
      ],
    );
  }

  void _logout(context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    showDialog(
        context: context,
        builder: (context)
        {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Do you want to Log Out?',
              style: TextStyle(
                color: Colors.white,
                fontSize:  20,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'No',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 18
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  auth.signOut();
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserState()));
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 18
                  ),
                ),
              ),
            ],
          );
        }
    );
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

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    launchUrlString(url);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBarForProvider(indexNum: 3),
      body: Center(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Stack(
              children: [
                Card(
                  elevation: 4,
                  color: const Color(0xffC2E8E8),
                  margin: const EdgeInsets.all(30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            name == null ? 'Name here' : name!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(
                          thickness: 1,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Account information:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: userInfo(icon: Icons.email, content: email),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: userInfo(icon: Icons.phone, content: phoneNumber),
                        ),
                        const SizedBox(height: 15),
                        const Divider(
                          thickness: 1,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(height: 35),
                        _isSameUser
                            ? Container()
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _contactBy(
                              color: Colors.green,
                              fct: () {
                                _openWhatsAppChat();
                              },
                              icon: FontAwesome.whatsapp,
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
                        !_isSameUser
                            ? Container()
                            : Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: MaterialButton(
                              onPressed: () {
                                _logout(context);
                              },
                              color: Colors.cyan,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.30,
                      height: size.width * 0.30,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 8,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            // ignore: unnecessary_null_comparison
                              imageUrl == null
                                  ? 'https://www.pngfind.com/pngs/m/676-6764065_default-profile-picture-transparent-hd-png-download.png'
                                  : imageUrl
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
