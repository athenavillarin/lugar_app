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
import '../../services/route_service.dart';

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
  double? _fromSelectedLat;
  double? _fromSelectedLng;
  double? _toSelectedLat;
  double? _toSelectedLng;
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
      // Geocode and store coordinates, but do NOT overwrite the text field
      NominatimService.searchPlaces(suggestion.name).then((results) {
        if (results.isNotEmpty) {
          final lat = results.first.lat;
          final lon = results.first.lon;
          setState(() {
            _fromSelectedLat = lat;
            _fromSelectedLng = lon;
          });
        }
      });
    }
    _fromFocusNode.unfocus();
    setState(() => _fromPlaceSuggestions = []);
  }

  void _handleToSuggestion(LocationSuggestion suggestion) {
    if (suggestion.name == 'Your location') {
      _setCurrentLocation(isFrom: false);
    } else {
      _toController.text = suggestion.name;
      // Geocode and store coordinates, but do NOT overwrite the text field
      NominatimService.searchPlaces(suggestion.name).then((results) {
        if (results.isNotEmpty) {
          final lat = results.first.lat;
          final lon = results.first.lon;
          setState(() {
            _toSelectedLat = lat;
            _toSelectedLng = lon;
          });
        }
      });
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

  Future<void> _findRoute() async {
    print('DEBUG: _findRoute called');
    if (!_isFormValid) {
      print('DEBUG: _findRoute exited early, form not valid');
      return;
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
    print('DEBUG: fromInput = "$fromInput"');
    print('DEBUG: toInput = "$toInput"');
    LatLng? fromCoord;
    LatLng? toCoord;
    if (_fromSelectedLat != null && _fromSelectedLng != null) {
      fromCoord = LatLng(_fromSelectedLat!, _fromSelectedLng!);
      print('DEBUG: Using _fromSelectedLat/Lng for fromCoord');
    } else {
      fromCoord = await getLatLng(fromInput);
    }
    if (_toSelectedLat != null && _toSelectedLng != null) {
      toCoord = LatLng(_toSelectedLat!, _toSelectedLng!);
      print('DEBUG: Using _toSelectedLat/Lng for toCoord');
    } else {
      toCoord = await getLatLng(toInput);
    }
    print('DEBUG: fromCoord = ${fromCoord?.latitude}, ${fromCoord?.longitude}');
    print('DEBUG: toCoord = ${toCoord?.latitude}, ${toCoord?.longitude}');
    if (fromCoord == null || toCoord == null) {
      print('DEBUG: One or both coordinates are null.');
      setState(() {
        _routeOptions.clear();
        _showRouteResults = true;
      });
      return;
    }

    // Call the service
    final options = await findRoutes(
      fromCoord.latitude,
      fromCoord.longitude,
      toCoord.latitude,
      toCoord.longitude,
    );

    setState(() {
      print('Matched route count: ${options.length}');
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
