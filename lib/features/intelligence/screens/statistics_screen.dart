// lib/features/intelligence/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/api_client.dart';
import '../../../widgets/custom_card.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistical Dashboard'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Hot & Cold'),
            Tab(text: 'Patterns'),
            Tab(text: 'Performance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHotColdTab(),
          _buildPatternsTab(),
          _buildPerformanceTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _api.getStatisticsDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stats = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _StatCard(
                title: 'Total Plays',
                value: '${stats['total_plays']}',
                icon: Icons.format_list_numbered,
                color: Colors.blue,
              ),
              SizedBox(height: 12),
              _StatCard(
                title: 'Win Rate',
                value: '${(stats['win_rate'] as double).toStringAsFixed(2)}%',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              SizedBox(height: 12),
              _StatCard(
                title: 'Most Active',
                value: '${stats['most_active_day']} (${stats['most_active_hour']}:00)',
                icon: Icons.access_time,
                color: Colors.orange,
              ),
              SizedBox(height: 12),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommended Next Numbers',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        final num = (10 + index * 7) % 56;
                        return Chip(
                          label: Text('$num'),
                          backgroundColor: Colors.purple.withOpacity(0.3),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHotColdTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _api.getHotNumbers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data!;

              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('🔥 Hot Numbers',
                            style: Theme.of(context).textTheme.titleLarge),
                        Chip(
                          label: Text('${data['total_plays']} plays'),
                          backgroundColor: Colors.orange.withOpacity(0.2),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: (data['hot_numbers'] as List?)
                              ?.map((num) {
                        final count = (data['appearance_counts'] != null
                            ? data['appearance_counts']['$num']
                            : 0);
                        return Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.withOpacity(0.3),
                              ),
                              child: Center(
                                child: Text(
                                  '$num',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('$count', style: TextStyle(fontSize: 12)),
                          ],
                        );
                      }).toList() ??
                              [],
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>>(
            future: _api.getColdNumbers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data!;

              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('❄️ Cold Numbers',
                            style: Theme.of(context).textTheme.titleLarge),
                        Chip(
                          label: Text('${data['total_plays']} plays'),
                          backgroundColor: Colors.blue.withOpacity(0.2),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: (data['cold_numbers'] as List?)
                              ?.map((num) {
                        final count = (data['appearance_counts'] != null
                            ? data['appearance_counts']['$num']
                            : 0);
                        return Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.3),
                              ),
                              child: Center(
                                child: Text(
                                  '$num',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('$count', style: TextStyle(fontSize: 12)),
                          ],
                        );
                      }).toList() ??
                              [],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _api.getNumberPatterns(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final patterns = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ratio Analysis',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    _PatternRow(
                      label: 'Even/Odd Ratio',
                      value: '${(patterns['even_odd_ratio'] as double).toStringAsFixed(2)}',
                      detail: 'Ratio of even to odd numbers',
                    ),
                    SizedBox(height: 8),
                    _PatternRow(
                      label: 'Prime Numbers',
                      value: '${(patterns['prime_number_ratio'] as double).toStringAsFixed(2)}',
                      detail: 'Percentage of prime numbers',
                    ),
                    SizedBox(height: 8),
                    _PatternRow(
                      label: 'Trend Direction',
                      value: patterns['trend_direction'],
                      detail: 'Current lottery number trend',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              if ((patterns['numbers_due_to_appear'] as List?)?.isNotEmpty ?? false)
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Numbers Due to Appear',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: (patterns['numbers_due_to_appear'] as List)
                            .map((num) => Chip(label: Text('$num')))
                            .toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _api.getPerformanceMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final perf = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PerformanceMetric(
                      label: 'Total Plays',
                      value: '${perf['total_plays']}',
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _PerformanceMetric(
                      label: 'Wins',
                      value: '${perf['winning_plays']}',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PerformanceMetric(
                      label: 'Win Rate',
                      value: '${(perf['win_rate'] as double).toStringAsFixed(1)}%',
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _PerformanceMetric(
                      label: 'ROI',
                      value: '${(perf['roi'] as double).toStringAsFixed(1)}%',
                      color: (perf['roi'] as double) > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Financial Summary',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 12),
                    _MetricRow(
                      label: 'Total Spent',
                      value: '\$${(perf['total_spent'] as double).toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 8),
                    _MetricRow(
                      label: 'Total Winnings',
                      value: '\$${(perf['total_winnings'] as double).toStringAsFixed(2)}',
                      color: Colors.green,
                    ),
                    SizedBox(height: 8),
                    _MetricRow(
                      label: 'Net',
                      value:
                          '\$${((perf['total_winnings'] as double) - (perf['total_spent'] as double)).toStringAsFixed(2)}',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternRow extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const _PatternRow({
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            Text(detail,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            )),
      ],
    );
  }
}
