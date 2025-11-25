import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/map_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'route_sheet.dart';
import '../models/location_suggestion.dart';
import '../../services/nominatim_service.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_option.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _setCurrentLocation({required bool isFrom}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude;
      final lng = position.longitude;
      String locationString = '($lat, $lng)';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          locationString = [
            if (p.name != null && p.name!.isNotEmpty) p.name,
            if (p.subLocality != null && p.subLocality!.isNotEmpty)
              p.subLocality,
            if (p.locality != null && p.locality!.isNotEmpty) p.locality,
            if (p.administrativeArea != null &&
                p.administrativeArea!.isNotEmpty)
              p.administrativeArea,
            if (p.country != null && p.country!.isNotEmpty) p.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (e) {
        // If reverse geocoding fails, fallback to coordinates
      }
      setState(() {
        if (isFrom) {
          _fromController.text = locationString;
        } else {
          _toController.text = locationString;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get current location: $e')),
        );
      }
    }
  }

  void _chooseOnMapTo() {
    _toFocusNode.unfocus();
    setState(() {
      _isMapSelectionMode = true;
      _activeField = 'to';
    });
  }

  String? _activeField;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();
  bool _isFromFocused = false;
  bool _isToFocused = false;
  bool _isMapSelectionMode = false;
  List<NominatimPlace> _fromPlaceSuggestions = [];
  List<NominatimPlace> _toPlaceSuggestions = [];
  LatLng? _mapCenter;
  final List<Polyline> _routePolylines = [];
  final List<Marker> _segmentMarkers = [];
  bool _showRouteResults = false;
  FareType _selectedFareType = FareType.regular;
  final List<RouteOption> _routeOptions = [];

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_onFromTextChanged);
    _toController.addListener(_onToTextChanged);
    _fromFocusNode.addListener(_onFromFocusChanged);
    _toFocusNode.addListener(_onToFocusChanged);
    _injectDemoRouteOptions(); // TODO: REMOVE DEMO DATA AFTER VERIFICATION
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  void _handleFromSuggestion(LocationSuggestion suggestion) {
    if (suggestion.name == 'Your location') {
      _setCurrentLocation(isFrom: true);
    } else {
      _fromController.text = suggestion.name;
    }
    _fromFocusNode.unfocus();
    setState(() => _fromPlaceSuggestions = []);
  }

  void _handleToSuggestion(LocationSuggestion suggestion) {
    if (suggestion.name == 'Your location') {
      _setCurrentLocation(isFrom: false);
    } else {
      _toController.text = suggestion.name;
    }
    _toFocusNode.unfocus();
    setState(() => _toPlaceSuggestions = []);
  }

  void _handleChooseOnMapTo() {
    _chooseOnMapTo();
    setState(() => _toPlaceSuggestions = []);
  }

  Future<void> _onFromTextChanged() async {
    final query = _fromController.text;
    if (query.isEmpty) {
      setState(() {
        _fromPlaceSuggestions = [];
      });
      return;
    }
    final results = await NominatimService.searchPlaces(query);
    setState(() {
      _fromPlaceSuggestions = results;
      if (_showRouteResults) {
        _showRouteResults = false;
      }
    });
  }

  Future<void> _onToTextChanged() async {
    final query = _toController.text;
    if (query.isEmpty) {
      setState(() {
        _toPlaceSuggestions = [];
      });
      return;
    }
    final results = await NominatimService.searchPlaces(query);
    setState(() {
      _toPlaceSuggestions = results;
      if (_showRouteResults) {
        _showRouteResults = false;
      }
    });
  }

  void _onFromFocusChanged() {
    if (_fromFocusNode.hasFocus) {
      setState(() {
        _isFromFocused = true;
      });
      // Expand the sheet when focused
      _sheetController.animateTo(
        0.85,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Delay hiding the dropdown to allow tap events to register
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isFromFocused = _fromFocusNode.hasFocus;
          });
        }
      });
    }
  }

  void _onToFocusChanged() {
    if (_toFocusNode.hasFocus) {
      setState(() {
        _isToFocused = true;
      });
      // Expand the sheet when focused
      _sheetController.animateTo(
        0.85,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Delay hiding the dropdown to allow tap events to register
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isToFocused = _toFocusNode.hasFocus;
          });
        }
      });
    }
  }

  bool get _isFormValid =>
      _fromController.text.trim().isNotEmpty &&
      _toController.text.trim().isNotEmpty;

  void _swapLocations() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  void _chooseOnMapFrom() {
    _fromFocusNode.unfocus();
    setState(() {
      _isMapSelectionMode = true;
      _activeField = 'from';
    });
  }

  Future<void> _onMapLocationSelected(LatLng latLng) async {
    String locationString = '(${latLng.latitude}, ${latLng.longitude})';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        locationString = [
          if (p.name != null && p.name!.isNotEmpty) p.name,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea,
          if (p.country != null && p.country!.isNotEmpty) p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (e) {
      // fallback to coordinates
    }
    setState(() {
      if (_activeField == 'from') {
        _fromController.text = locationString;
      } else if (_activeField == 'to') {
        _toController.text = locationString;
      }
      _isMapSelectionMode = false;
      _activeField = null;
    });
  }

  void _cancelMapSelection() {
    setState(() {
      _isMapSelectionMode = false;
      _activeField = null;
    });
  }

  // Temporary demo route data for frontend verification only.
  // TODO: REMOVE THIS WHEN REAL DATASET INTEGRATION IS READY.
  void _injectDemoRouteOptions() {
    if (_routeOptions.isNotEmpty)
      return; // Avoid overwriting actual fetched data.
    final demo = [
      RouteOption(
        routeId: 'DEMO_R1',
        routePath: const [
          RoutePoint(latitude: 10.7202, longitude: 122.5621),
          RoutePoint(latitude: 10.7230, longitude: 122.5650),
        ],
        duration: '20 mins',
        regularFare: 12.00,
        discountedFare: 10.00,
        segments: const [
          TransportSegment(icon: Icons.directions_walk, type: 'Walk'),
          TransportSegment(icon: Icons.directions_bus, type: 'Jeepney'),
        ],
        timeline: const [
          TimelinePoint(label: 'Start', time: '8:00 am'),
          TimelinePoint(
            label: 'Checkpoint 1',
            time: '8:05 am',
            isCheckpoint: true,
          ),
          TimelinePoint(label: 'Destination', time: '8:20 am'),
        ],
      ),
      RouteOption(
        routeId: 'DEMO_R2',
        routePath: const [
          RoutePoint(latitude: 10.7202, longitude: 122.5621),
          RoutePoint(latitude: 10.7255, longitude: 122.5675),
        ],
        duration: '40 mins',
        regularFare: 24.00,
        discountedFare: 20.00,
        segments: const [
          TransportSegment(icon: Icons.directions_bus, type: 'Jeepney'),
          TransportSegment(icon: Icons.directions_walk, type: 'Walk'),
          TransportSegment(icon: Icons.directions_bus, type: 'Jeepney'),
        ],
        timeline: const [
          TimelinePoint(label: 'Start', time: '8:00 am'),
          TimelinePoint(
            label: 'Checkpoint 1',
            time: '8:10 am',
            isCheckpoint: true,
          ),
          TimelinePoint(
            label: 'Checkpoint 2',
            time: '8:20 am',
            isCheckpoint: true,
          ),
          TimelinePoint(label: 'Destination', time: '8:40 am'),
        ],
      ),
    ];
    setState(() {
      _routeOptions.addAll(demo);
      _showRouteResults = true;
    });
  }

  Future<void> _findRoute() async {
    if (!_isFormValid) return;

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

    // 1. Get coordinates for from/to
    Future<LatLng?> getLatLng(String input) async {
      final regex = RegExp(r'\(([-\d.]+),\s*([-\d.]+)\)');
      final match = regex.firstMatch(input);
      if (match != null) {
        return LatLng(
          double.parse(match.group(1)!),
          double.parse(match.group(2)!),
        );
      }
      // Otherwise, geocode
      try {
        final results = await NominatimService.searchPlaces(input);
        if (results.isNotEmpty) {
          return LatLng(results.first.lat, results.first.lon);
        }
      } catch (_) {}
      return null;
    }

    final fromInput = _fromController.text.trim();
    final toInput = _toController.text.trim();
    final fromCoord = await getLatLng(fromInput);
    final toCoord = await getLatLng(toInput);
    if (fromCoord == null || toCoord == null) {
      setState(() {
        _routeOptions.clear();
        _showRouteResults = true;
      });
      return;
    }

    // 2. Fetch stops from Firestore
    final stopsSnapshot = await FirebaseFirestore.instance
        .collection('stops')
        .get();
    final stops = <String, Map<String, dynamic>>{};
    for (var doc in stopsSnapshot.docs) {
      final data = doc.data();
      stops[doc.id] = {
        'id': doc.id,
        'name': data['name'] ?? '',
        'lat': data['lat']?.toDouble() ?? 0,
        'lng': data['lng']?.toDouble() ?? 0,
      };
    }
    if (stops.isEmpty) {
      setState(() {
        _routeOptions.clear();
        _showRouteResults = true;
      });
      return;
    }

    // 3. Find nearest stop to fromCoord and toCoord
    String? nearestFromStopId;
    String? nearestToStopId;
    double minFromDist = double.infinity;
    double minToDist = double.infinity;
    stops.forEach((id, stop) {
      final lat = stop['lat'] as double;
      final lng = stop['lng'] as double;
      final fromDist = haversine(
        fromCoord.latitude,
        fromCoord.longitude,
        lat,
        lng,
      );
      if (fromDist < minFromDist) {
        minFromDist = fromDist;
        nearestFromStopId = id;
      }
      final toDist = haversine(toCoord.latitude, toCoord.longitude, lat, lng);
      if (toDist < minToDist) {
        minToDist = toDist;
        nearestToStopId = id;
      }
    });

    if (nearestFromStopId == null || nearestToStopId == null) {
      setState(() {
        _routeOptions.clear();
        _showRouteResults = true;
      });
      return;
    }

    // 4. Find all routes that include both stops
    final routeStopsSnapshot = await FirebaseFirestore.instance
        .collection('route_stops')
        .get();
    // Map routeId -> list of stopIds (ordered)
    final Map<String, List<String>> routeToStops = {};
    for (var doc in routeStopsSnapshot.docs) {
      final data = doc.data();
      final routeId = data['route_id'];
      final stopId = data['stop_id'];
      if (routeId != null && stopId != null) {
        routeToStops.putIfAbsent(routeId, () => []).add(stopId);
      }
    }

    // Find routes that contain both stops
    final matchingRouteIds = routeToStops.entries
        .where((entry) {
          final stopsList = entry.value;
          return stopsList.contains(nearestFromStopId) &&
              stopsList.contains(nearestToStopId);
        })
        .map((e) => e.key)
        .toList();

    if (matchingRouteIds.isEmpty) {
      setState(() {
        _routeOptions.clear();
        _showRouteResults = true;
      });
      return;
    }

    // 5. Fetch route details
    final routesSnapshot = await FirebaseFirestore.instance
        .collection('routes')
        .get();
    final matchingRoutes = routesSnapshot.docs
        .where((doc) => matchingRouteIds.contains(doc.id))
        .toList();

    // 6. Build RouteOption(s)
    List<RouteOption> options = matchingRoutes.map((doc) {
      final data = doc.data();
      final routeId = doc.id;
      final stopsList = routeToStops[routeId] ?? [];
      // Build routePath as list of RoutePoint from stopsList
      List<RoutePoint> routePath = stopsList.map((sid) {
        final stop = stops[sid];
        return RoutePoint(
          latitude: stop?['lat'] ?? 0,
          longitude: stop?['lng'] ?? 0,
        );
      }).toList();
      // Use static fares for now
      double regularFare = 15.0;
      double discountedFare = 12.0;
      // Segments and timeline (simple demo)
      final segments = [
        TransportSegment(icon: Icons.directions_walk, type: 'Walk'),
        TransportSegment(icon: Icons.directions_bus, type: 'Jeepney'),
      ];
      final timeline = [
        TimelinePoint(label: 'Start', time: '8:00 am'),
        TimelinePoint(
          label: 'Checkpoint 1',
          time: '8:10 am',
          isCheckpoint: true,
        ),
        TimelinePoint(label: 'Destination', time: '8:20 am'),
      ];
      return RouteOption(
        routeId: routeId,
        routePath: routePath,
        duration: (data['duration']?.toString() ?? '20') + ' mins',
        regularFare: regularFare,
        discountedFare: discountedFare,
        segments: segments,
        timeline: timeline,
      );
    }).toList();

    setState(() {
      _routeOptions
        ..clear()
        ..addAll(options);
      _showRouteResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always show Iloilo-related suggestions at the top, and only show the name
    List<LocationSuggestion> sortedFromSuggestions = _fromPlaceSuggestions
        .map((p) => LocationSuggestion(name: p.displayName, address: ''))
        .toList();
    sortedFromSuggestions.sort((a, b) {
      final aIloilo = a.name.toLowerCase().contains('iloilo');
      final bIloilo = b.name.toLowerCase().contains('iloilo');
      if (aIloilo && !bIloilo) return -1;
      if (!aIloilo && bIloilo) return 1;
      return 0;
    });

    List<LocationSuggestion> sortedToSuggestions = _toPlaceSuggestions
        .map((p) => LocationSuggestion(name: p.displayName, address: ''))
        .toList();
    sortedToSuggestions.sort((a, b) {
      final aIloilo = a.name.toLowerCase().contains('iloilo');
      final bIloilo = b.name.toLowerCase().contains('iloilo');
      if (aIloilo && !bIloilo) return -1;
      if (!aIloilo && bIloilo) return 1;
      return 0;
    });

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            MapWidget(
              isSelectionMode: _isMapSelectionMode,
              onLocationSelected: _onMapLocationSelected,
              onCancel: _cancelMapSelection,
              polylines: _routePolylines,
              markers: _segmentMarkers,
              center: _mapCenter ?? const LatLng(10.7202, 122.5621),
            ),
            // RouteSheet overlay (now with controller)
            RouteSheet(
              fromController: _fromController,
              toController: _toController,
              fromFocusNode: _fromFocusNode,
              toFocusNode: _toFocusNode,
              isFormValid: _isFormValid,
              onSwap: _swapLocations,
              onFindRoute: _findRoute,
              fromSuggestions: sortedFromSuggestions,
              toSuggestions: sortedToSuggestions,
              showFromDropdown:
                  _isFromFocused &&
                  _fromController.text.isNotEmpty &&
                  _fromPlaceSuggestions.isNotEmpty,
              showToDropdown:
                  _isToFocused &&
                  _toController.text.isNotEmpty &&
                  _toPlaceSuggestions.isNotEmpty,
              onSelectFromLocation: _handleFromSuggestion,
              onSelectToLocation: _handleToSuggestion,
              onChooseOnMapFrom: _chooseOnMapFrom,
              onChooseOnMapTo: _handleChooseOnMapTo,
              isMapSelectionMode: _isMapSelectionMode,
              showResults: _showRouteResults,
              routeOptions: _routeOptions,
              selectedFareType: _selectedFareType,
              onFareTypeChanged: (type) {
                setState(() {
                  _selectedFareType = type;
                });
              },
              sheetController: _sheetController,
            ),
          ],
        ),
      ),
    );
  }
}
