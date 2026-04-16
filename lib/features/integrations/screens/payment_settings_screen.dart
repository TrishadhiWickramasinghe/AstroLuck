import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:astroluck/providers/integrations_providers.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Settings'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<PaymentProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscription Card
                _buildSubscriptionCard(context, provider),
                const SizedBox(height: 24),

                // Payment Methods
                _buildPaymentMethodsSection(context, provider),
                const SizedBox(height: 24),

                // Upgrade Options
                _buildUpgradeOptions(context, provider),
                const SizedBox(height: 24),

                // Billing History
                _buildBillingHistory(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, PaymentProvider provider) {
    final plan = provider.currentSubscription?['plan'] ?? 'free';
    final price = provider.currentSubscription?['price_per_month'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(plan),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price == 0 ? 'Free Forever' : '\$${price.toStringAsFixed(2)}/month',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeaturesList(plan),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(String plan) {
    switch (plan.toLowerCase()) {
      case 'platinum':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 'gold':
        return [const Color(0xFFDAAA2B), const Color(0xFFFFC966)];
      case 'premium':
        return [Colors.blue, Colors.blueAccent];
      default:
        return [Colors.grey, Colors.grey.shade400];
    }
  }

  Widget _buildFeaturesList(String plan) {
    Map<String, List<String>> features = {
      'free': [
        '5 Community Pools',
        '10 Challenge Entries',
        '1 Astrologer Session/month',
      ],
      'premium': [
        '20 Community Pools',
        '50 Challenge Entries',
        '5 Astrologer Sessions/month',
        'Daily Insights',
      ],
      'gold': [
        '50 Community Pools',
        '200 Challenge Entries',
        '10 Astrologer Sessions/month',
        'Daily Insights',
        'Priority Support',
      ],
      'platinum': [
        'Unlimited Pools',
        'Unlimited Challenges',
        'Unlimited Sessions',
        'Daily Insights',
        'VIP Support',
        'Ad-free Experience',
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (features[plan.toLowerCase()] ?? [])
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPaymentMethodsSection(BuildContext context, PaymentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if ((provider.paymentMethods ?? []).isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.credit_card, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text(
                  'No payment methods saved',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ...provider.paymentMethods!.map((method) {
            return _buildPaymentMethodCard(method);
          }).toList(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _showAddPaymentDialog(context, provider),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.deepPurple),
            ),
            child: const Text(
              '+ Add Payment Method',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: method['is_default'] ? Colors.deepPurple : Colors.grey.shade200,
          width: method['is_default'] ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            method['type'] == 'card' ? Icons.credit_card : Icons.payment,
            color: Colors.deepPurple,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${method['brand']?.toUpperCase() ?? 'Card'} •••• ${method['last_four']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Expires ${method['expiry']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                if (method['is_default'])
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Default Method',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Set as Default'),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text('Remove'),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeOptions(BuildContext context, PaymentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upgrade Your Plan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPlanCard(
                'Premium',
                '\$9.99',
                'month',
                ['20 Pools', '5 Sessions', 'Daily Insights'],
                Colors.blue,
                () => _handleUpgrade(context, provider, 'premium'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPlanCard(
                'Gold',
                '\$19.99',
                'month',
                ['50 Pools', '10 Sessions', 'Priority Support'],
                const Color(0xFF8B6914),
                () => _handleUpgrade(context, provider, 'gold'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPlanCard(
                'Platinum',
                '\$49.99',
                'month',
                ['Unlimited All', 'VIP Support', 'Ad-free'],
                const Color(0xFFFFD700),
                () => _handleUpgrade(context, provider, 'platinum'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    String period,
    List<String> features,
    Color color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/$period',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...features
                .map((feature) => Text(
                      '• $feature',
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingHistory(BuildContext context, PaymentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if ((provider.paymentHistory ?? []).isEmpty)
          Center(
            child: Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          )
        else
          ...provider.paymentHistory!.map((payment) {
            return _buildPaymentHistoryItem(payment);
          }).toList(),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['type']?.toUpperCase() ?? 'Transaction',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  payment['date'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${payment['amount'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: payment['status'] == 'completed'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  payment['status']?.toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: payment['status'] == 'completed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, PaymentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit/Debit Card'),
              subtitle: const Text('Visa, Mastercard, American Express'),
              onTap: () {
                Navigator.pop(context);
                _showCardForm(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('PayPal'),
              subtitle: const Text('Link your PayPal account'),
              onTap: () {
                Navigator.pop(context);
                // Handle PayPal linking
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCardForm(BuildContext context, PaymentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'CVC',
                    ),
                  ),
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade(BuildContext context, PaymentProvider provider, String plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgrading to $plan plan...'),
      ),
    );
    // Handle upgrade logic
  }
}
