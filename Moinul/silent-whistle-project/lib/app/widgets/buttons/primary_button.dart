import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap; 
  final Color color;
  final Color textColor;
  final double height;
  final double borderRadius;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onTap,
    this.color = const Color(0xFF38E07B),
    this.textColor = Colors.black,
    this.height = 55,
    this.borderRadius = 30,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      
      onTap: onTap, 
      child: Opacity(
        
        opacity: onTap == null ? 0.6 : 1.0, 
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}