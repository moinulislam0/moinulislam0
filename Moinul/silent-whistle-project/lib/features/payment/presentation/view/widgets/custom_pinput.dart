import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class CustomPinput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onCompleted;
  final String? Function(String?)? validator;
  final bool autoFocus;

  const CustomPinput({
    super.key,
    required this.controller,
    this.onCompleted,
    this.validator,
    this.autoFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    // --- Default Theme ---
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(40),
      ),
    );

    // --- Focused Theme ---
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF00C27A)),
      borderRadius: BorderRadius.circular(40),
    );
    // --- Submitted Theme ---
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey),
      ),
    );

    return Pinput(
      controller: controller,
      length: 6,
      autofocus: autoFocus,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      validator: validator,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: onCompleted,
    );
  }
}
