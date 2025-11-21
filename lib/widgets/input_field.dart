import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  const InputField({Key? key, this.hint = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(hintText: hint));
  }
}
