"""Insight History Screen - Browse and manage past insights"""

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astroluck/core/models/ai_insight_model.dart';
import 'package:astroluck/providers/ai_insights_providers.dart';

class InsightHistoryScreen extends ConsumerWidget {
  const InsightHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(insightHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Insight History'),
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (history) {
          if (history == null || history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No insights viewed yet'),
                  SizedBox(height: 8),
                  Text(
                    'Your viewed insights will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) =>
                _buildHistoryCard(context, ref, history[index]),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading history'),
              SizedBox(height: 8),
              Text(err.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    InsightHistoryItem item,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Icon(
          Icons.auto_awesome,
          color: Colors.deepPurple,
          size: 28,
        ),
        title: Text(
          item.title,
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
              children: [
                Icon(Icons.label, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  item.zodiacSign.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 12),
                if (item.viewedAt != null)
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(item.viewedAt!),
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (item.timeSpentSeconds != null)
              Text(
                'Time spent: ${_formatDuration(item.timeSpentSeconds!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.rating != null)
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: index < item.rating! ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  item.isFavorite == true ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite == true ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  ref.read(engagementProvider).toggleFavorite(item.id);
                },
                tooltip: 'Toggle favorite',
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/insight-detail',
            arguments: item.id,
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.month}/${date.day}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).toStringAsFixed(0)}m';
    } else {
      return '${(seconds / 3600).toStringAsFixed(1)}h';
    }
  }
}
