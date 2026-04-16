import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/statistics_providers.dart';

class PatternsDetailScreen extends ConsumerWidget {
  const PatternsDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotteryType = ref.watch(selectedLotteryTypeProvider);
    final patterns = ref.watch(topPatternsProvider(lotteryType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Winning Patterns'),
        backgroundColor: Colors.deepPurple,
      ),
      body: patterns.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (patternsList) => ListView(
          padding: const EdgeInsets.all(8),
          children: patternsList.asMap().entries.map((entry) {
            final index = entry.key;
            final pattern = entry.value;
            return _buildPatternCard(context, pattern, index);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPatternCard(BuildContext context, dynamic pattern, int index) {
    final colors = [Colors.amber, Colors.grey, Colors.orange];
    final medals = ['🥇', '🥈', '🥉'];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with medal
            Row(
              children: [
                if (index < 3)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      medals[index],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        pattern.type,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Frequency', '${pattern.frequency.toStringAsFixed(1)}%'),
                _buildStatItem('Hit Rate', '${((pattern.hitRate ?? 0) * 100).toStringAsFixed(0)}%'),
                _buildStatItem('Confidence', '${(pattern.confidence * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'This pattern appears in ${pattern.occurrences} drawings',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pattern \"${pattern.name}\" tracked')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.withOpacity(0.7),
                ),
                child: const Text('Track Pattern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
