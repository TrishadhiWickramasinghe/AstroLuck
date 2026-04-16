// lib/features/social/screens/community_pools_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/primary_button.dart';
import '../providers/social_providers.dart';

class CommunityPoolsScreen extends ConsumerStatefulWidget {
  const CommunityPoolsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunityPoolsScreen> createState() => _CommunityPoolsScreenState();
}

class _CommunityPoolsScreenState extends ConsumerState<CommunityPoolsScreen> {
  bool _showCreatePool = false;

  @override
  Widget build(BuildContext context) {
    final poolsAsync = ref.watch(communityPoolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Community Lottery Pools'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() => _showCreatePool = true);
            },
          ),
        ],
      ),
      body: poolsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (pools) {
          if (pools.isEmpty) {
            return _emptyState(context);
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Stats Overview
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Pools',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statTile('${pools.length}', 'Total Pools'),
                        _statTile('${pools.where((p) => p['status'] == 'active').length}', 'Active'),
                        _statTile('${pools.where((p) => p['status'] == 'completed').length}', 'Completed'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Pools List
              Text(
                'Available Pools',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              ...pools.map((pool) => PoolCard(pool: pool, onTap: () => _showPoolDetails(context, pool))),
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
          Icon(Icons.people, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Pools Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Create or join a lottery pool to play with friends',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          PrimaryButton(
            label: 'Create Pool',
            onPressed: () {
              setState(() => _showCreatePool = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _showPoolDetails(BuildContext context, Map<String, dynamic> pool) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PoolDetailsSheet(pool: pool),
    );
  }
}

class PoolCard extends StatelessWidget {
  final Map<String, dynamic> pool;
  final VoidCallback onTap;

  const PoolCard({required this.pool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final members = (pool['members'] as List?)?.length ?? 0;
    final maxMembers = pool['max_members'] ?? 0;
    final totalWinnings = pool['total_winnings'] ?? 0;

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
                        pool['pool_name'] ?? 'Lottery Pool',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${pool['lottery_type'] ?? 'Mixed'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: pool['status'] == 'active' ? Colors.green[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pool['status'] ?? 'unknown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: pool['status'] == 'active' ? Colors.green[700] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip('💰 \$${pool['buy_in_amount'] ?? 0}', 'Buy-in'),
                _infoChip('👥 $members/$maxMembers', 'Members'),
                _infoChip('🎁 \$${totalWinnings ?? 0}', 'Winnings'),
              ],
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: maxMembers > 0 ? members / maxMembers : 0,
                minHeight: 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String title, String label) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class PoolDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> pool;

  const PoolDetailsSheet({required this.pool});

  @override
  Widget build(BuildContext context) {
    final members = (pool['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pool['pool_name'] ?? 'Pool Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _detailRow('Pool Type', pool['lottery_type'] ?? 'Unknown'),
                _detailRow('Buy-in Amount', '\$${pool['buy_in_amount'] ?? 0}'),
                _detailRow('Split Strategy', pool['split_strategy']?.toString().replaceAll('_', ' ') ?? 'Unknown'),
                _detailRow('Total Winnings', '\$${pool['total_winnings'] ?? 0}'),
                SizedBox(height: 16),
                Text('Pool Members (${members.length})', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8),
                ...members.map((member) => _memberTile(member)),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Join Pool',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _memberTile(Map<String, dynamic> member) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(member['username'] ?? 'Member'),
      subtitle: Text('${member['num_shares']} shares (${member['share_percentage']?.toStringAsFixed(1)}%)'),
      trailing: Text('\$${member['contribution'] ?? 0}', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
