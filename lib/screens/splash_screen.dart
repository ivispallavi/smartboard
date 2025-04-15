import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

void _navigate() async {
  await Future.delayed(const Duration(seconds: 2)); // Simulate loading time

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          Center(
            child: Image.asset(
              'assets/logo.png', // Replace with your logo file
              width: 150.w, // Adjust size as needed
              height: 150.h,
              fit: BoxFit.contain,
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Image.asset(
              'assets/company_logo.png', // Replace with your company logo file
              width: 100.w, // Adjust size as needed
              height: 50.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}