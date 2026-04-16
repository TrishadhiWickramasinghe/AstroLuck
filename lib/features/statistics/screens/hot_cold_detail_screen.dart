import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/statistics_providers.dart';

class HotColdDetailScreen extends ConsumerWidget {
  final int number;
  final String lotteryType;

  const HotColdDetailScreen({
    Key? key,
    required this.number,
    required this.lotteryType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = NumberDetailParams(number: number, lotteryType: lotteryType);
    final detail = ref.watch(numberDetailProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text('Number #$number Analysis'),
        backgroundColor: Colors.deepPurple,
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Heat/Cold Score Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('🔥 Heat Score', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: data.heatScore / 100,
                                strokeWidth: 4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('${data.heatScore.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('❄️ Cold Score', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: data.coldScore / 100,
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('${data.coldScore.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (data.recommended)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Recommended for selection', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildStatRow('Total Appearances', data.totalAppearances.toString()),
                    _buildStatRow('Mean Gap (days)', data.meanGapDays.toStringAsFixed(1)),
                    _buildStatRow('Max Gap (days)', data.maxGapDays?.toString() ?? 'N/A'),
                    _buildStatRow('Last 30 days', data.recent30d.toString()),
                    _buildStatRow('Last 90 days', data.recent90d.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recommendation Card
            Card(
              color: data.recommended ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.recommended ? '✅ Include in Selection' : '⚠️ Use with Caution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: data.recommended ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.recommended
                          ? 'This number shows strong performance indicators and is recommended for your next ticket.'
                          : 'This number has not appeared frequently. Consider other options.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Add to Ticket Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added #$number to potential selections')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Add to My Selections'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
