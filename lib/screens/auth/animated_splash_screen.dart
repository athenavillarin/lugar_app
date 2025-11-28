import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final String nextRoute;
  const AnimatedSplashScreen({super.key, this.nextRoute = '/onboarding'});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(widget.nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: Center(
        child: Lottie.asset(
          'assets/lottie/loading.json',
          width: 220,
          repeat: false,
        ),
      ),
    );
  }
}
