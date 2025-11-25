import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  const InputField({super.key, this.hint = ''});

  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(hintText: hint));
  }
}
