import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../providers/notification_provider.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Background message handling
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationProvider notificationProvider;

  FCMService(this.notificationProvider);

  // Initialize FCM
  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined notification permission');
      return;
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    // TODO: Send token to backend to associate with user

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      // TODO: Send new token to backend
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Handle message when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Handle message when app is opened from terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        'App opened from terminated state: ${initialMessage.notification?.title}',
      );
      _handleMessage(initialMessage);
    }
  }

  // Handle incoming message
  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      // Add notification to provider
      notificationProvider.addNotification(
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? '',
      );
    }
  }

  // Subscribe to a topic (for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  // Get current FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
