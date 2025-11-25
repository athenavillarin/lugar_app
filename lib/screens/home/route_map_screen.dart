import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/map_widget.dart';
import '../models/route_option.dart';
// ...existing code...
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteMapScreen extends StatefulWidget {
  final RouteOption routeOption;
  const RouteMapScreen({super.key, required this.routeOption});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  List<Polyline> _routePolylines = [];
  List<Marker> _segmentMarkers = [];

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    // 1. Get route path points
    final points = widget.routeOption.routePath
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
    // 2. Load stop/segment data from Firestore
    final routeId = widget.routeOption.routeId;
    // Fetch stops
    final stopsSnapshot = await FirebaseFirestore.instance
        .collection('stops')
        .get();
    Map<String, LatLng> stopCoords = {};
    for (var doc in stopsSnapshot.docs) {
      final data = doc.data();
      final stopId = doc.id;
      final lat = data['lat']?.toDouble();
      final lng = data['lng']?.toDouble();
      if (lat != null && lng != null) {
        stopCoords[stopId] = LatLng(lat, lng);
      }
    }
    // Fetch route_stops (ordered stops for this route)
    final routeStopsSnapshot = await FirebaseFirestore.instance
        .collection('route_stops')
        .where('route_id', isEqualTo: routeId)
        .orderBy('order')
        .get();
    List<String> stopOrder = [];
    for (var doc in routeStopsSnapshot.docs) {
      final data = doc.data();
      final stopId = data['stop_id'];
      if (stopId != null) stopOrder.add(stopId);
    }
    // For demo: alternate walk/jeep for each stop (replace with real segment logic as needed)
    List<Marker> markers = [];
    for (int i = 0; i < stopOrder.length; i++) {
      final stopId = stopOrder[i];
      final coord = stopCoords[stopId];
      if (coord == null) continue;
      String type = (i % 2 == 0) ? 'walk' : 'jeep';
      String iconPath = type == 'walk'
          ? 'assets/icons/map_walking.png'
          : 'assets/icons/map_jeepney.png';
      markers.add(
        Marker(
          point: coord,
          width: 32,
          height: 32,
          child: Image.asset(iconPath, width: 32, height: 32),
        ),
      );
    }
    setState(() {
      _routePolylines = [
        Polyline(points: points, color: Colors.blue, strokeWidth: 5.0),
      ];
      _segmentMarkers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Map')),
      body: MapWidget(polylines: _routePolylines, markers: _segmentMarkers),
    );
  }
}
