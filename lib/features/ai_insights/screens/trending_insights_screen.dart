"""Trending Insights Screen - Discover popular insights"""

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astroluck/core/models/ai_insight_model.dart';
import 'package:astroluck/providers/ai_insights_providers.dart';

class TrendingInsightsScreen extends ConsumerWidget {
  const TrendingInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trending Insights'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: trendingAsync.when(
        data: (trending) {
          if (trending == null || trending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No trending insights yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: trending.length,
            itemBuilder: (context, index) => _buildTrendingCard(
              context,
              ref,
              trending[index],
              index + 1,
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTrendingCard(
    BuildContext context,
    WidgetRef ref,
    TrendingInsight insight,
    int rank,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: rank <= 3 ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: rank == 1
              ? LinearGradient(colors: [Colors.amber.shade50, Colors.amber.shade100])
              : rank == 2
                  ? LinearGradient(
                      colors: [Colors.grey.shade100, Colors.grey.shade200])
                  : rank == 3
                      ? LinearGradient(
                          colors: [Colors.orange.shade50, Colors.orange.shade100])
                      : null,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getRankColor(rank),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          title: Text(
            insight.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      insight.zodiacSign.toUpperCase(),
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.purple.shade100,
                    visualDensity: VisualDensity.compact,
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.visibility, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${insight.viewCount ?? 0} views',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.favorite, size: 14, color: Colors.red),
                  SizedBox(width: 4),
                  Text(
                    '${insight.engagementScore ?? 0} engagement',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/insight-detail',
              arguments: insight.id,
            );
          },
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}
