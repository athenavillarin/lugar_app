import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/map_widget.dart';
import '../models/route_option.dart';
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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
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
          width: 56, // Increased size from 48 to 56
          height: 56, // Increased size from 48 to 56
          child: Image.asset(
            iconPath,
            width: 56, // Match the Marker size
            height: 56, // Match the Marker size
          ), // Adjusted icon size
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

  void _minimizeSheet() {
    _sheetController.animateTo(
      0.15,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Map view in background
          MapWidget(polylines: _routePolylines, markers: _segmentMarkers),

          // Back button positioned at top-left
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // Draggable bottom sheet with route details
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.6,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Route details content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fare header card
                          _FareHeaderCard(),

                          const SizedBox(height: 16),

                          // Timeline header
                          _TimelineHeader(),

                          const SizedBox(height: 16),

                          // Walk segment
                          _TransportSegmentCard(
                            icon: Icons.directions_walk,
                            title: 'Walk (375m) 5 min',
                            isWalkSegment: true,
                          ),

                          const SizedBox(height: 16),

                          // Jeep segment
                          _TransportSegmentCard(
                            icon: Icons.directions_bus,
                            title: 'Jeep (2km)  P 12.00   15 mins',
                            isWalkSegment: false,
                          ),

                          const SizedBox(height: 24),

                          // See Map button with favorite button
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 49,
                                  child: ElevatedButton(
                                    onPressed: _minimizeSheet,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'See Map',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 49,
                                height: 49,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.star_border),
                                  onPressed: () {},
                                  color: theme.colorScheme.onSurface,
                                  iconSize: 24,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Find new route button
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Find new route',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FareHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fare amount
          const Text(
            'P 12.00',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 20),

          // Timeline row with three points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimelinePoint(
                icon: Icons.directions_walk,
                label: 'Start',
                time: '8:00 PM',
                color: primaryBlue,
                isFilled: true,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: primaryBlue,
                ),
              ),
              _TimelinePoint(
                icon: Icons.directions_bus,
                label: 'Checkpoint 1',
                time: '8:05 PM',
                color: primaryBlue,
                isFilled: false,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: primaryBlue.withOpacity(0.3),
                ),
              ),
              _TimelinePoint(
                icon: Icons.location_on,
                label: 'Destination',
                time: '8:20 PM',
                color: primaryBlue.withOpacity(0.3),
                isFilled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelinePoint extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;
  final bool isFilled;

  const _TimelinePoint({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
    required this.isFilled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? color : Colors.white,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, size: 16, color: isFilled ? Colors.white : color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            fontSize: 9,
            color: color.withOpacity(0.7),
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportSegmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isWalkSegment;

  const _TransportSegmentCard({
    required this.icon,
    required this.title,
    required this.isWalkSegment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2024),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: isWalkSegment
                ? _WalkSegmentContent()
                : _JeepSegmentContent(),
          ),
        ],
      ),
    );
  }
}

class _WalkSegmentContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Text(
            'Robinsons Place Pavia',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Progress line
                  Container(height: 2, color: primaryBlue.withOpacity(0.3)),
                  // Filled progress
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    alignment: Alignment.centerLeft,
                    child: Container(height: 2, color: primaryBlue),
                  ),
                  // Progress indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Expanded(
          flex: 2,
          child: Text(
            'GT Mall Pavia',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }
}

class _JeepSegmentContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route info
        Row(
          children: [
            Icon(Icons.swap_vert, color: primaryBlue, size: 20),
            const SizedBox(width: 8),
            const Text(
              'ROUTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Ungka to City Proper via CPU',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Get On info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              child: Icon(Icons.circle, color: primaryBlue, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'GET ON',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(width: 24),
            const Expanded(
              child: Text(
                'GT Mall Pavia',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Connector line
        Padding(
          padding: const EdgeInsets.only(left: 7),
          child: Container(
            width: 2,
            height: 20,
            color: primaryBlue.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 12),

        // Get Off info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              child: Icon(Icons.circle_outlined, color: primaryBlue, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'GET OFF',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Jaro Plaza',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
