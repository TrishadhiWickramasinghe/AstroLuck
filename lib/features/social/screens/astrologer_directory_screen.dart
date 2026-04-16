// lib/features/social/screens/astrologer_directory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/primary_button.dart';
import '../providers/social_providers.dart';

class AstrologerDirectoryScreen extends ConsumerStatefulWidget {
  const AstrologerDirectoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AstrologerDirectoryScreen> createState() => _AstrologerDirectoryScreenState();
}

class _AstrologerDirectoryScreenState extends ConsumerState<AstrologerDirectoryScreen> {
  String _selectedSpecialization = 'all';
  double _minRating = 0;

  @override
  Widget build(BuildContext context) {
    final astrologersAsync = ref.watch(astrologersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expert Astrologers'),
        elevation: 0,
      ),
      body: astrologersAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (astrologers) {
          final filtered = astrologers.where((a) {
            final rating = (a['average_rating'] as num?)?.toDouble() ?? 0;
            if (_minRating > 0 && rating < _minRating) return false;
            if (_selectedSpecialization != 'all') {
              final specs = (a['specializations'] as List?)?.cast<String>() ?? [];
              if (!specs.contains(_selectedSpecialization)) return false;
            }
            return true;
          }).toList();

          if (astrologers.isEmpty) {
            return _emptyState(context);
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Search & Filter
              _filterSection(),
              SizedBox(height: 16),

              // Results
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No astrologers match your filters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                )
              else ...[
                Text(
                  '${filtered.length} Available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 12),
                ...filtered.map((astrologer) => AstrologerCard(
                  astrologer: astrologer,
                  onTap: () => _showAstrologerDetails(context, astrologer),
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _filterSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              'all',
              'birth_charts',
              'tarot',
              'numerology',
              'astrology',
            ].map((spec) {
              final isSelected = _selectedSpecialization == spec;
              return FilterChip(
                label: Text(spec.replaceAll('_', ' ')),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedSpecialization = spec);
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.blue[100],
              );
            }).toList(),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Min Rating', style: TextStyle(fontSize: 12)),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => _minRating = value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Expert Directory Coming Soon',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Connect with verified astrologers and get personalized readings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAstrologerDetails(BuildContext context, Map<String, dynamic> astrologer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AstrologerDetailsSheet(astrologer: astrologer),
    );
  }
}

class AstrologerCard extends StatelessWidget {
  final Map<String, dynamic> astrologer;
  final VoidCallback onTap;

  const AstrologerCard({required this.astrologer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = (astrologer['average_rating'] as num?)?.toDouble() ?? 0;
    final reviews = (astrologer['total_reviews'] as int?) ?? 0;
    final isVerified = (astrologer['is_verified'] as bool?) ?? false;
    final specializations = (astrologer['specializations'] as List?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        margin: EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('✨', style: TextStyle(fontSize: 32)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              astrologer['professional_name'] ?? 'Astrologer',
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified)
                            Tooltip(
                              message: 'Verified Professional',
                              child: Icon(Icons.verified, color: Colors.blue, size: 18),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '($reviews reviews)',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${astrologer['experience_years'] ?? 0} years experience',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: specializations.take(3).map((spec) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    spec.replaceAll('_', ' '),
                    style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${astrologer['hourly_rate'] ?? 0}/hour',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(
                  '${astrologer['total_consultations'] ?? 0} consultations',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AstrologerDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> astrologer;

  const AstrologerDetailsSheet({required this.astrologer});

  @override
  State<AstrologerDetailsSheet> createState() => _AstrologerDetailsSheetState();
}

class _AstrologerDetailsSheetState extends State<AstrologerDetailsSheet> {
  String _selectedType = 'video_call';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final rating = (widget.astrologer['average_rating'] as num?)?.toDouble() ?? 0;
    final reviews = (widget.astrologer['total_reviews'] as int?) ?? 0;
    final specializations = (widget.astrologer['specializations'] as List?)?.cast<String>() ?? [];
    final availableHours = (widget.astrologer['available_hours'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.astrologer['professional_name'] ?? 'Astrologer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber),
              SizedBox(width: 4),
              Text('$rating ($reviews reviews)', style: TextStyle(fontSize: 13)),
            ],
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          Text('Specializations', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: specializations.map((spec) {
              return Chip(
                label: Text(spec.replaceAll('_', ' ')),
                backgroundColor: Colors.blue[50],
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text('Consultation Type', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['video_call', 'written_report', 'email'].map((type) {
              final isSelected = _selectedType == type;
              return FilterChip(
                label: Text(type.replaceAll('_', ' ')),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedType = type);
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24),
          PrimaryButton(
            label: 'Book Consultation - \$${widget.astrologer['hourly_rate'] ?? 0}',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Consultation booking initiated!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
