// lib/features/social/screens/badges_leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/custom_card.dart';
import '../providers/social_providers.dart';

class BadgesLeaderboardScreen extends ConsumerStatefulWidget {
  final String userId;

  const BadgesLeaderboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<BadgesLeaderboardScreen> createState() => _BadgesLeaderboardScreenState();
}

class _BadgesLeaderboardScreenState extends ConsumerState<BadgesLeaderboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStatsAsync = ref.watch(userStatsProvider(widget.userId));
    final userBadgesAsync = ref.watch(userBadgesProvider(widget.userId));
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements & Rankings'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Badges'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          userStatsAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (stats) => _overviewTab(context, stats),
          ),

          // Badges Tab
          userBadgesAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (badges) => _badgesTab(context, badges),
          ),

          // Leaderboard Tab
          leaderboardAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (leaderboard) => _leaderboardTab(context, leaderboard),
          ),
        ],
      ),
    );
  }

  Widget _overviewTab(BuildContext context, Map<String, dynamic> stats) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // User Stats Card
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[100],
                      ),
                      child: Center(
                        child: Text('👤', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your Rank: #${stats['rank'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard('🏆', '${stats['challenge_wins'] ?? 0}', 'Wins'),
                  _statCard('⭐', '${stats['total_points'] ?? 0}', 'Points'),
                  _statCard('🎖️', '${stats['badges_count'] ?? 0}', 'Badges'),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Achievement Progress
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next Milestone', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Master Player (50 wins)', style: TextStyle(fontSize: 13)),
                      Text('${stats['challenge_wins'] ?? 0}/50'),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ((stats['challenge_wins'] as int?) ?? 0) / 50,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Featured Achievements
        Text('Recent Achievements', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 12),
        _achievementItem('🎯 First Win', 'Won your first challenge'),
        _achievementItem('💯 Perfect Streak', '5 consecutive wins'),
        _achievementItem('🤝 Social Butterfly', 'Joined 3 pools'),
      ],
    );
  }

  Widget _badgesTab(BuildContext context, List<Map<String, dynamic>> badges) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No Badges Yet', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Text(
              'Unlock badges by achieving milestones',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final unlockedBadges = badges.where((b) => b['is_unlocked'] == true).toList();
    final lockedBadges = badges.where((b) => b['is_unlocked'] == false).toList();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (unlockedBadges.isNotEmpty) ...[
          Text('Unlocked (${unlockedBadges.length})', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: unlockedBadges.length,
            itemBuilder: (context, index) => _badgeItem(context, unlockedBadges[index], true),
          ),
          SizedBox(height: 24),
        ],
        if (lockedBadges.isNotEmpty) ...[
          Text('Locked (${lockedBadges.length})', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: lockedBadges.length,
            itemBuilder: (context, index) => _badgeItem(context, lockedBadges[index], false),
          ),
        ],
      ],
    );
  }

  Widget _leaderboardTab(BuildContext context, List<Map<String, dynamic>> leaderboard) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        final rank = index + 1;
        final isCurrentUser = entry['user_id'].toString() == widget.userId;

        return GestureDetector(
          onTap: () => _showUserProfile(context, entry),
          child: CustomCard(
            margin: EdgeInsets.only(bottom: 12),
            backgroundColor: isCurrentUser ? Colors.blue[50] : null,
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry['username'] ?? 'User',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '${entry['total_points'] ?? 0} pts',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '🏆 ${entry['challenge_wins'] ?? 0} wins',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry['total_points'] ?? 0}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${entry['badges_count'] ?? 0} badges',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _achievementItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _badgeItem(BuildContext context, Map<String, dynamic> badge, bool isUnlocked) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.amber[50] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUnlocked ? Colors.amber : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(badge['emoji'] ?? '🏆', style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text(
              badge['badge_name']?.toString().split(' ').first ?? 'Badge',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isUnlocked) ...[
              SizedBox(height: 4),
              Text(
                '${badge['progress'] ?? 0}/${badge['threshold_value'] ?? 0}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber[600]!;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.orange[700]!;
    return Colors.blue[400]!;
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(badge['badge_name'] ?? 'Badge', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(badge['emoji'] ?? '🏆', style: TextStyle(fontSize: 50)),
              ),
            ),
            SizedBox(height: 16),
            Text(badge['rarity'] ?? 'Common', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 8),
            Text(badge['unlock_condition'] ?? 'No description', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['username'] ?? 'Player', style: Theme.of(context).textTheme.titleLarge),
                    Text('#${user['global_rank']} Global', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            _userStatRow('Total Points', '${user['total_points'] ?? 0}'),
            _userStatRow('Challenge Wins', '${user['challenge_wins'] ?? 0}'),
            _userStatRow('Pool Winnings', '\$${user['pool_winnings'] ?? 0}'),
            _userStatRow('Badges', '${user['badges_count'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _userStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
