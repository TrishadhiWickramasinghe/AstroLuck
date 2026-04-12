import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../data/models/lucky_number_model.dart';
import 'custom_card.dart';

class LuckyNumberCard extends StatelessWidget {
  final List<int> primaryNumbers;
  final List<int>? secondaryNumbers;
  final String luckyColor;
  final String luckyColorHex;
  final String energyStatus;
  final String fortuneMessage;
  final int luckyHour;
  final String moonPhase;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const LuckyNumberCard({
    super.key,
    required this.primaryNumbers,
    this.secondaryNumbers,
    required this.luckyColor,
    required this.luckyColorHex,
    required this.energyStatus,
    required this.fortuneMessage,
    required this.luckyHour,
    required this.moonPhase,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return CustomCard(
      gradient: AppColors.cosmicGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✨ ${strings.yourLuckyNumbers}',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Primary Numbers
          Row(
            children: [
              Text(
                '${strings.primaryNumbers}:',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                children: primaryNumbers.map((num) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        num.toString(),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Secondary Numbers
          if (secondaryNumbers != null && secondaryNumbers!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${strings.secondaryNumbers}:',
                      style: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 6,
                      children: secondaryNumbers!.map((num) {
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.purple.withValues(alpha: 0.3),
                            border: Border.all(color: AppColors.purple, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              num.toString(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          
          // Lucky Time & Color
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.luckyHour,
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$luckyHour:00',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.luckyColorLabel,
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      luckyColor,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Fortune Message
          Text(
            fortuneMessage,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (onShare != null)
                ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 18),
                  label: Text(strings.shareNumbers),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkPurple,
                  ),
                ),
              if (onSave != null)
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save, size: 18),
                  label: Text(strings.saveNumbers),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: AppColors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
