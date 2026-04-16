import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/statistics_providers.dart';

class PersonalStatsScreen extends ConsumerWidget {
  const PersonalStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotteryType = ref.watch(selectedLotteryTypeProvider);
    final personal = ref.watch(personalStatisticsProvider(lotteryType));
    final luckyNumbers = ref.watch(luckyNumbersProvider(lotteryType));
    final recommendations = ref.watch(numberRecommendationsProvider(lotteryType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Playing Statistics'),
        backgroundColor: Colors.deepPurple,
      ),
      body: personal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Playing Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Tickets', stats.totalTickets.toString(), Icons.confirmation_number),
                        _buildSummaryItem('Days Playing', stats.daysPlaying.toString(), Icons.calendar_today),
                        _buildSummaryItem('Frequency', stats.playFrequency, Icons.repeat),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💰 Financial Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Total Spent', '\$${stats.totalSpent.toStringAsFixed(2)}'),
                    _buildDetailRow('Total Winnings', '\$${stats.totalWinnings.toStringAsFixed(2)}', Colors.green),
                    _buildDetailRow('Net Profit/Loss', '\$${(stats.totalWinnings - stats.totalSpent).toStringAsFixed(2)}',
                        stats.totalWinnings >= stats.totalSpent ? Colors.green : Colors.red),
                    const Divider(),
                    _buildDetailRow('ROI', '${stats.roi.toStringAsFixed(1)}%',
                        stats.roi >= 0 ? Colors.green : Colors.red),
                    _buildDetailRow('Win Rate', '${stats.winRate.toStringAsFixed(1)}%'),
                    _buildDetailRow('Best Win', '\$${stats.largestWin.toStringAsFixed(2)}', Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lucky Numbers Card
            luckyNumbers.when(
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
              data: (numbers) => numbers.isNotEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⭐ Your Lucky Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: numbers.map((num) => Chip(
                                label: Text(num.toString()),
                                backgroundColor: Colors.purple.withOpacity(0.3),
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Recommendations Card
            recommendations.when(
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
              data: (recommended) => Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🎯 AI Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Based on your statistics and trends:', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recommended.map((num) => Chip(
                          label: Text(num.toString()),
                          backgroundColor: Colors.blue.withOpacity(0.3),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added recommended numbers to ticket')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Use These Numbers'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
