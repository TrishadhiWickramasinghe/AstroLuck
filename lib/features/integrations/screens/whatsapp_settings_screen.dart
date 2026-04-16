import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:astroluck/providers/integrations_providers.dart';

class WhatsAppSettingsScreen extends StatefulWidget {
  const WhatsAppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WhatsAppSettingsScreen> createState() => _WhatsAppSettingsScreenState();
}

class _WhatsAppSettingsScreenState extends State<WhatsAppSettingsScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _codeController;
  bool _showCodeInput = false;
  String? _connectionId;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Integration'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<WhatsAppProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Status Card
                _buildStatusCard(provider),
                const SizedBox(height: 24),

                // Connected Section
                if (provider.isConnected)
                  _buildConnectedSection(context, provider)
                else
                  _buildConnectionSection(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(WhatsAppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: provider.isConnected
              ? [Colors.green, Colors.greenAccent]
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
                Icons.checkcircle,
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
                  provider.isConnected ? 'Connected' : 'Not Connected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.isConnected
                      ? provider.connectedPhone ?? 'WhatsApp is active'
                      : 'Connect WhatsApp to get daily lucky numbers',
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

  Widget _buildConnectionSection(BuildContext context, WhatsAppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect WhatsApp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Receive daily lucky numbers and lottery alerts directly on WhatsApp',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),

        // Phone Number Input
        if (!_showCodeInput) ...[
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+1 (234) 567-8900',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'WhatsApp Phone Number',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () => _handleInitiate(context, provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Send Verification Code'),
            ),
          ),
        ] else ...[
          // Verification Code Input
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '000000',
              prefixIcon: Icon(Icons.security),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'Verification Code',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          setState(() => _showCodeInput = false);
                          _codeController.clear();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleVerify(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConnectedSection(BuildContext context, WhatsAppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Daily Numbers Toggle
        SwitchListTile(
          title: const Text('Daily Lucky Numbers'),
          subtitle: const Text('Get your lucky numbers every morning'),
          value: provider.receiveDailyNumbers ?? false,
          onChanged: (value) {
            provider.updatePreferences(receiveDailyNumbers: value);
          },
          activeColor: Colors.deepPurple,
        ),

        // Alerts Toggle
        SwitchListTile(
          title: const Text('Lottery Alerts'),
          subtitle: const Text('Get notified about lottery opportunities'),
          value: provider.receiveAlerts ?? false,
          onChanged: (value) {
            provider.updatePreferences(receiveAlerts: value);
          },
          activeColor: Colors.deepPurple,
        ),

        const SizedBox(height: 24),

        // Notification Time
        ListTile(
          title: const Text('Daily Notification Time'),
          subtitle: Text(provider.notificationTime ?? '08:00 AM'),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectTime(context, provider),
        ),

        const SizedBox(height: 24),

        // Disconnect Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showDisconnectDialog(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Disconnect WhatsApp'),
          ),
        ),

        const SizedBox(height: 16),

        // Message Statistics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Messages Sent',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${provider.messageCount ?? 0}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Message',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        provider.lastMessageSent ?? 'Never',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleInitiate(BuildContext context, WhatsAppProvider provider) async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your WhatsApp phone number')),
      );
      return;
    }

    final result = await provider.initiateConnection(_phoneController.text);
    if (result['success'] && mounted) {
      setState(() {
        _showCodeInput = true;
        _connectionId = result['connection_id'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent to WhatsApp')),
      );
    }
  }

  Future<void> _handleVerify(BuildContext context, WhatsAppProvider provider) async {
    if (_codeController.text.isEmpty || _codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    final result = await provider.verifyConnection(_connectionId!, _codeController.text);
    if (result['success'] && mounted) {
      setState(() => _showCodeInput = false);
      _phoneController.clear();
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp connected successfully!')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, WhatsAppProvider provider) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      provider.updatePreferences(notificationTime: timeStr);
    }
  }

  void _showDisconnectDialog(BuildContext context, WhatsAppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect WhatsApp?'),
        content: const Text(
          'You will no longer receive daily numbers and alerts on WhatsApp. You can reconnect anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.disconnect();
              Navigator.pop(context);
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
