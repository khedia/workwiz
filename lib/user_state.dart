import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/user_home_screen.dart';
import 'pages/provider_home_screen.dart';
import 'pages/landing_screen.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.data == null) {
          return const LandingScreen();
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data!;
          final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
          final providerRef = FirebaseFirestore.instance
              .collection('providers')
              .doc(user.uid);

          return FutureBuilder<DocumentSnapshot>(
            future: userRef.get(),
            builder: (context, userData) {
              if (userData.hasData && userData.data!.exists) {
                // User exists in "users" collection
                return const UserHomeScreen();
              } else {
                return FutureBuilder<DocumentSnapshot>(
                  future: providerRef.get(),
                  builder: (context, providerData) {
                    if (providerData.hasData && providerData.data!.exists) {
                      // User exists in "providers" collection
                      return const ProviderHomeScreen();
                    } else if (providerData.connectionState ==
                        ConnectionState.waiting) {
                      // Show loading indicator while checking provider collection
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      // User does not exist in "users" or "providers" collection
                      return const Scaffold(
                        body: Center(
                          child: Text(
                              'User does not exist in "users" or "providers" collection'),
                        ),
                      );
                    }
                  },
                );
              }
            },
          );
        } else if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                  'An error has been occurred. Please try again later.'),
            ),
          );
        } else if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      },
    );
  }
}
