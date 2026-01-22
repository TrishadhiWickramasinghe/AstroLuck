import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String? label;
  final String? text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final IconData? icon;
  final bool isOutlined;

  const PrimaryButton({
    super.key,
    this.label,
    this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFD4AF37),
    this.textColor = Colors.white,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonLabel = label ?? text ?? 'Button';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : backgroundColor,
            border: isOutlined ? Border.all(color: backgroundColor, width: 2) : null,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor),
                const SizedBox(width: 8),
              ],
              Text(
                buttonLabel,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
