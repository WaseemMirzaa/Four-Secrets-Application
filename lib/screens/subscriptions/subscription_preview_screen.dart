import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../routes/routes.dart';

class SubscriptionPreviewScreen extends StatefulWidget {
  const SubscriptionPreviewScreen({super.key});

  @override
  State<SubscriptionPreviewScreen> createState() =>
      _SubscriptionPreviewScreenState();
}

class _SubscriptionPreviewScreenState extends State<SubscriptionPreviewScreen> {
  final List<String> _previewImages = [
    'assets/preview/1.jpg',
    'assets/preview/2.jpg',
    'assets/preview/3.png',
    'assets/preview/4.jpg',
    'assets/preview/6.jpg',
    'assets/preview/7.jpg',
    'assets/preview/8.jpg',
    'assets/preview/9.jpg',
    'assets/preview/10.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background slider
          Stack(
            children: [
              CarouselSlider(
                items: _previewImages
                    .map(
                      (imgPath) => Image.asset(
                        imgPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                    .toList(),
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 2),
                ),
              ),

              // Gradient overlay only for bottom half
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.1, 1.0], // no shadow for top half
                      colors: [
                        Colors.transparent, // top half clear
                        Colors.black.withOpacity(0.9), // fade in at bottom
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Top bar with logout
                  const Spacer(),

                  // Title
                  const Text(
                    'Entdecken Sie alle Premium-Funktionen',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 1,
                        )
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Machen Sie Ihre Hochzeit stressfrei mit 4secrets.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Upgrade button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/subscription');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            const Color.fromARGB(255, 107, 69, 106),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.white.withOpacity(0.6),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Jetzt Premium Freischalten",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteManager.homePage,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'überspringen',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
