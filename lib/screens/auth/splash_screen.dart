import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _onLetsGoPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
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

                    const SizedBox(height: 20),

                    Text(
                      'Meet your local jeepney companion!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),

                    SizedBox(height: size.height > 600 ? 120 : 40),

                    // CTA Button
                    SizedBox(
                      width: 164,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _onLetsGoPressed,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.pressed)) {
                              return theme.scaffoldBackgroundColor;
                            }
                            return theme.colorScheme.primary;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.pressed)) {
                              return theme.colorScheme.onSurface;
                            }
                            return theme.colorScheme.onPrimary;
                          }),
                          elevation: WidgetStateProperty.all(6),
                          shadowColor: WidgetStateProperty.all(
                            theme.colorScheme.primary.withValues(alpha: 0.3),
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
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
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
