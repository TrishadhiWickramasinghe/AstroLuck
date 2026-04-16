// lib/features/intelligence/screens/ai_insights_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../../../widgets/custom_card.dart';

class AIInsightsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends ConsumerState<AIInsightsScreen> {
  final ApiClient _api = ApiClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Daily Insights'),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _api.generateDailyAIInsight(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final insight = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight['title'] ?? 'Daily Insight',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 4),
                                Text(insight['date'] ?? DateTime.now().toString().split(' ')[0],
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getMoodColor(insight['mood'])
                                      .withOpacity(0.2),
                                ),
                                child: Center(
                                  child: Text(
                                    _getMoodEmoji(insight['mood']),
                                    style: TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Energy: ${insight['energy_level']}/10',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(insight['description'] ?? 'Loading your personalized insight...',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Horoscope
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today\'s Horoscope',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Text(insight['horoscope'] ?? 'Horoscope loading...',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Lottery Recommendations
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lottery Recommendation',
                              style: Theme.of(context).textTheme.titleLarge),
                          _RecommendationBadge(
                            recommendation: insight['lottery_recommendation'] ?? 'wait',
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text('Recommended Numbers:',
                          style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (insight['recommended_numbers'] as List?)
                                ?.map((num) => Chip(
                                  label: Text('$num'),
                                  backgroundColor: Colors.green.withOpacity(0.3),
                                ))
                                .toList() ??
                            [],
                      ),
                      SizedBox(height: 12),
                      Text('Avoid Numbers:',
                          style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (insight['avoid_numbers'] as List?)
                                ?.map((num) => Chip(
                                  label: Text('$num'),
                                  backgroundColor: Colors.red.withOpacity(0.3),
                                ))
                                .toList() ??
                            [],
                      ),
                      SizedBox(height: 12),
                      Text('Best Time: ${insight['best_time_of_day'] ?? 'afternoon'}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Planetary Influence
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Planetary Influence',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Chip(
                        label: Text('Ruling Planet: ${insight['ruling_planet'] ?? 'Unknown'}'),
                        backgroundColor: Colors.purple.withOpacity(0.2),
                      ),
                      SizedBox(height: 8),
                      Text(insight['planetary_influence'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Health & Wellness
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wellness Advice',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 12),
                      _AdviceItem(
                        icon: Icons.favorite,
                        title: 'Health',
                        content: insight['health_advice'] ?? '',
                      ),
                      SizedBox(height: 12),
                      _AdviceItem(
                        icon: Icons.psychology,
                        title: 'Meditation',
                        content: insight['meditation_recommendation'] ?? '',
                      ),
                      SizedBox(height: 12),
                      _AdviceItem(
                        icon: Icons.air,
                        title: 'Breathing',
                        content: insight['breathing_exercise'] ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Financial Advice
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financial Forecast',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Chip(
                        label: Text('Outlook: ${insight['spending_forecast'] ?? 'moderate'}'),
                        backgroundColor: Colors.amber.withOpacity(0.2),
                      ),
                      SizedBox(height: 8),
                      Text(insight['financial_advice'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Lucky Items
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lucky Items',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 12),
                      _LuckyItem(
                        icon: '🎨',
                        title: 'Color',
                        value: insight['lucky_color_of_day'] ?? 'Unknown',
                      ),
                      SizedBox(height: 8),
                      _LuckyItem(
                        icon: '💎',
                        title: 'Gemstone',
                        value: insight['lucky_gemstone'] ?? 'Unknown',
                      ),
                      SizedBox(height: 8),
                      _LuckyItem(
                        icon: '🌸',
                        title: 'Scent',
                        value: insight['lucky_scent'] ?? 'Unknown',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Daily Affirmation
                CustomCard(
                  child: Column(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 40),
                      SizedBox(height: 12),
                      Text('Daily Affirmation',
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      Text(
                        insight['daily_affirmation'] ?? 'You are blessed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMoodEmoji(String? mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Neutral':
        return '😐';
      case 'Cautious':
        return '😟';
      case 'Energetic':
        return '🤩';
      case 'Reflective':
        return '🤔';
      default:
        return '🌟';
    }
  }

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case 'Happy':
        return Colors.yellow;
      case 'Neutral':
        return Colors.grey;
      case 'Cautious':
        return Colors.orange;
      case 'Energetic':
        return Colors.red;
      case 'Reflective':
        return Colors.indigo;
      default:
        return Colors.purple;
    }
  }
}

class _RecommendationBadge extends StatelessWidget {
  final String recommendation;

  const _RecommendationBadge({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (recommendation) {
      case 'play':
        bgColor = Colors.green;
        textColor = Colors.white;
        displayText = '✓ Play';
        break;
      case 'wait':
        bgColor = Colors.orange;
        textColor = Colors.white;
        displayText = 'ⓘ Wait';
        break;
      case 'be_cautious':
        bgColor = Colors.red;
        textColor = Colors.white;
        displayText = '⚠ Caution';
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
        displayText = '?';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(displayText, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }
}

class _AdviceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _AdviceItem({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 4),
              Text(content, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _LuckyItem extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const _LuckyItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 24)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ],
    );
  }
}
