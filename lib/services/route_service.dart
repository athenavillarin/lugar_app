import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/models/route_option.dart';

/// Finds the best jeepney routes between two coordinates
/// Returns a sorted list of RouteOption objects (shortest travel time first)
Future<List<RouteOption>> findRoutes(
  double originLat,
  double originLng,
  double destLat,
  double destLng,
) async {
  // Helper: Haversine formula
  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // meters
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180.0;
    final dLon = (lon2 - lon1) * 3.141592653589793 / 180.0;
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * 3.141592653589793 / 180.0) *
            cos(lat2 * 3.141592653589793 / 180.0) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // 1. Fetch all routes
  final routesSnapshot = await FirebaseFirestore.instance
      .collection('routes')
      .get();
  final routes = <String, Map<String, dynamic>>{};
  for (var doc in routesSnapshot.docs) {
    routes[doc.id] = doc.data();
  }
  print('DEBUG: Fetched ${routes.length} routes');
  if (routes.isEmpty) return [];

  // 2. Fetch fares (per fare_type and distance_km)
  final faresSnapshot = await FirebaseFirestore.instance
      .collection('fares')
      .get();
  // Map: fareType_distanceKm -> {regular, discounted}
  final Map<String, Map<String, double>> routeFares = {};
  for (var doc in faresSnapshot.docs) {
    final data = doc.data();
    final fareType = data['fare_type'];
    final distanceKm = data['distance_km'];
    if (fareType != null && distanceKm != null) {
      final key = '${fareType}_${distanceKm}';
      routeFares[key] = {
        'regular': (data['regular'] as num?)?.toDouble() ?? 0.0,
        'discounted': (data['discounted'] as num?)?.toDouble() ?? 0.0,
      };
    }
  }

  // 3. Find routes where route_path passes near both origin and destination
  const double proximityThreshold = 5000.0; // meters
  List<RouteOption> options = [];
  int routesChecked = 0;
  int routesWithPath = 0;
  int routesNearOrigin = 0;
  int routesNearBoth = 0;
  routes.forEach((routeId, routeData) {
    routesChecked++;
    final dynamic routePathRaw = routeData['route_path'];
    if (routePathRaw is! List<dynamic>) {
      print('DEBUG: Route $routeId route_path is not a list: $routePathRaw');
      return;
    }
    final List<dynamic> routePathList = routePathRaw;
    if (routePathList.isEmpty) {
      print('DEBUG: Route $routeId has empty route_path');
      return;
    }
    routesWithPath++;

    final fareType = 'PUJ_MOD'; // Assume MOD for now; both types available

    final List<Map<String, dynamic>> routePathCoords = routePathList
        .whereType<Map<String, dynamic>>()
        .toList();
    print('DEBUG: Route $routeId has ${routePathCoords.length} coordinates');

    // Skip routes with fewer than 2 coordinates (no path to calculate distance)
    if (routePathCoords.length < 2) {
      print('DEBUG: Route $routeId skipped due to insufficient coordinates');
      return;
    }

    // Check proximity to origin and destination
    double minOriginDist = double.infinity;
    double minDestDist = double.infinity;
    for (final pt in routePathCoords) {
      final lat = (pt['latitude'] as num).toDouble();
      final lng = (pt['longitude'] as num).toDouble();
      final originDist = haversine(originLat, originLng, lat, lng);
      if (originDist < minOriginDist) minOriginDist = originDist;
      final destDist = haversine(destLat, destLng, lat, lng);
      if (destDist < minDestDist) minDestDist = destDist;
    }

    print(
      'DEBUG: Route $routeId - minOriginDist: $minOriginDist, minDestDist: $minDestDist',
    );

    if (minOriginDist <= proximityThreshold) routesNearOrigin++;
    if (minOriginDist <= proximityThreshold &&
        minDestDist <= proximityThreshold) {
      routesNearBoth++;
      // Compute walking distance (min to route)
      final walkingDistance = minOriginDist;
      // Compute jeepney distance (total route length)
      double jeepDistance = 0.0;
      for (int i = 0; i < routePathCoords.length - 1; i++) {
        final pt1 = routePathCoords[i];
        final pt2 = routePathCoords[i + 1];
        jeepDistance += haversine(
          (pt1['latitude'] as num).toDouble(),
          (pt1['longitude'] as num).toDouble(),
          (pt2['latitude'] as num).toDouble(),
          (pt2['longitude'] as num).toDouble(),
        );
      }
      // Estimate times
      final walkingTime = (walkingDistance / 100).ceil();
      final jeepTime = (jeepDistance / 300).ceil();
      // Fares (distance-based, lookup exact km)
      final distanceKm = jeepDistance / 1000.0;
      final km = max(1, distanceKm.ceil()); // Ensure at least 1 km
      final fareKey = '${fareType}_${km}';
      print(
        'DEBUG: Route $routeId - jeepDistance: $jeepDistance m, km: $km, fareKey: $fareKey',
      );
      final fareMap =
          routeFares[fareKey] ?? {'regular': 0.0, 'discounted': 0.0};
      print(
        'DEBUG: Fare found: ${routeFares.containsKey(fareKey)}, regular: ${fareMap['regular']}, discounted: ${fareMap['discounted']}',
      );
      // Calculate total duration in minutes
      final totalDurationMinutes = walkingTime + jeepTime;
      final currentTime = DateTime.now();
      // RoutePath for UI (as RoutePoint)
      final routePath = routePathCoords
          .map(
            (pt) => RoutePoint(
              latitude: (pt['latitude'] as num).toDouble(),
              longitude: (pt['longitude'] as num).toDouble(),
            ),
          )
          .toList();
      // Segments for UI (walk + jeep)
      final segments = <TransportSegment>[];
      if (walkingDistance > 0) {
        segments.add(
          TransportSegment(icon: Icons.directions_walk, type: 'Walk'),
        );
      }
      segments.add(
        TransportSegment(icon: Icons.directions_bus, type: 'Jeepney'),
      );
      // Timeline for UI (with times: start = now, checkpoints cumulative, destination = ETA)
      final timeline = <TimelinePoint>[];
      DateTime cumulativeTime = currentTime;
      timeline.add(
        TimelinePoint(
          label: 'Start',
          time:
              '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
        ),
      );

      if (walkingDistance > 0) {
        cumulativeTime = cumulativeTime.add(Duration(minutes: walkingTime));
        timeline.add(
          TimelinePoint(
            label: 'Walk to Route',
            time:
                '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
          ),
        );
      }

      cumulativeTime = cumulativeTime.add(Duration(minutes: jeepTime));
      timeline.add(
        TimelinePoint(
          label: 'Jeepney',
          time:
              '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
        ),
      );

      timeline.add(
        TimelinePoint(
          label: 'Destination',
          time:
              '${currentTime.add(Duration(minutes: totalDurationMinutes)).hour.toString().padLeft(2, '0')}:${currentTime.add(Duration(minutes: totalDurationMinutes)).minute.toString().padLeft(2, '0')} (ETA)',
        ),
      );
      options.add(
        RouteOption(
          routeId: routeId,
          routePath: routePath,
          duration: '${walkingTime + jeepTime} mins',
          regularFare: fareMap['regular']!,
          discountedFare: fareMap['discounted']!,
          segments: segments,
          timeline: timeline,
        ),
      );
    }
  });

  // Sort by total travel time (ascending)
  options.sort((a, b) {
    int aTime = int.tryParse(a.duration.split(' ').first) ?? 9999;
    int bTime = int.tryParse(b.duration.split(' ').first) ?? 9999;
    return aTime.compareTo(bTime);
  });
  return options;
}
