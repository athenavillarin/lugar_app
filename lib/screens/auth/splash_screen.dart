import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Show splash briefly
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Not logged in
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Image
            Container(
              margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
              height: size.height * 0.50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/splashscreen.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Lower Card Area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Image.asset(
                        'assets/images/lugar logo.png',
                        width: 180,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Gap between logo and text
                    const SizedBox(height: 20),

                    Text(
                      'Meet your local jeepney companion!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),

                    SizedBox(
                      height: size.height > 600 ? 120 : 40,
                    ), // Responsive gap: 120 for taller screens, 40 for smaller
                    // Loading indicator instead of button
                    const CircularProgressIndicator(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
