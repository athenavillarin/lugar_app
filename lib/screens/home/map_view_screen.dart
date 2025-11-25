import 'package:flutter/material.dart';
import '../../widgets/map_widget.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: const MapWidget(),
    );
  }
}
