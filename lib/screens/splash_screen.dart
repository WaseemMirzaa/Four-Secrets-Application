import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:four_secrets_wedding_app/pages/home.dart';
import 'package:four_secrets_wedding_app/screens/email_verification_screen.dart';
import 'package:four_secrets_wedding_app/screens/subscriptions/subscription_preview_screen.dart';
import 'package:four_secrets_wedding_app/services/wedding_day_schedule_service.dart';
import 'package:four_secrets_wedding_app/screens/newfeature1/services/wedding_day_schedule_service1.dart';
import 'package:page_transition/page_transition.dart';
import '../services/auth_service.dart';
import '../services/subscription/revenuecat_subscription_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final RevenueCatService _revenueCatService = RevenueCatService();
  Future<double> get _height => Future<double>.value(200);
  AnimationController? _controller;
  final int timeInSeconds = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: timeInSeconds, milliseconds: 200),
      vsync: this,
    );

    _controller?.addListener(() {
      if (_controller?.status == AnimationStatus.completed) {
        Timer(const Duration(seconds: 2), () {
          _checkAuthentication();
        });
      }
    });
    _controller?.forward();
  }

  Future<void> _checkAuthentication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.reload();

        // If this is the tester/reviewer account, skip RevenueCat and force subscribed
        final emailLower = (user.email ?? '').toLowerCase();
        const testerEmail = 'offfahad1@gmail.com';
        final isTester = emailLower == testerEmail;

        if (isTester) {
          print('✅ Firestore review account detected, skipping RevenueCat.');

          // Save to local prefs / userModel for consistency
          final userModel = await _authService.getCurrentUser();
          if (userModel != null) {
            await _authService.saveUserToPrefs(userModel);
          }

          // Normal flow: initialize RC and check status
          await _revenueCatService.initialize(user.uid);

          // Load schedule services, then navigate to Home
          try {
            final scheduleService = WeddingDayScheduleService();
            await scheduleService.loadData();
            final scheduleService1 = WeddingDayScheduleService1();
            await scheduleService1.loadData();
          } catch (e) {
            print('🔴 Error loading schedule services for review account: $e');
          }

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageTransition(
              duration: const Duration(seconds: 1),
              curve: Curves.easeIn,
              type: PageTransitionType.rightToLeft,
              child: const HomePage(),
            ),
          );
          return;
        }

        // Normal flow: initialize RC and check status
        await _revenueCatService.initialize(user.uid);
        await _revenueCatService.checkSubscriptionStatus();

        final userModel = await _authService.getCurrentUser();
        if (userModel != null) {
          await _authService.saveUserToPrefs(userModel);
          if (!user.emailVerified) {
            Navigator.of(context).pushReplacement(
              PageTransition(
                duration: const Duration(seconds: 1),
                curve: Curves.easeIn,
                type: PageTransitionType.rightToLeft,
                child: const EmailVerificationScreen(),
              ),
            );
            return;
          }

          if (!userModel.isSubscribed) {
            Navigator.of(context).pushReplacement(
              PageTransition(
                duration: const Duration(seconds: 1),
                curve: Curves.easeIn,
                type: PageTransitionType.rightToLeft,
                child: const SubscriptionPreviewScreen(),
              ),
            );
            return;
          }
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageTransition(
            duration: const Duration(seconds: 1),
            curve: Curves.easeIn,
            type: PageTransitionType.rightToLeft,
            child: const HomePage(),
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    } catch (e) {
      print('🔴 Error in splash screen authentication check: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<double>(
              future: _height,
              initialData: 0.0,
              builder: (context, snapshot) {
                return AnimatedContainer(
                  duration: Duration(seconds: timeInSeconds),
                  height: snapshot.data,
                  child: Container(
                    // width: 180, // Increased size
                    // height: 180, // Increased size
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4.0,
                      ), // Slightly thicker border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo/secrets-logo.jpg',
                        fit: BoxFit
                            .contain, // Changed to contain instead of cover
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0),
                child: Text(
                  'Perfect your Wedding with 4secrets - Wedding Planner',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
