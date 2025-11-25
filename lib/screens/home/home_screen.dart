import 'package:flutter/material.dart';
import '../../widgets/map_widget.dart';
import 'route_sheet.dart';
import '../models/location_suggestion.dart';
import 'temp_locations.dart';
import '../models/route_option.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  List<LocationSuggestion> _fromSuggestions = [];
  List<LocationSuggestion> _toSuggestions = [];
  bool _isFromFocused = false;
  bool _isToFocused = false;
  bool _isMapSelectionMode = false;
  String? _activeField; // 'from' or 'to'

  // Route Results State
  bool _showRouteResults = false;
  FareType _selectedFareType = FareType.regular;
  List<RouteOption> _routeOptions = [];

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

  void _onFromTextChanged() {
    setState(() {
      _fromSuggestions = TempLocations.searchLocations(_fromController.text);
      if (_showRouteResults) {
        _showRouteResults = false;
      }
    });
  }

  void _onToTextChanged() {
    setState(() {
      _toSuggestions = TempLocations.searchLocations(_toController.text);
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

  void _selectFromLocation(LocationSuggestion location) {
    _fromController.text = location.name;
    _fromFocusNode.unfocus();
    setState(() {
      _fromSuggestions = [];
    });
  }

  void _selectToLocation(LocationSuggestion location) {
    _toController.text = location.name;
    _toFocusNode.unfocus();
    setState(() {
      _toSuggestions = [];
    });
  }

  void _chooseOnMapFrom() {
    _fromFocusNode.unfocus();
    setState(() {
      _isMapSelectionMode = true;
      _activeField = 'from';
      _fromSuggestions = [];
    });
  }

  void _chooseOnMapTo() {
    _toFocusNode.unfocus();
    setState(() {
      _isMapSelectionMode = true;
      _activeField = 'to';
      _toSuggestions = [];
    });
  }

  void _onMapLocationSelected(String locationName) {
    if (_activeField == 'from') {
      _fromController.text = locationName;
    } else if (_activeField == 'to') {
      _toController.text = locationName;
    }
    setState(() {
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

  void _findRoute() {
    if (_isFormValid) {
      // Mock data generation
      setState(() {
        _showRouteResults = true;
        _routeOptions = [
          RouteOption(
            duration: '20 mins',
            regularFare: 15.00,
            discountedFare: 12.00,
            segments: [
              TransportSegment(icon: Icons.directions_walk, type: 'walk'),
              TransportSegment(icon: Icons.directions_bus, type: 'jeep'),
            ],
            timeline: [
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
            duration: '40 mins',
            regularFare: 30.00,
            discountedFare: 24.00,
            segments: [
              TransportSegment(icon: Icons.directions_bus, type: 'jeep'),
              TransportSegment(icon: Icons.directions_walk, type: 'walk'),
              TransportSegment(icon: Icons.directions_bus, type: 'jeep'),
            ],
            timeline: [
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            isSelectionMode: _isMapSelectionMode,
            onLocationSelected: _onMapLocationSelected,
            onCancel: _cancelMapSelection,
          ),
          RouteSheet(
            fromController: _fromController,
            toController: _toController,
            fromFocusNode: _fromFocusNode,
            toFocusNode: _toFocusNode,
            isFormValid: _isFormValid,
            onSwap: _swapLocations,
            onFindRoute: _findRoute,
            fromSuggestions: _fromSuggestions,
            toSuggestions: _toSuggestions,
            showFromDropdown: _isFromFocused && _fromSuggestions.isNotEmpty,
            showToDropdown: _isToFocused && _toSuggestions.isNotEmpty,
            onSelectFromLocation: _selectFromLocation,
            onSelectToLocation: _selectToLocation,
            onChooseOnMapFrom: _chooseOnMapFrom,
            onChooseOnMapTo: _chooseOnMapTo,
            isMapSelectionMode: _isMapSelectionMode,
            showResults: _showRouteResults,
            routeOptions: _routeOptions,
            selectedFareType: _selectedFareType,
            onFareTypeChanged: (type) {
              setState(() {
                _selectedFareType = type;
              });
            },
          ),
        ],
      ),
    );
  }
}
