import 'package:flutter/material.dart';

import 'user_login_screen.dart';
import 'user_signup_screen.dart';
import 'provider_signup_screen.dart';
import 'provider_login_screen.dart';

class LandingScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LandingScreen({Key? key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildButton(
      String text, Color color, VoidCallback onPressed) {
    return MaterialButton(
      onPressed: onPressed,
      color: color,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'WorkWiz',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 65,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Your go-to home services app',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 65,
              ),
              _buildButton(
                  'Register as a Service Provider', Colors.cyan, () {
                _navigateTo(context, const ProviderSignUp());
              }),
              const SizedBox(
                height: 20,
              ),
              _buildButton('Register as a User', Colors.cyan, () {
                _navigateTo(context, const UserSignUp());
              }),
              const SizedBox(
                height: 20,
              ),
              _buildButton(
                  'Login as a Service Provider', Colors.cyan, () {
                _navigateTo(context, const ProviderLogin());
              }),
              const SizedBox(
                height: 20,
              ),
              _buildButton('Login as a User', Colors.cyan, () {
                _navigateTo(context, UserLogin());
              }),
            ],
          ),
        ),
      ),
    );
  }
}
