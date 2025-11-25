import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/app_shell.dart';
import 'services/fcm_service.dart';
import 'providers/notification_provider.dart';

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationProvider _notificationProvider = NotificationProvider();
  FCMService? _fcmService;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Initialize FCM service with the same provider instance
    _fcmService = FCMService(_notificationProvider);
    await _fcmService!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xFF1F2024);
    const primaryBlue = Color(0xFF006FFD);

    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _notificationProvider)],
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
          ),
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
                  return const Color(0xFFF5F8FF); // scaffoldBackgroundColor
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
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const AppShell(),
        },
      ),
    );
  }
}
