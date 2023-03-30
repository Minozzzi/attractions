import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  final Color? buttonColor;
  final Color? iconColor;
  final String? label;

  const FloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.buttonColor,
    this.iconColor,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: buttonColor ?? Theme.of(context).primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.white,
          ),
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                color: iconColor ?? Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
