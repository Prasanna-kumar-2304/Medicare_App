import 'package:flutter/material.dart';
import 'dart:async';
import 'package:medicare_app/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your splash screen content (logo, app name, etc.)
            Image.asset('assets/logo.png', height: 150),
            const SizedBox(height: 5),
            const Text('Your Complete Heathcare Assistant', 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color:Color.fromRGBO(11, 125, 198, 1)),
            ),
          ],
        ),
      ),
    );
  }
}