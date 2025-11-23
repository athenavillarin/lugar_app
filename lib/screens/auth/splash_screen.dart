import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
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
                  image: AssetImage('assets/images/splashscreen.jpg'),
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
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Gap between logo and text
                    const SizedBox(height: 20),

                    const Text(
                      'Meet your local jeepney companion!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF1F2024), fontSize: 14),
                    ),

                    const SizedBox(height: 120),

                    // CTA Button
                    SizedBox(
                      width: 164,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFFF5F8FF); // pressed bg
                            }
                            return const Color(0xFF006FFD); // normal bg
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF1F2024); // pressed text
                            }
                            return Colors.white; // normal text
                          }),
                          elevation: WidgetStateProperty.all(6),
                          shadowColor: WidgetStateProperty.all(
                            const Color(0x4D006FFD),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Let's go!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),

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
