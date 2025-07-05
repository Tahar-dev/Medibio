import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'dart:async';
import 'splash_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ThemeColors.buildCardBlue),
              strokeWidth: 5,
            ),
            const SizedBox(height: 60),
            Text(
              'Chargement en cours \n Merci de patienter',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeColors.buildCardBlue,
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'lib/images/sandGlass.jpg',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Image.asset(
              'lib/images/logo-ts.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
