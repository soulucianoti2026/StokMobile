import 'package:flutter/material.dart';

enum ButtonType { filled, outlined }

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.type,
    this.backgroundColor,
    this.textStyle,
    this.elevation,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _getStyle().copyWith(
        textStyle: textStyle == null ? null : WidgetStatePropertyAll(textStyle),
        elevation: elevation == null ? null : WidgetStatePropertyAll(elevation),
      ),
      child: Text(label),
    );
  }

  ButtonStyle _getStyle() {
    switch (type) {
      case ButtonType.filled:
        return ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: Colors.white,
          backgroundColor: backgroundColor ?? const Color(0xFF22C55E),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );

      case ButtonType.outlined:
        return ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: const Color(0xFF22C55E),
          backgroundColor: backgroundColor ?? Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF22C55E)),
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }
}
