"""Insight Detail Screen - Full view of an insight with all sections"""

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astroluck/core/models/ai_insight_model.dart';
import 'package:astroluck/providers/ai_insights_providers.dart';

class InsightDetailScreen extends ConsumerStatefulWidget {
  final String insightId;

  const InsightDetailScreen({
    Key? key,
    required this.insightId,
  }) : super(key: key);

  @override
  _InsightDetailScreenState createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends ConsumerState<InsightDetailScreen> {
  int? userRating;
  final _commentController = TextEditingController();
  int _timeSpentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _timeSpentSeconds++;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    // Log time spent when leaving
    ref.read(engagementProvider).logView?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
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
                        'Today\\'s Cosmic Insight',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Personalized guidance and cosmic alignment',
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

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Your Daily Cosmic Alignment',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Meta Info
                  Row(
                    children: [
                      Icon(Icons.today, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('Today'),
                      SizedBox(width: 16),
                      Icon(Icons.visibility, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('Read time'),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Main Content
                  Text(
                    'The cosmic energies are in your favor today. Trust your intuition and take bold action towards your goals.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Lucky Times Card
                  _buildSectionCard(
                    context,
                    'Lucky Times',
                    Icons.access_time,
                    Colors.amber,
                    ['9:00 AM - 12:00 PM', 'Perfect for important decisions', '6:00 PM - 8:00 PM'],
                  ),
                  SizedBox(height: 16),

                  // Lucky Numbers
                  _buildSectionCard(
                    context,
                    'Lucky Numbers',
                    Icons.numbers,
                    Colors.green,
                    ['7', '14', '21', '28'],
                  ),
                  SizedBox(height: 16),

                  // Lucky Colors
                  _buildSectionCard(
                    context,
                    'Lucky Colors',
                    Icons.palette,
                    Colors.purple,
                    ['Gold', 'Emerald', 'Silver'],
                  ),
                  SizedBox(height: 16),

                  // Power Affirmation
                  Card(
                    color: Colors.deepPurple.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Power Affirmation',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '\"I am aligned with the cosmic energy and embrace unlimited possibilities.\"',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.deepPurple.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Career Guidance
                  _buildGuidanceSection(
                    context,
                    'Career Focus',
                    'Take initiative on a project you\'ve been considering. This is the perfect timing to propose your ideas.',
                    Icons.work,
                  ),
                  SizedBox(height: 12),

                  // Romance Insight
                  _buildGuidanceSection(
                    context,
                    'Romance',
                    'Vulnerability leads to deeper connection. Be open with those you care about.',
                    Icons.favorite,
                  ),
                  SizedBox(height: 12),

                  // Health Tip
                  _buildGuidanceSection(
                    context,
                    'Health & Wellness',
                    'Honor your body\\'s need for rest and movement. Balance is key today.',
                    Icons.favorite_border,
                  ),
                  SizedBox(height: 24),

                  // Feedback Section
                  Text(
                    'How was this insight?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() => userRating = index + 1);
                        },
                        icon: Icon(
                          userRating != null && index < userRating!
                              ? Icons.star
                              : Icons.star_outline,
                          size: 32,
                        ),
                        color: Colors.amber,
                      );
                    }),
                  ),
                  SizedBox(height: 16),

                  // Comment Field
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (userRating != null) {
                          ref.read(feedbackProvider).submitFeedback(
                            insightId: widget.insightId,
                            rating: userRating!,
                            comment: _commentController.text.isNotEmpty
                                ? _commentController.text
                                : null,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Thank you for your feedback!')),
                          );
                        }
                      },
                      child: Text('Submit Feedback'),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Share Actions
                  Text(
                    'Share This Insight',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(engagementProvider).logShare(
                            widget.insightId,
                            'whatsapp',
                          );
                        },
                        icon: Icon(Icons.share),
                        label: Text('WhatsApp'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(engagementProvider).logShare(
                            widget.insightId,
                            'social',
                          );
                        },
                        icon: Icon(Icons.share),
                        label: Text('Social'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(engagementProvider).saveInsight(
                            widget.insightId,
                          );
                        },
                        icon: Icon(Icons.bookmark),
                        label: Text('Save'),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      backgroundColor: color.withOpacity(0.2),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.purple, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
