import 'package:flutter/material.dart';

class FareChip extends StatelessWidget {
  final String text;
  const FareChip({Key? key, this.text = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}
