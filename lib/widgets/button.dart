import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String buttonText;
  final onButtonTap;
  const Button({super.key, required this.color, required this.textColor, required this.buttonText, required this.onButtonTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onButtonTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: color,
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
