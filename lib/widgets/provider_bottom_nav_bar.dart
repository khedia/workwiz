import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:workwiz/pages/provider_home_screen.dart';
import 'package:workwiz/pages/provider_search_screen.dart';
import 'package:workwiz/pages/provider_my_bookings_screen.dart';
import 'package:workwiz/pages/provider_profile_screen.dart';
import 'package:workwiz/Service/service_posting_screen.dart';

// ignore: must_be_immutable
class BottomNavigationBarForProvider extends StatelessWidget {

  int indexNum = 0;

  BottomNavigationBarForProvider({super.key, required this.indexNum});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.blue,
      backgroundColor: Colors.white,
      buttonBackgroundColor: Colors.blue,
      height: 50,
      index: indexNum,
      items: [
        _buildNavigationItem(Icons.list),
        _buildNavigationItem(Icons.add),
        _buildNavigationItem(Icons.book_online),
        _buildNavigationItem(Icons.person_pin),
      ],
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ProviderHomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ServicePosting()));
        } else if (index == 2) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ProviderMyBookingsScreen()));
        } else if (index == 3) {
          final FirebaseAuth auth = FirebaseAuth.instance;
          final User? user = auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ProviderProfileScreen(
                        userID: uid,
                      )));
        }
      },
    );
  }

  Widget _buildNavigationItem(IconData iconData) {
    return Icon(
      iconData,
      size: 24,
      color: Colors.white,
    );
  }
}
