// Favorites provider
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteRoute {
  final String id;
  final String title;
  final int durationMinutes;
  final double price;
  final List<String> checkpoints;

  FavoriteRoute({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.price,
    required this.checkpoints,
  });

  factory FavoriteRoute.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FavoriteRoute(
      id: doc.id,
      title: data['title'] ?? 'Route',
      durationMinutes: (data['durationMinutes'] ?? 30) as int,
      price: (data['price'] ?? 0.0).toDouble(),
      checkpoints: List<String>.from(
        data['checkpoints'] ?? ['Start', 'Destination'],
      ),
    );
  }
}

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<FavoriteRoute> _favorites = [];
  bool _isLoading = false;

  List<FavoriteRoute> get favorites => _favorites;
  bool get isLoading => _isLoading;

  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> fetchFavorites() async {
    final user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();

    try {
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .orderBy('createdAt', descending: true)
            .get();

        _favorites = snapshot.docs
            .map((doc) => FavoriteRoute.fromFirestore(doc))
            .toList();
      } else {
        // Provide some local placeholders for guests
        _favorites = [
          FavoriteRoute(
            id: 'local_1',
            title: 'Start → Destination',
            durationMinutes: 20,
            price: 12.0,
            checkpoints: ['Start', 'Checkpoint 1', 'Destination'],
          ),
          FavoriteRoute(
            id: 'local_2',
            title: 'Home → Office',
            durationMinutes: 40,
            price: 24.0,
            checkpoints: [
              'Start',
              'Checkpoint 1',
              'Checkpoint 2',
              'Destination',
            ],
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFavorite(String id) async {
    final user = _auth.currentUser;
    try {
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(id)
            .delete();
      }

      _favorites.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting favorite: $e');
    }
  }
}
