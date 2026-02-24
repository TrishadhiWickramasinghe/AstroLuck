import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/lucky_number_model.dart';

class LuckyCard extends StatelessWidget {
  final LuckyNumbers luckyNumbers;

  const LuckyCard({super.key, required this.luckyNumbers});

  void _shareNumbers() {
    final message = '''
🌟 AstroLucky Daily Numbers 🌟

Primary Numbers: ${luckyNumbers.primaryNumbers.join(', ')}
Secondary Numbers: ${luckyNumbers.secondaryNumbers?.join(', ') ?? 'N/A'}
Lucky Digits: ${luckyNumbers.luckyDigits.join(', ')}

Energy Level: ${luckyNumbers.energyLevel}
Lucky Color: ${luckyNumbers.luckyColor}
Zodiac Influence: ${luckyNumbers.zodiacInfluence}

Generated on: ${DateTime.now().toLocal()}

#AstroLucky #LuckyNumbers
''';
    Share.share(message);
  }

  void _saveNumbers() {
    // Implement save to local storage
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'gold':
        return AppColors.gold;
      case 'purple':
        return AppColors.purple;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cosmicGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow effect
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎯 Today\'s Lucky Numbers',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _saveNumbers,
                          icon: const Icon(Icons.bookmark_border, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: _shareNumbers,
                          icon: const Icon(Icons.share, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Energy Indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Energy: ${luckyNumbers.energyLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getZodiacColor(luckyNumbers.zodiacInfluence),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        luckyNumbers.zodiacInfluence,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                // Primary Numbers
                Text(
                  'Primary Numbers',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: luckyNumbers.primaryNumbers.map((number) {
                    return _NumberBall(
                      number: number,
                      isPrimary: true,
                    );
                  }).toList(),
                ),
                
                // Secondary Numbers
                if (luckyNumbers.secondaryNumbers != null &&
                    luckyNumbers.secondaryNumbers!.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  Text(
                    'Secondary Numbers',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: luckyNumbers.secondaryNumbers!.map((number) {
                      return _NumberBall(
                        number: number,
                        isPrimary: false,
                      );
                    }).toList(),
                  ),
                ],
                
                // Lucky Digits
                const SizedBox(height: 25),
                Text(
                  'Lucky Digits (0-9)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: luckyNumbers.luckyDigits.map((digit) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Center(
                        child: Text(
                          digit.toString(),
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                // Footer
                const SizedBox(height: 25),
                Divider(color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.color_lens,
                          color: _getColorFromString(luckyNumbers.luckyColor),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lucky Color',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getZodiacColor(String zodiac) {
    switch (zodiac.toLowerCase()) {
      case 'aries': return AppColors.aries;
      case 'taurus': return AppColors.taurus;
      case 'gemini': return AppColors.gemini;
      case 'cancer': return AppColors.cancer;
      case 'leo': return AppColors.leo;
      case 'virgo': return AppColors.virgo;
      case 'libra': return AppColors.libra;
      case 'scorpio': return AppColors.scorpio;
      case 'sagittarius': return AppColors.sagittarius;
      case 'capricorn': return AppColors.capricorn;
      case 'aquarius': return AppColors.aquarius;
      case 'pisces': return AppColors.pisces;
      default: return AppColors.purple;
    }
  }
}

class _NumberBall extends StatelessWidget {
  final int number;
  final bool isPrimary;

  const _NumberBall({
    required this.number,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? AppColors.goldGradient
            : const LinearGradient(
                colors: [AppColors.purple, AppColors.lightPurple],
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? AppColors.gold.withOpacity(0.5)
                : AppColors.purple.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          
          // Number
          Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}