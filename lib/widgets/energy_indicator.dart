import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';

class EnergyIndicator extends StatelessWidget {
  final int energyLevel;
  final String energyStatus;
  final double size;
  final bool showPercentage;

  const EnergyIndicator({
    super.key,
    required this.energyLevel,
    required this.energyStatus,
    this.size = 120,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isHighEnergy = energyLevel >= 70;
    final isMediumEnergy = energyLevel >= 40 && energyLevel < 70;

    final statusText = isHighEnergy
      ? strings.highEnergy
      : isMediumEnergy
        ? strings.mediumEnergy
        : strings.lowEnergy;
    final displayStatus = strings.locale.languageCode == 'en'
      ? energyStatus
      : statusText;
    
    Color getEnergyColor() {
      if (isHighEnergy) return AppColors.highEnergy;
      if (isMediumEnergy) return AppColors.mediumEnergy;
      return AppColors.lowEnergy;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            // Progress ring
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: energyLevel / 100,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(getEnergyColor()),
                backgroundColor: AppColors.darkPurple.withOpacity(0.3),
              ),
            ),
            // Center content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showPercentage)
                  Text(
                    '${energyLevel.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: getEnergyColor(),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  statusText,
                  style: TextStyle(
                    color: getEnergyColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          displayStatus,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.lightGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
