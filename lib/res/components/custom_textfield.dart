import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController? textController;
  final Color textColor;
  final Color borderColor;
  final bool obscureText;
  const CustomTextField({
    super.key,
    required this.hint,
    this.textController,
    this.textColor = Colors.black,
    this.borderColor = Colors.black,
    bool? readOnly,
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textController,
      cursorColor: Colors.blue,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
          isDense: true,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: widget.borderColor,
          )),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: widget.borderColor,
          )),
          border: OutlineInputBorder(
              borderSide: BorderSide(
            color: widget.borderColor,
          )),
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: widget.textColor,
          )),
    );
  }
}
