import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/animated_splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/app_shell.dart';
import 'services/fcm_service.dart';
import 'providers/notification_provider.dart';
import 'providers/favorites_provider.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Handle FCM background messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Load prefs and user before runApp() → prevents splash flash
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final user = FirebaseAuth.instance.currentUser;

  // Decide starting route
  String initialRoute;

  if (user != null) {
    initialRoute = '/home';
  } else if (hasSeenOnboarding) {
    initialRoute = '/login';
  } else {
    initialRoute = '/onboarding'; // first installation → show onboarding splash
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationProvider _notificationProvider = NotificationProvider();
  final FavoritesProvider _favoritesProvider = FavoritesProvider();
  FCMService? _fcmService;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    _fcmService = FCMService(_notificationProvider);
    await _fcmService!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xFF1F2024);
    const primaryBlue = Color(0xFF006FFD);
    const cardBackgroundColor = Color(0xFFEAF2FF);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _notificationProvider),
        ChangeNotifierProvider.value(value: _favoritesProvider),
      ],
      child: MaterialApp(
        title: 'Lugar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: const Color(0xFFF5F8FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryBlue,
            primary: primaryBlue,
            secondary: primaryBlue,
            surfaceContainerHighest: cardBackgroundColor,
          ),
          cardTheme: const CardThemeData(color: cardBackgroundColor),
          textTheme: Typography.blackMountainView.apply(
            bodyColor: primaryTextColor,
            displayColor: primaryTextColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: primaryTextColor,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return const Color(0xFFF5F8FF);
                }
                return primaryBlue;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return primaryTextColor;
                }
                return Colors.white;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),

        initialRoute: widget.initialRoute,

        routes: {
          '/onboarding': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const AppShell(),

          // Keeping this in case you still use it somewhere
          '/loading_to_home': (context) =>
              const AnimatedSplashScreen(nextRoute: '/home'),
        },
      ),
    );
  }
}
