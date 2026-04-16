import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/statistics_providers.dart';
import '../../../core/models/statistics_models.dart';

class StatisticsHomeScreen extends ConsumerWidget {
  const StatisticsHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotteryType = ref.watch(selectedLotteryTypeProvider);
    final summary = ref.watch(dashboardSummaryProvider(lotteryType));
    final personal = ref.watch(personalStatisticsProvider(lotteryType));
    final preferences = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to preferences
            },
          ),
        ],
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardSummaryProvider(lotteryType).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Lottery Type selector
              SegmentedButton<String>(
                selected: {lotteryType},
                onSelectionChanged: (Set<String> newSelection) {
                  ref.read(selectedLotteryTypeProvider.notifier).state = newSelection.first;
                },
                segments: const [
                  ButtonSegment(value: 'powerball', label: Text('PowerBall')),
                  ButtonSegment(value: 'mega_millions', label: Text('Mega Millions')),
                ],
              ),
              const SizedBox(height: 20),

              // Hot Numbers Section
              if (preferences.showHotCold)
                _buildHotColdSection(context, data.hotNumbers, data.coldNumbers),
              const SizedBox(height: 20),

              // Trends Section
              if (preferences.showTrends)
                _buildTrendsSection(context, data.trending),
              const SizedBox(height: 20),

              // Patterns Section
              if (preferences.showPatterns)
                _buildPatternsSection(context, data.patterns),
              const SizedBox(height: 20),

              // Personal Stats
              if (preferences.showPersonalStats && personal.hasValue)
                _buildPersonalStatsSection(context, personal.value!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotColdSection(BuildContext context, List<HotColdNumber> hot, List<HotColdNumber> cold) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hot & Cold Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Hot Numbers
            const Text('🔥 Hottest', style: TextStyle(fontSize: 14, color: Colors.red)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: hot.take(5).map((num) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(num.number.toString()),
                    backgroundColor: Colors.red.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.red),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Cold Numbers
            const Text('❄️ Coldest', style: TextStyle(fontSize: 14, color: Colors.blue)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cold.take(5).map((num) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(num.number.toString()),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.blue),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsSection(BuildContext context, List<TrendNumber> trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 Trending Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...trends.take(5).map((trend) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(trend.number.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(
                        trend.direction == 'increasing' ? Icons.trending_up : Icons.trending_down,
                        color: trend.direction == 'increasing' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text('${trend.changePercentage.toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternsSection(BuildContext context, List<WinningPatternData> patterns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 Top Winning Patterns', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...patterns.take(3).map((pattern) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(pattern.name),
                subtitle: Text('${pattern.frequency.toStringAsFixed(1)}% • Hit rate: ${(pattern.hitRate ?? 0).toStringAsFixed(2)}'),
                trailing: Chip(
                  label: Text('${(pattern.confidence * 100).toStringAsFixed(0)}%'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalStatsSection(BuildContext context, PersonalStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👤 Your Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Tickets', stats.totalTickets.toString()),
                _buildStatItem('ROI', '${stats.roi.toStringAsFixed(1)}%'),
                _buildStatItem('Win Rate', '${stats.winRate.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Spent', '\$${stats.totalSpent.toStringAsFixed(2)}'),
                _buildStatItem('Won', '\$${stats.totalWinnings.toStringAsFixed(2)}'),
                _buildStatItem('Best Win', '\$${stats.largestWin.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
