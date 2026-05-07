import 'package:flutter/material.dart';

class CustomTextFieldPaymentView extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller; // Added controller
  final TextInputType? keyboardType;       // Added keyboard type (for phone numbers)

  const CustomTextFieldPaymentView({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,       // Connect controller here
      keyboardType: keyboardType,   // Connect keyboard type here
      style: const TextStyle(color: Colors.white), // Ensure text is visible on dark background
      decoration: InputDecoration(
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xff777980),
        ),
        fillColor: const Color(0Xff101010),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0Xff101010)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0Xff101010)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xff38E07B)), // Optional: green border when focused
        ),
      ),
    );
  }
}