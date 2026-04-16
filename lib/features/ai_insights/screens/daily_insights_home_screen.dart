"""Daily Insights Home Screen - Main feed for personalized daily insights"""

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astroluck/core/models/ai_insight_model.dart';
import 'package:astroluck/core/models/user_insight_preference.dart';
import 'package:astroluck/providers/ai_insights_providers.dart';
import 'package:astroluck/widgets/primary_button.dart';

class DailyInsightsHomeScreen extends ConsumerWidget {
  const DailyInsightsHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalizedInsightAsync = ref.watch(personalizedInsightProvider);
    final preferencesAsync = ref.watch(preferencesProvider);
    final engagementStatsAsync = ref.watch(engagementStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade700,
                      Colors.purple.shade500,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Daily Insights',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Personalized cosmic guidance for today',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Personalized Insight Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: personalizedInsightAsync.when(
                data: (insight) {
                  if (insight == null) {
                    return _buildNoInsightCard(context);
                  }
                  return _buildPersonalizedInsightCard(
                    context,
                    ref,
                    insight,
                  );
                },
                loading: () => _buildLoadingCard(),
                error: (err, stack) => _buildErrorCard(
                  context,
                  err.toString(),
                ),
              ),
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: engagementStatsAsync.when(
                data: (stats) {
                  if (stats == null) return SizedBox.shrink();
                  return _buildStatsSection(context, stats);
                },
                loading: () => SizedBox.shrink(),
                error: (err, stack) => SizedBox.shrink(),
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildQuickActionsSection(context, ref),
            ),
          ),

          // History Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // History List
          ref.watch(insightHistoryProvider).when(
            data: (history) {
              if (history == null || history.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No insights viewed yet'),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildHistoryItem(
                    context,
                    ref,
                    history[index],
                  ),
                  childCount: history.length,
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error loading history'),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildPersonalizedInsightCard(
    BuildContext context,
    WidgetRef ref,
    PersonalizedAIInsight insight,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail screen
        Navigator.of(context).pushNamed(
          '/insight-detail',
          arguments: insight.id,
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade100, Colors.purple.shade100],
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                insight.personalizedTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                ),
              ),
              SizedBox(height: 12),

              // Content Preview
              Text(
                insight.personalizedContent.length > 150
                    ? '${insight.personalizedContent.substring(0, 150)}...'
                    : insight.personalizedContent,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/insight-detail',
                        arguments: insight.id,
                      );
                    },
                    icon: Icon(Icons.read_more),
                    label: Text('Read Full'),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(engagementProvider).logShare(
                        insight.id,
                        'whatsapp',
                      );
                    },
                    icon: Icon(Icons.share),
                    tooltip: 'Share to WhatsApp',
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(engagementProvider).saveInsight(insight.id);
                    },
                    icon: Icon(Icons.bookmark_border),
                    tooltip: 'Save for later',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoInsightCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Insight Available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for your personalized cosmic guidance',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(height: 8),
            Text('Error loading insight'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Your Engagement',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Views',
                stats['total_views']?.toString() ?? '0',
                Icons.visibility,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Saved',
                stats['saved_count']?.toString() ?? '0',
                Icons.bookmark,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Shared',
                stats['shared_count']?.toString() ?? '0',
                Icons.share,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.purple),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickActionChip(
                context,
                'Favorites',
                Icons.favorite,
                () {
                  Navigator.of(context).pushNamed('/insight-favorites');
                },
              ),
              SizedBox(width: 8),
              _buildQuickActionChip(
                context,
                'History',
                Icons.history,
                () {
                  Navigator.of(context).pushNamed('/insight-history');
                },
              ),
              SizedBox(width: 8),
              _buildQuickActionChip(
                context,
                'Preferences',
                Icons.settings,
                () {
                  Navigator.of(context).pushNamed('/insight-preferences');
                },
              ),
              SizedBox(width: 8),
              _buildQuickActionChip(
                context,
                'Trending',
                Icons.trending_up,
                () {
                  Navigator.of(context).pushNamed('/insight-trending');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (_) => onTap(),
      backgroundColor: Colors.purple.shade100,
      side: BorderSide.none,
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    InsightHistoryItem item,
  ) {
    return ListTile(
      leading: Icon(Icons.auto_awesome, color: Colors.purple),
      title: Text(item.title),
      subtitle: Text(
        item.zodiacSign.toUpperCase() +
            (item.viewedAt != null ? ' • Viewed' : ''),
      ),
      trailing: item.rating != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 16,
                  color: index < item.rating! ? Colors.amber : Colors.grey,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).pushNamed(
          '/insight-detail',
          arguments: item.id,
        );
      },
    );
  }
}
