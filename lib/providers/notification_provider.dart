import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  int _localIdCounter = 0; // For generating local IDs
  bool _notificationsEnabled = true; // Notification preferences

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get notificationsEnabled => _notificationsEnabled;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Toggle notification preferences
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Fetch notifications (from Firebase if logged in, local otherwise)
  Future<void> fetchNotifications() async {
    final user = _auth.currentUser;

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch global announcements for all users
      final globalSnapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();
      final globalNotifications = globalSnapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();

      List<AppNotification> userNotifications = [];
      if (user != null) {
        // Fetch user-specific notifications
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .get();
        userNotifications = snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList();
      }

      // Merge global and user notifications
      _notifications = [...globalNotifications, ...userNotifications]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;

    try {
      // Update in Firebase if logged in
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
      }

      // Update local state regardless
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;

    try {
      // Update in Firebase if logged in
      if (user != null) {
        final batch = _firestore.batch();
        final unreadNotifications = _notifications.where((n) => !n.isRead);

        for (final notification in unreadNotifications) {
          final docRef = _firestore
              .collection('users')
              .doc(user.uid)
              .collection('notifications')
              .doc(notification.id);
          batch.update(docRef, {'isRead': true});
        }

        await batch.commit();
      }

      // Update local state regardless
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final user = _auth.currentUser;

    try {
      // Delete from Firebase if logged in
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notificationId)
            .delete();
      }

      // Delete from local state regardless
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Add a notification (local or Firebase)
  Future<void> addNotification(String title, String body) async {
    final user = _auth.currentUser;

    try {
      if (user != null) {
        // Add to Firebase
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .add({
              'title': title,
              'body': body,
              'createdAt': FieldValue.serverTimestamp(),
              'isRead': false,
            });
        await fetchNotifications();
      } else {
        // Add locally for guest users
        final notification = AppNotification(
          id: 'local_${_localIdCounter++}',
          title: title,
          body: body,
          createdAt: DateTime.now(),
          isRead: false,
        );
        _notifications.insert(0, notification);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  // Add a test notification (for development)
  Future<void> addTestNotification() async {
    await addNotification(
      'Test Notification',
      'This is a test notification. Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...',
    );
  }
}
