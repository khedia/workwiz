import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:workwiz/pages/user_home_screen.dart';
import 'package:workwiz/pages/user_search_screen.dart';
import 'package:workwiz/pages/user_my_bookings_screen.dart';
import 'package:workwiz/pages/user_profile_screen.dart';

// ignore: must_be_immutable
class BottomNavigationBarForUser extends StatelessWidget {

  int indexNum = 0;

  BottomNavigationBarForUser({super.key, required this.indexNum});

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
        _buildNavigationItem(Icons.search),
        _buildNavigationItem(Icons.book_online),
        _buildNavigationItem(Icons.person_pin),
      ],
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const UserHomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserSearchScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const UserMyBookingsScreen()));
        } else if (index == 3) {
          final FirebaseAuth auth = FirebaseAuth.instance;
          final User? user = auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      UserProfileScreen(
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
