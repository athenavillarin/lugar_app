import 'package:flutter/material.dart';

class StopCard extends StatelessWidget {
  const StopCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: EdgeInsets.all(8), child: Text('Stop')),
    );
  }
}
