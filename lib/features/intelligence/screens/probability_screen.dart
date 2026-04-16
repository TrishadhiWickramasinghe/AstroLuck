// lib/features/intelligence/screens/probability_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/api_client.dart';
import '../../../widgets/custom_card.dart';
import '../widgets/probability_card.dart';

class ProbabilityScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProbabilityScreen> createState() => _ProbabilityScreenState();
}

class _ProbabilityScreenState extends ConsumerState<ProbabilityScreen> {
  String selectedLottery = 'powerball';
  final ApiClient _api = ApiClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Win Probability'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Lottery type selector
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedLottery,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'powerball', child: Text('PowerBall')),
                  DropdownMenuItem(value: 'megamillions', child: Text('Mega Millions')),
                  DropdownMenuItem(value: 'lucky_seven', child: Text('Lucky Seven')),
                  DropdownMenuItem(value: 'daily_pick', child: Text('Daily Pick')),
                ].cast(),
                onChanged: (value) {
                  setState(() => selectedLottery = value!);
                },
              ),
            ),
            SizedBox(height: 24),

            // Main probability display
            FutureBuilder<Map<String, dynamic>>(
              future: _api.calculateWinProbability(selectedLottery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data!;
                final probability = data['predicted_win_probability'] as double;
                final confidence = data['confidence_score'] as double;

                return Column(
                  children: [
                    // Main probability gauge
                    ProbabilityGauge(
                      probability: probability,
                      confidence: confidence,
                    ),
                    SizedBox(height: 24),

                    // Breakdown
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Probability Breakdown',
                              style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: 16),
                          _BreakdownItem(
                            label: 'Base Probability',
                            value: '${(data['breakdown']['base_probability'] as double).toStringAsFixed(3)}%',
                          ),
                          _BreakdownItem(
                            label: 'Numerology Boost',
                            value: '+${(data['breakdown']['numerology_boost'] as double).toStringAsFixed(2)}%',
                            color: Colors.purple,
                          ),
                          _BreakdownItem(
                            label: 'Astrological Influence',
                            value: '+${(data['breakdown']['astrological_influence'] as double).toStringAsFixed(2)}%',
                            color: Colors.blue,
                          ),
                          _BreakdownItem(
                            label: 'Historical Performance',
                            value: '+${(data['breakdown']['historical_performance'] as double).toStringAsFixed(2)}%',
                            color: Colors.green,
                          ),
                          _BreakdownItem(
                            label: 'Lucky Day Bonus',
                            value: '+${(data['breakdown']['lucky_day_bonus'] as double).toStringAsFixed(2)}%',
                            color: Colors.orange,
                          ),
                          _BreakdownItem(
                            label: 'Lucky Hour Bonus',
                            value: '+${(data['breakdown']['lucky_hour_bonus'] as double).toStringAsFixed(2)}%',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Recommendations
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recommendations',
                              style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: 12),
                          Text('Recommended Numbers:',
                              style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (data['recommended_numbers'] as List)
                                .map((num) => Chip(
                                  label: Text(num.toString()),
                                  backgroundColor: Colors.green.withOpacity(0.2),
                                ))
                                .toList(),
                          ),
                          SizedBox(height: 16),
                          Text('Avoid Numbers:',
                              style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (data['avoid_numbers'] as List)
                                .map((num) => Chip(
                                  label: Text(num.toString()),
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                ))
                                .toList(),
                          ),
                          SizedBox(height: 16),
                          Text('Best Time to Play: ${data['best_time_to_play']}',
                              style: Theme.of(context).textTheme.bodyLarge),
                          SizedBox(height: 8),
                          Text('Best Days: ${(data['best_days_to_play'] as List).join(', ')}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BreakdownItem({
    required this.label,
    required this.value,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }
}
