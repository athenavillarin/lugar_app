import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/models/route_option.dart';
import 'nominatim_service.dart';

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

  // 1. Fetch routes and fares from Firestore
  final routesSnapshot = await FirebaseFirestore.instance
      .collection('routes')
      .get();
  final routes = <String, Map<String, dynamic>>{};
  for (var doc in routesSnapshot.docs) {
    routes[doc.id] = doc.data();
  }
  final faresSnapshot = await FirebaseFirestore.instance
      .collection('fares')
      .get();
  final routeFares = <String, Map<String, dynamic>>{};
  for (var doc in faresSnapshot.docs) {
    routeFares[doc.id] = doc.data();
  }

  // 2. Find routes near origin and near destination (allow transfers)
  const double proximityThreshold = 400.0; // meters
  List<RouteOption> options = [];

  // Find routes near origin
  List<String> originRoutes = [];
  routes.forEach((routeId, routeData) {
    final dynamic routePathRaw = routeData['route_path'];
    if (routePathRaw is! List<dynamic>) return;
    final List<dynamic> routePathList = routePathRaw;
    if (routePathList.isEmpty) return;
    final List<Map<String, dynamic>> routePathCoords = routePathList
        .whereType<Map<String, dynamic>>()
        .toList();
    if (routePathCoords.length < 2) return;

    double minOriginDist = double.infinity;
    for (var pt in routePathCoords) {
      final lat = (pt['latitude'] as num).toDouble();
      final lng = (pt['longitude'] as num).toDouble();
      final dist = haversine(originLat, originLng, lat, lng);
      if (dist < minOriginDist) minOriginDist = dist;
    }
    if (minOriginDist <= proximityThreshold) {
      originRoutes.add(routeId);
    }
  });

  // Find routes near destination
  List<String> destRoutes = [];
  routes.forEach((routeId, routeData) {
    final dynamic routePathRaw = routeData['route_path'];
    if (routePathRaw is! List<dynamic>) return;
    final List<dynamic> routePathList = routePathRaw;
    if (routePathList.isEmpty) return;
    final List<Map<String, dynamic>> routePathCoords = routePathList
        .whereType<Map<String, dynamic>>()
        .toList();
    if (routePathCoords.length < 2) return;

    double minDestDist = double.infinity;
    for (var pt in routePathCoords) {
      final lat = (pt['latitude'] as num).toDouble();
      final lng = (pt['longitude'] as num).toDouble();
      final dist = haversine(destLat, destLng, lat, lng);
      if (dist < minDestDist) minDestDist = dist;
    }
    if (minDestDist <= proximityThreshold) {
      destRoutes.add(routeId);
    }
  });

  print(
    'DEBUG: Routes near origin: ${originRoutes.length}, near dest: ${destRoutes.length}',
  );
  print('DEBUG: Origin routes: $originRoutes');
  print('DEBUG: Dest routes: $destRoutes');

  // For now, simple: if same route covers both, use it; else, check for split routes (e.g., R001A and R001B)
  Set<String> commonRoutes = originRoutes.toSet().intersection(
    destRoutes.toSet(),
  );
  if (commonRoutes.isEmpty) {
    // Check for split routes: if origin has RXXXA, dest has RXXXB, treat as connected
    for (String o in originRoutes) {
      for (String d in destRoutes) {
        if (o != d &&
            o.replaceAll(RegExp(r'[AB]$'), '') ==
                d.replaceAll(RegExp(r'[AB]$'), '')) {
          commonRoutes.add(o); // Use the origin one
          break;
        }
      }
      if (commonRoutes.isNotEmpty) break;
    }
  }

  if (commonRoutes.isNotEmpty) {
    // Add a RouteOption for each direct route
    for (String routeId in commonRoutes) {
      final routeData = routes[routeId]!;
      final dynamic routePathRaw = routeData['route_path'];
      final List<dynamic> routePathList = routePathRaw;
      final List<Map<String, dynamic>> routePathCoords = routePathList
          .whereType<Map<String, dynamic>>()
          .toList();

      // Find closest points
      double minOriginDist = double.infinity;
      double minDestDist = double.infinity;
      int originClosestIndex = -1;
      int destClosestIndex = -1;
      for (int i = 0; i < routePathCoords.length; i++) {
        final pt = routePathCoords[i];
        final lat = (pt['latitude'] as num).toDouble();
        final lng = (pt['longitude'] as num).toDouble();
        final originDist = haversine(originLat, originLng, lat, lng);
        if (originDist < minOriginDist) {
          minOriginDist = originDist;
          originClosestIndex = i;
        }
        final destDist = haversine(destLat, destLng, lat, lng);
        if (destDist < minDestDist) {
          minDestDist = destDist;
          destClosestIndex = i;
        }
      }

      // Always use originClosestIndex as start, destClosestIndex as end, and reverse if needed
      int startIndex = originClosestIndex;
      int endIndex = destClosestIndex;
      bool reverse = startIndex > endIndex;
      // Determine if walking is actually needed
      const double onRouteThreshold = 100.0; // meters
      final walkingDistanceOrigin = minOriginDist <= onRouteThreshold
          ? 0.0
          : minOriginDist;
      final walkingDistanceDest = minDestDist <= onRouteThreshold
          ? 0.0
          : minDestDist;
      final walkingDistance = walkingDistanceOrigin + walkingDistanceDest;
      double jeepDistance = 0.0;
      for (
        int i = min(startIndex, endIndex);
        i < max(startIndex, endIndex);
        i++
      ) {
        final pt1 = routePathCoords[i];
        final pt2 = routePathCoords[i + 1];
        jeepDistance += haversine(
          (pt1['latitude'] as num).toDouble(),
          (pt1['longitude'] as num).toDouble(),
          (pt2['latitude'] as num).toDouble(),
          (pt2['longitude'] as num).toDouble(),
        );
      }
      final walkingTime = (walkingDistance / 100).ceil();
      final jeepTime = (jeepDistance / 300).ceil();
      final distanceKm = jeepDistance / 1000.0;
      final km = max(1, distanceKm.ceil());
      final fareType = 'PUJ_MOD';
      final fareKey = '${fareType}_$km';
      final fareMap =
          routeFares[fareKey] ?? {'regular': 0.0, 'discounted': 0.0};
      final currentTime = DateTime.now();
      List<RoutePoint> routePath = routePathCoords
          .sublist(min(startIndex, endIndex), max(startIndex, endIndex) + 1)
          .map(
            (pt) => RoutePoint(
              latitude: (pt['latitude'] as num).toDouble(),
              longitude: (pt['longitude'] as num).toDouble(),
            ),
          )
          .toList();
      if (reverse) {
        routePath = routePath.reversed.toList();
      }
      // Geocoding
      final int n = routePath.length;
      Set<int> neededIndices = {};
      if (walkingDistanceOrigin > 0 && walkingDistanceDest > 0) {
        neededIndices.addAll([0, 1, n - 2, n - 1]);
      } else if (walkingDistanceOrigin > 0) {
        neededIndices.addAll([0, 1, n - 1]);
      } else if (walkingDistanceDest > 0) {
        neededIndices.addAll([0, n - 2, n - 1]);
      } else {
        neededIndices.addAll([0, n - 1]);
      }
      final labelFutures = <int, Future<String?>>{};
      for (int idx in neededIndices) {
        if (idx >= 0 && idx < routePath.length) {
          labelFutures[idx] = _getCleanedPlaceName(
            routePath[idx].latitude,
            routePath[idx].longitude,
          );
        }
      }
      final labelResults = <int, String?>{};
      await Future.wait(
        labelFutures.entries.map((entry) async {
          labelResults[entry.key] = await entry.value;
        }),
      );
      String getLabel(int idx) {
        return labelResults[idx] ?? 'Location ${idx + 1}';
      }

      // Build segments
      final segments = <TransportSegment>[];
      if (walkingDistanceOrigin > 0 && walkingDistanceDest > 0) {
        segments.add(
          TransportSegment(
            icon: Icons.directions_walk,
            type: 'Walk',
            startIndex: 0,
            endIndex: 0,
            durationMinutes: (walkingDistanceOrigin / 100).ceil(),
            getOnLabel: getLabel(0),
            getOffLabel: getLabel(0),
          ),
        );
        if (n > 2) {
          segments.add(
            TransportSegment(
              icon: Icons.directions_bus,
              type: 'Jeepney',
              startIndex: 1,
              endIndex: n - 2,
              durationMinutes: jeepTime,
              getOnLabel: getLabel(1),
              getOffLabel: getLabel(n - 2),
            ),
          );
        }
        segments.add(
          TransportSegment(
            icon: Icons.directions_walk,
            type: 'Walk',
            startIndex: n - 1,
            endIndex: n - 1,
            durationMinutes: (walkingDistanceDest / 100).ceil(),
            getOnLabel: getLabel(n - 1),
            getOffLabel: getLabel(n - 1),
          ),
        );
      } else if (walkingDistanceOrigin > 0) {
        segments.add(
          TransportSegment(
            icon: Icons.directions_walk,
            type: 'Walk',
            startIndex: 0,
            endIndex: 0,
            durationMinutes: (walkingDistanceOrigin / 100).ceil(),
            getOnLabel: getLabel(0),
            getOffLabel: getLabel(0),
          ),
        );
        if (n > 1) {
          segments.add(
            TransportSegment(
              icon: Icons.directions_bus,
              type: 'Jeepney',
              startIndex: 1,
              endIndex: n - 1,
              durationMinutes: jeepTime,
              getOnLabel: getLabel(1),
              getOffLabel: getLabel(n - 1),
            ),
          );
        }
      } else if (walkingDistanceDest > 0) {
        if (n > 1) {
          segments.add(
            TransportSegment(
              icon: Icons.directions_bus,
              type: 'Jeepney',
              startIndex: 0,
              endIndex: n - 2,
              durationMinutes: jeepTime,
              getOnLabel: getLabel(0),
              getOffLabel: getLabel(n - 2),
            ),
          );
        }
        segments.add(
          TransportSegment(
            icon: Icons.directions_walk,
            type: 'Walk',
            startIndex: n - 1,
            endIndex: n - 1,
            durationMinutes: (walkingDistanceDest / 100).ceil(),
            getOnLabel: getLabel(n - 1),
            getOffLabel: getLabel(n - 1),
          ),
        );
      } else {
        if (n > 1) {
          segments.add(
            TransportSegment(
              icon: Icons.directions_bus,
              type: 'Jeepney',
              startIndex: 0,
              endIndex: n - 1,
              durationMinutes: jeepTime,
              getOnLabel: getLabel(0),
              getOffLabel: getLabel(n - 1),
            ),
          );
        }
      }
      // Build timeline (unchanged)
      final timeline = <TimelinePoint>[];
      DateTime cumulativeTime = currentTime;
      timeline.add(
        TimelinePoint(
          label: 'Start',
          time:
              '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
        ),
      );
      if (walkingDistanceOrigin > 0) {
        cumulativeTime = cumulativeTime.add(
          Duration(minutes: (walkingDistanceOrigin / 100).ceil()),
        );
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
      if (walkingDistanceDest > 0) {
        cumulativeTime = cumulativeTime.add(
          Duration(minutes: (walkingDistanceDest / 100).ceil()),
        );
        timeline.add(
          TimelinePoint(
            label: getLabel(n - 1),
            time:
                '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
          ),
        );
      } else {
        timeline.add(
          TimelinePoint(
            label: getLabel(n - 1),
            time:
                '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')} (ETA)',
          ),
        );
      }
      // Ensure all string values are non-null
      final startLoc = segments.isNotEmpty && segments.first.getOnLabel != null
          ? segments.first.getOnLabel!
          : 'Start';

      final checkpointLoc =
          segments.length > 1 && segments[1].getOnLabel != null
          ? segments[1].getOnLabel!
          : (segments.isNotEmpty && segments.first.getOffLabel != null
                ? segments.first.getOffLabel!
                : 'Checkpoint');

      final startTimeStr =
          '${DateTime.now().add(Duration(minutes: walkingTime)).hour.toString().padLeft(2, '0')}:${DateTime.now().add(Duration(minutes: walkingTime)).minute.toString().padLeft(2, '0')}';
      final endTimeStr =
          '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}';

      print(
        'DEBUG: Creating RouteOption with startLocation="$startLoc", checkpointLocation="$checkpointLoc", startTime="$startTimeStr", endTime="$endTimeStr"',
      );

      options.add(
        RouteOption(
          routeId: routeId,
          routePath: routePath,
          duration: '${walkingTime + jeepTime} mins',
          regularFare: (fareMap['regular'] as num).toDouble(),
          discountedFare: (fareMap['discounted'] as num).toDouble(),
          price: (fareMap['regular'] as num).toDouble(),
          startTime: startTimeStr,
          endTime: endTimeStr,
          progress: 0.0,
          startLocation: startLoc,
          checkpointLocation: checkpointLoc,
          segments: segments,
          timeline: timeline,
        ),
      );
    }
  } else {
    // Placeholder for transfer: for now, no routes
    print('DEBUG: No direct routes; transfers not implemented yet');
  }

  // Sort by total travel time (ascending)
  options.sort((a, b) {
    int aTime = int.tryParse(a.duration.split(' ').first) ?? 9999;
    int bTime = int.tryParse(b.duration.split(' ').first) ?? 9999;
    return aTime.compareTo(bTime);
  });
  return options;
}

// Helper function to get cleaned place name from coordinates
Future<String?> _getCleanedPlaceName(double lat, double lon) async {
  try {
    final result = await NominatimService.reverseGeocode(lat, lon);
    if (result != null) {
      String name = result.displayName;
      // Remove common suffixes
      name = name.replaceAll(
        RegExp(r',?\s*Iloilo( City)?', caseSensitive: false),
        '',
      );
      name = name.replaceAll(
        RegExp(r',?\s*Philippines', caseSensitive: false),
        '',
      );
      name = name.replaceAll(
        RegExp(r',?\s*Western Visayas', caseSensitive: false),
        '',
      );
      // Remove trailing commas/spaces
      name = name.replaceAll(RegExp(r',\s*$'), '').trim();
      // Only keep the first phrase before a comma
      name = name.split(',')[0].trim();
      return name.isNotEmpty ? name : null;
    }
  } catch (e) {
    print('Error fetching place name: $e');
  }
  return null;
}
