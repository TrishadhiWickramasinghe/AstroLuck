import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EnergyIndicator extends StatelessWidget {
  final EnergyLevel level;

  const EnergyIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      switch (level) {
        case EnergyLevel.low:
          return Colors.red;
        case EnergyLevel.medium:
          return Colors.yellow;
        case EnergyLevel.high:
          return Colors.green;
      }
    }
g
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: getColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            level.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              color: getColor(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

enum EnergyLevel { low, medium, high }