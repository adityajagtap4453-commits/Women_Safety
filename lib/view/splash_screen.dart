import 'dart:async';
import 'package:flutter/material.dart';
import 'package:women_safety_app/controller/share_pref.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/view/login_screen.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_screen.dart';
import 'package:women_safety_app/view/register/parent/parent_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 🔹 Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // 🔹 Navigate to appropriate screen
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    String userType = MySharedPrefference.getUserType();

    if (userType == 'parent') {
      goToPushReplacement(context, const ParentHomeScreen());
    } else if (userType == 'child') {
      goToPushReplacement(context, const BottomNavigationScreen());
    } else {
      goToPushReplacement(context, const LoginScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pink50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌸 App logo or image
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: white,
                  boxShadow: [
                    BoxShadow(color: pink200, blurRadius: 15, spreadRadius: 3),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/logo.png', // ⚠️ replace with your app logo
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 🌸 App name
              const Text(
                "Women Safety App",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: pink,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              // 🌸 Tagline
              Text(
                "Stay Safe, Stay Strong 💪",
                style: TextStyle(
                  fontSize: 16,
                  color: pink400,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
