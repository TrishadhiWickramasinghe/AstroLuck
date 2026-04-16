import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/statistics_providers.dart';

class TrendsDetailScreen extends ConsumerWidget {
  const TrendsDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotteryType = ref.watch(selectedLotteryTypeProvider);
    final trends = ref.watch(trendsOverviewProvider(lotteryType));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Number Trends'),
          backgroundColor: Colors.deepPurple,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.trending_up), text: 'Trending Up'),
              Tab(icon: Icon(Icons.trending_down), text: 'Trending Down'),
            ],
          ),
        ),
        body: trends.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (trendsData) => TabBarView(
            children: [
              // Trending Up Tab
              ListView.builder(
                itemCount: trendsData.trendingUp.length,
                itemBuilder: (context, index) {
                  final trend = trendsData.trendingUp[index];
                  return _buildTrendCard(context, trend, true);
                },
              ),
              // Trending Down Tab
              ListView.builder(
                itemCount: trendsData.trendingDown.length,
                itemBuilder: (context, index) {
                  final trend = trendsData.trendingDown[index];
                  return _buildTrendCard(context, trend, false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context, dynamic trend, bool isUp) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isUp ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  trend.number.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isUp ? Colors.green : Colors.red,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        title: Text('Number ${trend.number}'),
        subtitle: Text('Change: ${trend.changePercentage.toStringAsFixed(1)}%'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(trend.strength * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Strength',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () {
          // Navigate to number detail
        },
      ),
    );
  }
}
