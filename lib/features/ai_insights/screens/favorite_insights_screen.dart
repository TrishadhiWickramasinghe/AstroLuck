"""Favorite Insights Screen - View and manage saved insights"""

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astroluck/core/models/ai_insight_model.dart';
import 'package:astroluck/providers/ai_insights_providers.dart';

class FavoriteInsightsScreen extends ConsumerWidget {
  const FavoriteInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Insights'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites == null || favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No favorite insights yet'),
                  SizedBox(height: 8),
                  Text(
                    'Insights you save will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) =>
                _buildFavoriteCard(context, ref, favorites[index]),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading favorites'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    WidgetRef ref,
    InsightHistoryItem item,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.shade200,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: Icon(
            Icons.favorite,
            color: Colors.red,
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
                  Chip(
                    label: Text(
                      item.zodiacSign.toUpperCase(),
                      style: TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.purple.shade100,
                    visualDensity: VisualDensity.compact,
                  ),
                  SizedBox(width: 8),
                  if (item.rating != null)
                    Row(
                      children: List.generate(
                        item.rating!,
                        (index) => Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                ],
              ),
              if (item.timeSpentSeconds != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Spent ${_formatDuration(item.timeSpentSeconds!)} reading',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              ref.read(engagementProvider).toggleFavorite(item.id);
            },
            tooltip: 'Remove from favorites',
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/insight-detail',
              arguments: item.id,
            );
          },
        ),
      ),
    );
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
