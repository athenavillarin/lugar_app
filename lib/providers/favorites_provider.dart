// Favorites provider
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteRoute {
  final String id;
  final String routeId;
  final String title;
  final int durationMinutes;
  final double price;
  final List<String> checkpoints;
  final String origin;
  final String destination;
  final List<Map<String, double>>? routePath;
  final List<Map<String, dynamic>>? segments;

  FavoriteRoute({
    required this.id,
    required this.routeId,
    required this.title,
    required this.durationMinutes,
    required this.price,
    required this.checkpoints,
    required this.origin,
    required this.destination,
    this.routePath,
    this.segments,
  });

  factory FavoriteRoute.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    List<String> _parseCheckpoints(dynamic value) {
      if (value is List) {
        final list = value
            .map(
              (e) => (e is String && e.trim().isNotEmpty)
                  ? e
                  : (e?.toString() ?? '').trim(),
            )
            .map((e) => e.isEmpty ? 'Stop' : e)
            .toList();
        return list.isEmpty ? ['Start', 'Destination'] : list;
      }
      return ['Start', 'Destination'];
    }

    String _parseString(dynamic v, String fallback) {
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    int _parseInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
        final asDouble = double.tryParse(v);
        if (asDouble != null) return asDouble.round();
      }
      return fallback;
    }

    double _parseDouble(dynamic v, double fallback) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final checkpoints = _parseCheckpoints(data['checkpoints']);
    String origin = _parseString(data['origin'], checkpoints.first);
    String destination = _parseString(data['destination'], checkpoints.last);

    // Shorten location names by removing common suffixes
    String _shortenLocation(String location) {
      String shortened = location;

      // Remove common location suffixes
      shortened = shortened.replaceAll(
        RegExp(r',?\s*Iloilo( City)?', caseSensitive: false),
        '',
      );
      shortened = shortened.replaceAll(
        RegExp(r',?\s*Philippines', caseSensitive: false),
        '',
      );
      shortened = shortened.replaceAll(
        RegExp(r',?\s*Western Visayas', caseSensitive: false),
        '',
      );
      shortened = shortened.replaceAll(
        RegExp(r',?\s*Iloilo Province', caseSensitive: false),
        '',
      );

      // Remove trailing commas and extra spaces
      shortened = shortened.replaceAll(RegExp(r',\s*$'), '').trim();

      // If there are still commas, keep only the first part
      if (shortened.contains(',')) {
        shortened = shortened.split(',')[0].trim();
      }

      // Limit length to avoid overflow (max 30 characters)
      if (shortened.length > 30) {
        shortened = shortened.substring(0, 27) + '...';
      }

      return shortened.isNotEmpty ? shortened : location;
    }

    origin = _shortenLocation(origin);
    destination = _shortenLocation(destination);

    // If origin/destination look generic, try to parse from title
    String rawTitle = _parseString(data['title'], '');
    List<String>? _parseEndsFromTitle(String t) {
      if (t.isEmpty) return null;
      final candidates = ['→', '->', '—', '-', ' to '];
      for (final sep in candidates) {
        if (t.contains(sep)) {
          final parts = t.split(sep);
          if (parts.length >= 2) {
            final left = _shortenLocation(parts.first.trim());
            final right = _shortenLocation(parts.last.trim());
            if (left.isNotEmpty && right.isNotEmpty) {
              return [left, right];
            }
          }
        }
      }
      return null;
    }

    bool _isGeneric(String s) {
      final v = s.trim().toLowerCase();
      return v == 'start' || v == 'destination' || v == 'your location';
    }

    if (_isGeneric(origin) || _isGeneric(destination)) {
      final ends = _parseEndsFromTitle(rawTitle);
      if (ends != null) {
        if (_isGeneric(origin)) origin = ends[0];
        if (_isGeneric(destination)) destination = ends[1];
      }
    }

    // Parse routePath if available
    List<Map<String, double>>? routePath;
    if (data['routePath'] is List) {
      routePath = (data['routePath'] as List)
          .map(
            (p) => {
              'latitude': (p['latitude'] as num).toDouble(),
              'longitude': (p['longitude'] as num).toDouble(),
            },
          )
          .toList();
    }

    // Parse segments if available
    List<Map<String, dynamic>>? segments;
    if (data['segments'] is List) {
      segments = (data['segments'] as List)
          .map((s) => Map<String, dynamic>.from(s as Map))
          .toList();
    }

    return FavoriteRoute(
      id: doc.id,
      routeId: _parseString(data['routeId'], doc.id),
      title: _parseString(rawTitle, '$origin → $destination'),
      durationMinutes: _parseInt(data['durationMinutes'], 30),
      price: _parseDouble(data['price'], 0.0),
      checkpoints: checkpoints,
      origin: origin,
      destination: destination,
      routePath: routePath,
      segments: segments,
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
            routeId: 'R001',
            title: 'Start → Destination',
            durationMinutes: 20,
            price: 12.0,
            checkpoints: ['Start', 'Checkpoint 1', 'Destination'],
            origin: 'Start',
            destination: 'Destination',
          ),
          FavoriteRoute(
            id: 'local_2',
            routeId: 'R002',
            title: 'Home → Office',
            durationMinutes: 40,
            price: 24.0,
            checkpoints: [
              'Start',
              'Checkpoint 1',
              'Checkpoint 2',
              'Destination',
            ],
            origin: 'Home',
            destination: 'Office',
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
