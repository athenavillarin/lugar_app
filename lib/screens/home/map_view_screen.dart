import 'package:flutter/material.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map View')),
      body: Center(child: Text('Map View Screen')),
    );
  }
}
