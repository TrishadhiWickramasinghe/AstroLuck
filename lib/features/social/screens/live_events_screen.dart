// lib/features/social/screens/live_events_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/primary_button.dart';
import '../providers/social_providers.dart';

class LiveEventsScreen extends ConsumerStatefulWidget {
  const LiveEventsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LiveEventsScreen> createState() => _LiveEventsScreenState();
}

class _LiveEventsScreenState extends ConsumerState<LiveEventsScreen> {
  String _selectedMethod = 'frequency_based';
  List<int> _submittedNumbers = [];

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(liveEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Generation Events'),
        elevation: 0,
      ),
      body: eventsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (events) {
          if (events.isEmpty) {
            return _emptyState(context);
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // How it Works
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'How It Works',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Submit your lucky numbers to collaborate with other players. Final numbers will be generated based on community input.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Active Events
              Text('Active Events', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 12),
              ...events.map((event) => EventCard(event: event, onTap: () => _showEventDetails(context, event))),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Live Events',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Check back soon for collaborative number generation events',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventDetailsSheet(event: event, onSubmit: _onNumbersSubmitted),
    );
  }

  void _onNumbersSubmitted() {
    setState(() => _submittedNumbers.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Numbers submitted successfully!')),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final participants = (event['num_participants'] as int?) ?? 0;
    final maxParticipants = (event['max_participants'] as int?) ?? 100;
    final collectedNumbers = (event['collected_numbers'] as List?)?.length ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        margin: EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['event_name'] ?? 'Lucky Generation Event',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '🎰 ${event['lottery_type'] ?? 'Mixed'} • ${event['status'] ?? 'live'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Text('🔴', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _eventStat('$participants', 'Participants'),
                _eventStat('$collectedNumbers', 'Numbers'),
                _eventStat('${(participants / maxParticipants * 100).toStringAsFixed(0)}%', 'Full'),
              ],
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: participants / maxParticipants,
                minHeight: 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            if (event['generated'] != null && event['generated'] == true) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Final numbers: ${(event['final_numbers'] as List?)?.join(', ') ?? 'N/A'}',
                      style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _eventStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class EventDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> event;
  final VoidCallback onSubmit;

  const EventDetailsSheet({required this.event, required this.onSubmit});

  @override
  State<EventDetailsSheet> createState() => _EventDetailsSheetState();
}

class _EventDetailsSheetState extends State<EventDetailsSheet> {
  late List<int> selectedNumbers;
  String generationMethod = 'frequency_based';

  @override
  void initState() {
    super.initState();
    selectedNumbers = [];
  }

  @override
  Widget build(BuildContext context) {
    final targetNumbers = (widget.event['target_numbers'] as int?) ?? 6;
    final collectedNumbers = (widget.event['collected_numbers'] as List?)?.cast<int>() ?? [];

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
                widget.event['event_name'] ?? 'Event Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          SizedBox(height: 16),
          if (widget.event['generated'] == true) ...[
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Final Numbers Generated', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: (widget.event['final_numbers'] as List?)?.cast<int>().map((num) {
                          return _numberBadge(num.toString(), true);
                        }).toList() ??
                        [],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ] else ...[
            Text('Submit Your Numbers ($selectedNumbers.length/$targetNumbers)', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(targetNumbers, (i) {
                final num = i + 1;
                final isSelected = selectedNumbers.contains(num);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedNumbers.remove(num);
                      } else if (selectedNumbers.length < targetNumbers) {
                        selectedNumbers.add(num);
                      }
                    });
                  },
                  child: _numberBadge(num.toString(), isSelected),
                );
              }),
            ),
            SizedBox(height: 24),
            Text('Community Numbers', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            _frequencyChart(collectedNumbers),
            SizedBox(height: 24),
            PrimaryButton(
              label: 'Submit Numbers',
              onPressed: selectedNumbers.length == targetNumbers ? () {
                Navigator.pop(context);
                widget.onSubmit();
              } : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _numberBadge(String number, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _frequencyChart(List<int> numbers) {
    if (numbers.isEmpty) {
      return Text('No numbers submitted yet', style: TextStyle(color: Colors.grey[600]));
    }

    Map<int, int> frequency = {};
    for (int num in numbers) {
      frequency[num] = (frequency[num] ?? 0) + 1;
    }

    final topNumbers = frequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: topNumbers.take(5).map((entry) {
          final percentage = (entry.value / numbers.length * 100).toStringAsFixed(0);
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text('${entry.key}', style: TextStyle(fontWeight: FontWeight.bold, width: 20)),
                Expanded(
                  child: LinearProgressIndicator(value: entry.value / (topNumbers.first.value)),
                ),
                SizedBox(width: 8),
                Text('$percentage%', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
