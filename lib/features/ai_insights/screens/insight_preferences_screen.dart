"""Insight Preferences Screen - Configure notification and content preferences"""

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astroluck/core/models/user_insight_preference.dart';
import 'package:astroluck/providers/ai_insights_providers.dart';

class InsightPreferencesScreen extends ConsumerStatefulWidget {
  const InsightPreferencesScreen({Key? key}) : super(key: key);

  @override
  _InsightPreferencesScreenState createState() =>
      _InsightPreferencesScreenState();
}

class _InsightPreferencesScreenState
    extends ConsumerState<InsightPreferencesScreen> {
  late TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);
  String selectedTimezone = 'UTC';
  Map<String, bool> selectedChannels = {
    'email': true,
    'push': true,
    'whatsapp': false,
  };
  Set<String> selectedContentTypes = {'general', 'lucky_times', 'career'};
  String selectedWritingStyle = 'inspiring';

  @override
  Widget build(BuildContext context) {
    final preferencesAsync = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Insight Preferences'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: preferencesAsync.when(
        data: (prefs) => _buildPreferencesForm(context, prefs),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPreferencesForm(
    BuildContext context,
    UserInsightPreference? prefs,
  ) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Enable/Disable Section
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Enable Daily Insights'),
                  subtitle: Text('Receive personalized insights daily'),
                  value: prefs?.insightsEnabled ?? true,
                  onChanged: (value) async {
                    final success = await ref
                        .read(preferencesProvider.notifier)
                        .toggleInsights(value);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Preference updated')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Delivery Time Section
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text('Delivery Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: Icon(Icons.edit),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
                SizedBox(height: 12),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedTimezone,
                  items: [
                    'UTC',
                    'EST',
                    'CST',
                    'MST',
                    'PST',
                    'IST',
                    'CET',
                  ]
                      .map((tz) => DropdownMenuItem(value: tz, child: Text(tz)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedTimezone = value);
                    }
                  },
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(preferencesProvider.notifier)
                          .updateDeliveryTime(
                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            selectedTimezone,
                          );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Delivery time updated')),
                        );
                      }
                    },
                    child: Text('Save Delivery Time'),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Notification Channels
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Channels',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                CheckboxListTile(
                  title: Text('Email'),
                  subtitle: Text('Receive insights via email'),
                  value: selectedChannels['email'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      selectedChannels['email'] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Push Notification'),
                  subtitle: Text('Receive push notifications'),
                  value: selectedChannels['push'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      selectedChannels['push'] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('WhatsApp'),
                  subtitle: Text('Receive insights via WhatsApp'),
                  value: selectedChannels['whatsapp'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      selectedChannels['whatsapp'] = value ?? false;
                    });
                  },
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(preferencesProvider.notifier)
                          .updateChannels(selectedChannels);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Channels updated')),
                        );
                      }
                    },
                    child: Text('Save Channels'),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Content Preferences
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text('Insight Types'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'General',
                    'Lucky Times',
                    'Career',
                    'Romance',
                    'Finance',
                    'Health',
                  ]
                      .map((type) => FilterChip(
                        label: Text(type),
                        selected: selectedContentTypes
                            .contains(type.toLowerCase().replaceAll(' ', '_')),
                        onSelected: (selected) {
                          setState(() {
                            final key = type.toLowerCase().replaceAll(' ', '_');
                            if (selected) {
                              selectedContentTypes.add(key);
                            } else {
                              selectedContentTypes.remove(key);
                            }
                          });
                        },
                      ))
                      .toList(),
                ),
                SizedBox(height: 16),
                Text('Writing Style'),
                SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedWritingStyle,
                  items: [
                    'inspiring',
                    'scientific',
                    'mystical',
                  ]
                      .map((style) => DropdownMenuItem(
                        value: style,
                        child: Text(style.toUpperCase()),
                      ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedWritingStyle = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Quiet Hours
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiet Hours',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Enable Quiet Hours'),
                  subtitle: Text('Don\\'t send notifications during specific times'),
                  value: false,
                  onChanged: (value) {},
                ),
                SizedBox(height: 12),
                Text('No notifications from'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '22:00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('to'),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '08:00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Reset Button
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Reset Preferences'),
                content: Text('Reset all preferences to defaults?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(preferencesProvider.notifier)
                          .resetPreferences();
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Preferences reset')),
                        );
                      }
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text('Reset to Defaults', style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: 32),
      ],
    );
  }
}
