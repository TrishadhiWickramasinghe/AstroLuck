// lib/features/intelligence/widgets/intelligence_widgets.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Intelligence Feature Cards and Widgets

/// Recommendation Badge - Shows Play/Wait/Caution status
class RecommendationBadge extends StatelessWidget {
  final String recommendation; // play, wait, be_cautious
  final double probability;

  const RecommendationBadge({
    required this.recommendation,
    required this.probability,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (recommendation) {
      case 'play':
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'wait':
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'be_cautious':
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        icon = Icons.warning;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recommendation.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(
                '${(probability * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: textColor, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Energy Level Indicator - Visual representation of daily energy
class EnergyLevelIndicator extends StatelessWidget {
  final int energyLevel; // 1-10
  final String? label;

  const EnergyLevelIndicator({
    required this.energyLevel,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (energyLevel / 10);
    final color = _getEnergyColor(energyLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(label!, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '$energyLevel/10',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getEnergyColor(int level) {
    if (level <= 3) return Colors.red;
    if (level <= 6) return Colors.orange;
    return Colors.green;
  }
}

/// Number Chip - For displaying lottery numbers
class LotteryNumberChip extends StatelessWidget {
  final int number;
  final bool isHot;
  final bool isCold;
  final bool isSelected;
  final VoidCallback? onTap;

  const LotteryNumberChip({
    required this.number,
    this.isHot = false,
    this.isCold = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
    } else if (isHot) {
      backgroundColor = Colors.red.withOpacity(0.3);
      textColor = Colors.red;
    } else if (isCold) {
      backgroundColor = Colors.blue.withOpacity(0.3);
      textColor = Colors.blue;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.2);
      textColor = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: textColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Numerology Card - Display single numerology number
class NumerologyCard extends StatelessWidget {
  final int number;
  final String title;
  final String meaning;
  final Color? color;

  const NumerologyCard({
    required this.number,
    required this.title,
    required this.meaning,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? _getNumberColor(number);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor.withOpacity(0.1), bgColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bgColor.withOpacity(0.3)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(meaning, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Color _getNumberColor(int number) {
    const colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[(number - 1) % colors.length];
  }
}

/// Hot/Cold Number Heatmap - Visual representation of frequencies
class NumberHeatmap extends StatelessWidget {
  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final Map<int, int> frequencies;
  final int totalNumbers; // Usually 49

  const NumberHeatmap({
    required this.hotNumbers,
    required this.coldNumbers,
    required this.frequencies,
    this.totalNumbers = 49,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: totalNumbers,
      itemBuilder: (context, index) {
        final number = index + 1;
        final isHot = hotNumbers.contains(number);
        final isCold = coldNumbers.contains(number);
        final frequency = frequencies[number] ?? 0;

        return _HeatmapTile(
          number: number,
          frequency: frequency,
          isHot: isHot,
          isCold: isCold,
        );
      },
    );
  }
}

class _HeatmapTile extends StatelessWidget {
  final int number;
  final int frequency;
  final bool isHot;
  final bool isCold;

  const _HeatmapTile({
    required this.number,
    required this.frequency,
    required this.isHot,
    required this.isCold,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (isHot) {
      color = Colors.red.withOpacity(Math.min(frequency / 10, 1.0).toDouble());
    } else if (isCold) {
      color = Colors.blue.withOpacity(0.3);
    } else {
      color = Colors.grey.withOpacity(0.2);
    }

    return Tooltip(
      message: 'Number $number: $frequency draws',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isHot ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stats Summary Card - Shows key statistics
class StatsSummaryCard extends StatelessWidget {
  final int totalPlays;
  final int totalWins;
  final double winRate;
  final int currentStreak;

  const StatsSummaryCard({
    required this.totalPlays,
    required this.totalWins,
    required this.winRate,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              icon: Icons.trending_up,
              label: 'Plays',
              value: '$totalPlays',
            ),
            _StatItem(
              icon: Icons.stars,
              label: 'Wins',
              value: '$totalWins',
            ),
            _StatItem(
              icon: Icons.percent,
              label: 'Win Rate',
              value: '${(winRate * 100).toStringAsFixed(1)}%',
            ),
            _StatItem(
              icon: Icons.local_fire_department,
              label: 'Streak',
              value: '$currentStreak',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 2),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

/// Affirmation Card - Display daily affirmation
class AffirmationCard extends StatelessWidget {
  final String affirmation;
  final String? author;

  const AffirmationCard({
    required this.affirmation,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.indigo.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 32),
            SizedBox(height: 16),
            Text(
              affirmation,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (author != null) ...[
              SizedBox(height: 12),
              Text(
                '— $author',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Insight Chip - Quick insight summary
class InsightChip extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? backgroundColor;

  const InsightChip({
    required this.title,
    required this.value,
    required this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.blue.withOpacity(0.1);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Loading Skeleton - While data loads
class IntelligenceLoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _SkeletonCard(height: 150),
          SizedBox(height: 16),
          _SkeletonCard(height: 100),
          SizedBox(height: 16),
          _SkeletonCard(height: 200),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;

  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Time Display Widget
class LuckyTimeWidget extends StatelessWidget {
  final String timeWindow; // e.g., "3:00 PM - 5:00 PM"

  const LuckyTimeWidget({required this.timeWindow});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.amber),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lucky Time", style: Theme.of(context).textTheme.bodySmall),
                Text(timeWindow, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
