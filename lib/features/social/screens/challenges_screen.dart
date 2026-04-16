// lib/features/social/screens/challenges_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/primary_button.dart';
import '../providers/social_providers.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Challenges'),
        elevation: 0,
      ),
      body: challengesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (challenges) {
          if (challenges.isEmpty) {
            return _emptyState(context);
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Featured Challenge
              if (challenges.isNotEmpty) ...[
                Text('Featured Challenge', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 12),
                FeaturedChallengeCard(challenge: challenges.first, onTap: () => _showChallengeDetails(context, challenges.first)),
                SizedBox(height: 24),
              ],

              // Stats
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Performance', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statColumn('2', 'Joined'),
                        _statColumn('1', 'Won'),
                        _statColumn('\$150', 'Earned'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Active Challenges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active Challenges (${challenges.length})', style: Theme.of(context).textTheme.titleMedium),
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                ],
              ),
              SizedBox(height: 12),
              ...challenges.skip(1).map((challenge) => ChallengeCard(
                challenge: challenge,
                onTap: () => _showChallengeDetails(context, challenge),
              )),
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
          Icon(Icons.sports_score, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Active Challenges',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Check back soon for weekly competitions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _showChallengeDetails(BuildContext context, Map<String, dynamic> challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChallengeDetailsSheet(challenge: challenge),
    );
  }
}

class FeaturedChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final VoidCallback onTap;

  const FeaturedChallengeCard({required this.challenge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prizePool = (challenge['prize_pool'] as num?)?.toDouble() ?? 0;
    final numWinners = (challenge['num_winners'] as int?) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
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
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              challenge['challenge_name'] ?? 'Mystery Challenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        challenge['challenge_type']?.toString().replaceAll('_', ' ') ?? 'Challenge',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _featureInfo('🏆', 'Prize Pool', '\$${prizePool.toStringAsFixed(0)}'),
                _featureInfo('👥', 'Winners', '$numWinners'),
                _featureInfo('💰', 'Entry Fee', '\$${challenge['participation_fee'] ?? 0}'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Enter Challenge',
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.blue[700]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureInfo(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white70)),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final VoidCallback onTap;

  const ChallengeCard({required this.challenge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prizePool = (challenge['prize_pool'] as num?)?.toDouble() ?? 0;
    final participationFee = (challenge['participation_fee'] as num?)?.toDouble() ?? 0;

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
                        challenge['challenge_name'] ?? 'Challenge',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        challenge['challenge_type']?.toString().replaceAll('_', ' ') ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _challengeInfo('Prize Pool', '\$${prizePool.toStringAsFixed(0)}', Colors.blue),
                _challengeInfo('Entry Fee', '\$${participationFee.toStringAsFixed(0)}', Colors.red),
                _challengeInfo('Winners', '${challenge['num_winners'] ?? 0}', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class ChallengeDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> challenge;

  const ChallengeDetailsSheet({required this.challenge});

  @override
  State<ChallengeDetailsSheet> createState() => _ChallengeDetailsSheetState();
}

class _ChallengeDetailsSheetState extends State<ChallengeDetailsSheet> {
  TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prizePool = (widget.challenge['prize_pool'] as num?)?.toDouble() ?? 0;
    final numWinners = (widget.challenge['num_winners'] as int?) ?? 0;

    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.challenge['challenge_name'] ?? 'Challenge',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.challenge['challenge_type']?.toString().replaceAll('_', ' ') ?? 'Unknown',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          _detailRow('Prize Pool', '\$${prizePool.toStringAsFixed(0)}'),
          _detailRow('Winners', '$numWinners'),
          _detailRow('Entry Fee', '\$${widget.challenge['participation_fee'] ?? 0}'),
          _detailRow('Lottery Type', widget.challenge['lottery_type'] ?? 'Unknown'),
          SizedBox(height: 16),
          Text('How to Participate', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Text(
            '1. Analyze the challenge\n2. Submit your answer\n3. Wait for results\n4. Claim your prize if you win!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          TextField(
            controller: answerController,
            decoration: InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(),
              hintText: 'Enter your numbers or answer',
            ),
          ),
          SizedBox(height: 16),
          PrimaryButton(
            label: 'Submit Answer - \$${widget.challenge['participation_fee'] ?? 0}',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Answer submitted! Results in 24 hours.')),
              );
            },
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

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }
}
