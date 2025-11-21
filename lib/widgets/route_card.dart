import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: EdgeInsets.all(8), child: Text('Route')),
    );
  }
}
