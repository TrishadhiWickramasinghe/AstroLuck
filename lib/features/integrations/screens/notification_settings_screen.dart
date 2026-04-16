import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:astroluck/providers/integrations_providers.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Channels
                _buildChannelsSection(context, provider),
                const SizedBox(height: 24),

                // Notification Types
                _buildNotificationTypesSection(context, provider),
                const SizedBox(height: 24),

                // Timing Settings
                _buildTimingSection(context, provider),
                const SizedBox(height: 24),

                // Quiet Hours
                _buildQuietHoursSection(context, provider),
                const SizedBox(height: 24),

                // Test Notification
                _buildTestSection(context, provider),
                const SizedBox(height: 24),

                // Notification History
                _buildHistorySection(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChannelsSection(BuildContext context, NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Channels',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Choose how you want to receive notifications',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        // Email Channel
        _buildChannelCard(
          'Email',
          'Get important updates via email',
          Icons.mail,
          Colors.blue,
          provider.emailEnabled ?? true,
          (value) {
            provider.updatePreferences(emailEnabled: value);
          },
          () => _showEmailSettings(context, provider),
        ),
        const SizedBox(height: 12),

        // SMS Channel
        _buildChannelCard(
          'SMS',
          'Get urgent alerts via text message',
          Icons.textsms,
          Colors.green,
          provider.smsEnabled ?? false,
          (value) {
            provider.updatePreferences(smsEnabled: value);
          },
          () => _showSMSSettings(context, provider),
        ),
        const SizedBox(height: 12),

        // Push Notifications
        _buildChannelCard(
          'Push Notifications',
          'Get real-time notifications in the app',
          Icons.notifications,
          Colors.orange,
          provider.pushEnabled ?? true,
          (value) {
            provider.updatePreferences(pushEnabled: value);
          },
          null,
        ),
      ],
    );
  }

  Widget _buildChannelCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
    VoidCallback? onSettings,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (onSettings != null)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: onSettings,
                  iconSize: 20,
                ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.deepPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesSection(BuildContext context, NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What to Notify',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildNotificationTypeItem(
          'Daily Lucky Numbers',
          'Your personalized lucky numbers every morning',
          Icons.calculate,
          true,
          (value) {},
        ),
        const SizedBox(height: 12),
        _buildNotificationTypeItem(
          'Lottery Alerts',
          'Reminders for upcoming lottery drawings',
          Icons.sports_score,
          true,
          (value) {},
        ),
        const SizedBox(height: 12),
        _buildNotificationTypeItem(
          'Pool Invitations',
          'When someone invites you to a lottery pool',
          Icons.group,
          true,
          (value) {},
        ),
        const SizedBox(height: 12),
        _buildNotificationTypeItem(
          'Challenge Updates',
          'Updates on challenges you\'re participating in',
          Icons.emoji_events,
          true,
          (value) {},
        ),
        const SizedBox(height: 12),
        _buildNotificationTypeItem(
          'Insights & Analytics',
          'Weekly analysis and success insights',
          Icons.insights,
          false,
          (value) {},
        ),
        const SizedBox(height: 12),
        _buildNotificationTypeItem(
          'Promotions',
          'Special offers and discounts',
          Icons.local_offer,
          false,
          (value) {},
        ),
      ],
    );
  }

  Widget _buildNotificationTypeItem(
    String title,
    String description,
    IconData icon,
    bool enabled,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSection(BuildContext context, NotificationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferred Notification Times',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Morning Time
          ListTile(
            title: const Text('Morning Notifications'),
            subtitle: Text(provider.morningTime ?? '08:00 AM'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(context, provider, true),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          // Evening Time
          ListTile(
            title: const Text('Evening Notifications'),
            subtitle: Text(provider.eveningTime ?? '06:00 PM'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(context, provider, false),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection(BuildContext context, NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiet Hours',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'No notifications during these hours',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enable Quiet Hours'),
          subtitle: const Text('Mute notifications during sleep time'),
          value: provider.quietHoursEnabled ?? false,
          onChanged: (value) {
            provider.updatePreferences(quietHoursEnabled: value);
          },
          activeColor: Colors.deepPurple,
          contentPadding: EdgeInsets.zero,
        ),
        if (provider.quietHoursEnabled ?? false) ...[
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(provider.quietHoursStart ?? '11:00 PM'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectQuietHourTime(context, provider, true),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(provider.quietHoursEnd ?? '07:00 AM'),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectQuietHourTime(context, provider, false),
          ),
        ],
      ],
    );
  }

  Widget _buildTestSection(BuildContext context, NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Send a test notification to verify your settings',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _sendTestEmail(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Test Email'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: provider.smsEnabled ?? false
                    ? () => _sendTestSMS(context, provider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Test SMS'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if ((provider.notificationHistory ?? []).isEmpty)
          Center(
            child: Text(
              'No notifications yet',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          )
        else
          ...provider.notificationHistory!.take(5).map((notification) {
            return _buildHistoryItem(notification);
          }).toList(),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> notification) {
    IconData icon;
    Color color;

    switch (notification['channel']) {
      case 'email':
        icon = Icons.mail;
        color = Colors.blue;
        break;
      case 'sms':
        icon = Icons.textsms;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['type'] ?? 'Notification',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  notification['sent_at'] ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Sent',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailSettings(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email Frequency',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...['Daily', 'Weekly', 'Never'].map((freq) {
              return RadioListTile(
                title: Text(freq),
                value: freq,
                groupValue: 'Daily',
                onChanged: (value) {},
                activeColor: Colors.deepPurple,
              );
            }).toList(),
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

  void _showSMSSettings(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SMS Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 (234) 567-8900',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification code sent to phone'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Verify Phone'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    NotificationProvider provider,
    bool isMorning,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      if (isMorning) {
        provider.updatePreferences(morningTime: timeStr);
      } else {
        provider.updatePreferences(eveningTime: timeStr);
      }
    }
  }

  Future<void> _selectQuietHourTime(
    BuildContext context,
    NotificationProvider provider,
    bool isStart,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        provider.updatePreferences(quietHoursStart: timeStr);
      } else {
        provider.updatePreferences(quietHoursEnd: timeStr);
      }
    }
  }

  Future<void> _sendTestEmail(BuildContext context, NotificationProvider provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending test email...')),
    );
    await provider.sendTestEmail();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test email sent successfully!')),
      );
    }
  }

  Future<void> _sendTestSMS(BuildContext context, NotificationProvider provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending test SMS...')),
    );
    await provider.sendTestSMS();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test SMS sent successfully!')),
      );
    }
  }
}
