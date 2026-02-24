import 'package:flutter/material.dart';

class EnergyIndicator extends StatelessWidget {
  final int level;

  const EnergyIndicator({super.key, required this.level});

  Color _getColor() {
    if (level < 33) return Colors.red;
    if (level < 66) return Colors.orange;
    return Colors.green;
  }

  String _getLevelText() {
    if (level < 33) return 'LOW';
    if (level < 66) return 'MEDIUM';
    return 'HIGH';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _getColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _getLevelText(),
            style: TextStyle(
              color: _getColor(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}