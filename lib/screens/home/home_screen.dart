import 'package:flutter/material.dart';
import 'map_placeholder.dart';
import 'route_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fromController.addListener(() => setState(() {}));
    _toController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _fromController.text.trim().isNotEmpty &&
      _toController.text.trim().isNotEmpty;

  void _swapLocations() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  void _findRoute() {
    if (_isFormValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Finding route...')));
      // TODO: Implement route finding logic / navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MapPlaceholder(),
          RouteSheet(
            fromController: _fromController,
            toController: _toController,
            isFormValid: _isFormValid,
            onSwap: _swapLocations,
            onFindRoute: _findRoute,
          ),
        ],
      ),
    );
  }
}
