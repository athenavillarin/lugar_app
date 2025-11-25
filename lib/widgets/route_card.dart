import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: EdgeInsets.all(8), child: Text('Route')),
    );
  }
}
