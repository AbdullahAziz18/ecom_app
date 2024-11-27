import 'dart:async';
import 'package:ecom_app/pages/bottom_navigation.dart';
import 'package:ecom_app/pages/onboarding.dart';
import 'package:ecom_app/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? email;

  Future<void> checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = await SharedPreferenceHelper().getUserEmail();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && email != null) {
      // Redirect to homepage
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => BottomNavigation(
                  id: email!,
                )),
      );
    } else {
      // Redirect to login page
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const Onboarding()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), checkLoginState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 235, 231),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'images/ecom_app_logo-removebg-preview.png',
            ),
          ),
        ],
      ),
    );
  }
}
