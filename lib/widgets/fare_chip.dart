import 'package:flutter/material.dart';

class FareChip extends StatelessWidget {
  final String text;
  const FareChip({super.key, this.text = ''});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}
