import 'package:ecom_app/pages/login_page.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    // Get screen height and width using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate dynamic font size based on screen width
    double baseFontSize;
    if (screenHeight < 700) {
      baseFontSize = screenWidth * 0.078;
    } else {
      baseFontSize = screenWidth * 0.11;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 235, 231),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image takes dynamic height (e.g., 58% of screen height) and full screen width
            SizedBox(
              height: screenHeight * 0.6, // 60% of screen height
              width: double.infinity, // Full width of the screen
              child: Image.asset(
                'images/headphone.PNG',
                fit: BoxFit.cover, // Ensures the image covers the entire area
              ),
            ),
            // Text section with dynamic font size
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Explore\nThe Best\nProducts',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: baseFontSize, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Button section pushed to the bottom with dynamic font size
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: screenWidth > 350 || screenHeight > 700
                      ? Container(
                          padding: const EdgeInsets.all(35),
                          margin: const EdgeInsets.only(right: 20),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: baseFontSize *
                                  0.5, // Smaller responsive font for button
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(right: 20),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: baseFontSize *
                                  0.5, // Smaller responsive font for button
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }
}
