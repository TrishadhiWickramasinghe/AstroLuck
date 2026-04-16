import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:astroluck/providers/integrations_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarSyncScreen extends StatefulWidget {
  const CalendarSyncScreen({Key? key}) : super(key: key);

  @override
  State<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends State<CalendarSyncScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Sync'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<CalendarSyncProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                _buildStatusCard(provider),
                const SizedBox(height: 24),

                // Connected Calendars or Connection Section
                if (provider.connectedCalendars.isEmpty)
                  _buildConnectionSection(context, provider)
                else
                  _buildCalendarsSection(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(CalendarSyncProvider provider) {
    final connected = provider.connectedCalendars.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: connected
              ? [Colors.blue, Colors.blueAccent]
              : [Colors.grey, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
            child: Center(
              child: Icon(
                Icons.calendar_today,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connected ? 'Syncing' : 'Not Syncing',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  connected
                      ? '${provider.connectedCalendars.length} calendar(s) connected'
                      : 'Connect your calendar to sync lucky dates and events',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSection(BuildContext context, CalendarSyncProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect Calendar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sync your lucky dates, lucky times, and lottery drawing dates to your calendar',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),

        // Google Calendar
        _buildCalendarOption(
          context,
          provider,
          'Google Calendar',
          'Sync with your Google Calendar account',
          Icons.calendar_today,
          Colors.red,
          () => _handleGoogleAuth(context, provider),
        ),
        const SizedBox(height: 12),

        // Apple Calendar
        _buildCalendarOption(
          context,
          provider,
          'Apple Calendar',
          'Sync with your Apple Calendar account',
          Icons.calendar_today,
          Colors.grey,
          () => _handleAppleAuth(context, provider),
        ),
      ],
    );
  }

  Widget _buildCalendarOption(
    BuildContext context,
    CalendarSyncProvider provider,
    String name,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(name),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: provider.isLoading ? null : onPressed,
        enabled: !provider.isLoading,
      ),
    );
  }

  Widget _buildCalendarsSection(BuildContext context, CalendarSyncProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connected Calendars',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Calendars List
        ...provider.connectedCalendars.map((calendar) {
          return _buildCalendarCard(context, provider, calendar);
        }).toList(),

        const SizedBox(height: 24),

        // Add Another Calendar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _showAddCalendarDialog(context, provider),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.deepPurple),
            ),
            child: const Text(
              '+ Add Another Calendar',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Sync Preferences
        _buildSyncPreferences(context, provider),
      ],
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    CalendarSyncProvider provider,
    Map<String, dynamic> calendar,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
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
                      calendar['type'] ?? 'Calendar',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      calendar['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last sync: ${calendar['last_sync'] ?? 'Never'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _showDisconnectDialog(context, provider, calendar['id']),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSyncSettingsDialog(context, provider, calendar),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sync Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncPreferences(BuildContext context, CalendarSyncProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What to Sync',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Lucky Dates'),
            subtitle: const Text('Sync your personal lucky dates'),
            value: provider.syncLuckyDates ?? true,
            onChanged: (value) {
              provider.updateSyncPreferences(syncLuckyDates: value ?? true);
            },
            activeColor: Colors.deepPurple,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Lucky Times'),
            subtitle: const Text('Sync your lucky times for the day'),
            value: provider.syncLuckyTimes ?? true,
            onChanged: (value) {
              provider.updateSyncPreferences(syncLuckyTimes: value ?? true);
            },
            activeColor: Colors.deepPurple,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Lottery Drawings'),
            subtitle: const Text('Sync upcoming lottery drawing dates'),
            value: provider.syncLotteryDrawings ?? true,
            onChanged: (value) {
              provider.updateSyncPreferences(syncLotteryDrawings: value ?? true);
            },
            activeColor: Colors.deepPurple,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleAuth(BuildContext context, CalendarSyncProvider provider) async {
    final result = await provider.initiateGoogleAuth();
    if (result['success'] && result['auth_url'] != null) {
      if (await canLaunchUrl(Uri.parse(result['auth_url']))) {
        await launchUrl(
          Uri.parse(result['auth_url']),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  Future<void> _handleAppleAuth(BuildContext context, CalendarSyncProvider provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Calendar support coming soon'),
      ),
    );
  }

  void _showAddCalendarDialog(BuildContext context, CalendarSyncProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Calendar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Google Calendar'),
              onTap: () {
                Navigator.pop(context);
                _handleGoogleAuth(context, provider);
              },
            ),
            ListTile(
              title: const Text('Apple Calendar'),
              onTap: () {
                Navigator.pop(context);
                _handleAppleAuth(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncSettingsDialog(
    BuildContext context,
    CalendarSyncProvider provider,
    Map<String, dynamic> calendar,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Lucky Dates'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.deepPurple,
            ),
            CheckboxListTile(
              title: const Text('Lucky Times'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.deepPurple,
            ),
            CheckboxListTile(
              title: const Text('Lottery Drawings'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.deepPurple,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(
    BuildContext context,
    CalendarSyncProvider provider,
    String calendarId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Calendar?'),
        content: const Text(
          'Synced events will remain in your calendar. You can reconnect anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.disconnectCalendar(calendarId);
              Navigator.pop(context);
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
