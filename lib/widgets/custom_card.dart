import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;

  const CustomCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shadows = const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(colors: [Colors.white, Colors.grey[100]!]),
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
