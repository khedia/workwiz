import 'package:flutter/material.dart';
import 'package:workwiz/pages/provider_login_screen.dart';
import 'package:workwiz/pages/provider_signup_screen.dart';
import 'package:workwiz/pages/user_login_screen.dart';
import 'package:workwiz/pages/user_signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildButton(
      String text, Color color, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double logoSize = screenHeight * 0.18;

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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'WorkWiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 58,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your go-to home services app',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              _buildButton(
                'I\'m a Service Provider',
                Colors.cyan,
                    () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: const Center(
                            child: Text(
                              'Service Provider Options',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan,
                              ),
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildButton(
                                'Register',
                                Colors.cyan,
                                    () =>
                                    _navigateTo(
                                      context,
                                      const ProviderSignUp(),
                                    ),
                              ),
                              _buildButton(
                                'Log in',
                                Colors.cyan,
                                    () =>
                                    _navigateTo(
                                      context,
                                      const ProviderLogin(),
                                    ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
              const SizedBox(height: 5,),
              _buildButton(
                'I\'m a User',
                Colors.cyan,
                    () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: const Center(
                            child: Text(
                              'User Options',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan,
                              ),
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildButton(
                                'Register',
                                Colors.cyan,
                                    () => _navigateTo(context, const UserSignUp()),
                              ),
                              _buildButton(
                                'Log in',
                                Colors.cyan,
                                    () => _navigateTo(context, const UserLogin()),
                              ),
                            ],
                          ),
                        )
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

