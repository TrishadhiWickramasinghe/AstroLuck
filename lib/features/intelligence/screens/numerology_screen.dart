// lib/features/intelligence/screens/numerology_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../../../widgets/custom_card.dart';

class NumerologyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends ConsumerState<NumerologyScreen>
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
        title: Text('Numerology Profile'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Numbers'),
            Tab(text: 'Readings'),
            Tab(text: 'Lucky Items'),
            Tab(text: 'Compatibility'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _api.getNumerologyProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profile = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNumbersTab(profile),
              _buildReadingsTab(profile),
              _buildLuckyItemsTab(profile),
              _buildCompatibilityTab(profile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNumbersTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _NumberCard(
            title: 'Life Path Number',
            number: profile['life_path_number'],
            color: Colors.purple,
            description:
                'Your fundamental life pattern and direction',
          ),
          SizedBox(height: 12),
          _NumberCard(
            title: 'Destiny Number',
            number: profile['destiny_number'],
            color: Colors.blue,
            description: 'Your life purpose and career path',
          ),
          SizedBox(height: 12),
          _NumberCard(
            title: 'Soul Urge Number',
            number: profile['soul_urge_number'],
            color: Colors.green,
            description: 'Your inner desires and motivations',
          ),
          SizedBox(height: 12),
          _NumberCard(
            title: 'Personality Number',
            number: profile['personality_number'],
            color: Colors.orange,
            description: 'How others perceive you',
          ),
          SizedBox(height: 12),
          _NumberCard(
            title: 'Expression Number',
            number: profile['expression_number'],
            color: Colors.red,
            description: 'Your natural talents and abilities',
          ),
          SizedBox(height: 12),
          _NumberCard(
            title: 'Birth Day Number',
            number: profile['birth_day_number'],
            color: Colors.teal,
            description: 'Your day of birth influence',
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _ReadingCard(
            title: 'Life Path Reading',
            reading: profile['life_path_reading'],
          ),
          SizedBox(height: 12),
          _ReadingCard(
            title: 'Destiny Reading',
            reading: profile['destiny_reading'],
          ),
          SizedBox(height: 12),
          _ReadingCard(
            title: 'Soul Urge Reading',
            reading: profile['soul_urge_reading'],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lucky Numbers', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['lucky_numbers'] as List?)?.map((num) {
                    return Chip(
                      label: Text(num.toString()),
                      backgroundColor: Colors.purple.withOpacity(0.2),
                    );
                  }).toList() ?? [],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lucky Colors', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['lucky_colors'] as List?)?.map((color) {
                    return Chip(label: Text(color));
                  }).toList() ?? [],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lucky Days', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['lucky_days'] as List?)?.map((day) {
                    return Chip(
                      label: Text(day),
                      backgroundColor: Colors.green.withOpacity(0.2),
                    );
                  }).toList() ?? [],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lucky Hours', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['lucky_hours'] as List?)?.map((hour) {
                    return Chip(
                      label: Text('$hour:00'),
                      backgroundColor: Colors.orange.withOpacity(0.2),
                    );
                  }).toList() ?? [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Zodiac Compatibility',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 12),
                Text(
                    'Your numerology profile shows compatibility with certain zodiac signs. Compatible partners often share similar numerology patterns.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _NumberCard extends StatelessWidget {
  final String title;
  final int number;
  final Color color;
  final String description;

  const _NumberCard({
    required this.title,
    required this.number,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 4),
                Text(description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final String title;
  final String reading;

  const _ReadingCard({
    required this.title,
    required this.reading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 12),
          Text(reading, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
