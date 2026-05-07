import 'package:flutter/material.dart';
class CustomPaymentButton extends StatelessWidget {
  const CustomPaymentButton({
    super.key,
    required this.buttonColor,
    required this.textColor,
    required this.text,
    required this.onTap,
  });

  final Color buttonColor;
  final Color textColor;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}