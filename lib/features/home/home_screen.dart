import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/astrology_service.dart';
import '../../../core/services/lucky_number_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../core/utils/numerology_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/lucky_number_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/primary_button.dart';
import 'widgets/lucky_card.dart';
import 'widgets/energy_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  LuckyNumbers? _todayLuckyNumbers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadDailyData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyData() async {
    final user = ref.read(userRepositoryProvider).getCurrentUser();
    if (user != null) {
      // Generate daily lucky numbers
      _todayLuckyNumbers = LuckyNumberService.generateDailyLuckyNumbers(user);
      
      // Check if this is user's first visit today
      final lastVisit = await app_date_utils.DateUtils.getLastAppVisit();
      final today = DateTime.now();
      if (lastVisit == null || !app_date_utils.DateUtils.isSameDay(lastVisit, today)) {
        // Show confetti for first daily visit
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confettiController.play();
        });
        await app_date_utils.DateUtils.saveAppVisit(today);
      }
    }
    setState(() => _isLoading = false);
  }

  void _refreshDailyData() {
    setState(() => _isLoading = true);
    _loadDailyData();
  }

  void _showLuckyTimeNotification() {
    final user = ref.read(userRepositoryProvider).getCurrentUser();
    if (user != null) {
      final luckyTime = AstrologyService.calculateLuckyTimeWindow(user);
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            gradient: AppColors.cosmicGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 60,
                color: AppColors.gold,
              ),
              const SizedBox(height: 20),
              Text(
                '🎯 Lucky Time Window',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Best Time:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            luckyTime.bestTime,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Duration:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '${luckyTime.durationInMinutes} minutes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Planetary Influence:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Chip(
                            label: Text(
                              luckyTime.planet,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: AppColors.purple.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              PrimaryButton(
                onPressed: () {
                  // Set notification for lucky time
                  NotificationService.scheduleLuckyTimeNotification(
                    DateTime.now(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification set for lucky time!'),
                      backgroundColor: AppColors.gold,
                    ),
                  );
                },
                text: 'Set Reminder',
                icon: Icons.notifications_active,
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showPersonalFormula() {
    final user = ref.read(userRepositoryProvider).getCurrentUser();
    if (user != null) {
      final formula = NumerologyUtils.generatePersonalFormula(user);
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: CustomCard(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.functions,
                  size: 50,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 15),
                Text(
                  '🔮 Your Personal Lucky Formula',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.darkPurple,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.purple),
                  ),
                  child: SelectableText(
                    formula,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'This formula changes daily based on:\n• Your birth numbers\n• Current planetary positions\n• Zodiac energy',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Got It',
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildHeader(UserProfile? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          app_date_utils.DateUtils.getAstrologicalGreeting(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Text(
                user?.name.split(' ').first ?? 'Cosmic Traveler',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    '♈',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user?.zodiacSign ?? 'Aries',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Today\'s Energy: ${_todayLuckyNumbers?.energyLevel ?? "Calculating..."}',
          style: TextStyle(
            color: AppColors.lightPurple,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyInsight() {
    final user = ref.read(userRepositoryProvider).getCurrentUser();
    if (user == null) {
      return const SizedBox.shrink();
    }
    final insight = AstrologyService.generateDailyInsight(user);
    
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.gold),
              const SizedBox(width: 10),
              Text(
                '✨ Daily Astro Insight',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            insight.message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (insight.tip.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight.tip,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyTimeCard() {
    final user = ref.read(userRepositoryProvider).getCurrentUser();
    if (user == null) return const SizedBox();
    
    final luckyTime = AstrologyService.calculateLuckyTimeWindow(user);
    
    return GestureDetector(
      onTap: _showLuckyTimeNotification,
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_filled,
                color: AppColors.gold,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🕰️ Lucky Time Today',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    luckyTime.bestTime,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${luckyTime.planet} energy is strong',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberEnergySystem() {
    final numbers = _todayLuckyNumbers?.numberEnergy ?? [];
    if (numbers.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 10),
          child: Text(
            '🎨 Number Energy Today',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              final item = numbers[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: CustomCard(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            item.number.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.energy,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      EnergyIndicator(level: item.energyLevel),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userRepositoryProvider).getCurrentUser();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background cosmic effect
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkPurple, AppColors.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Stars animation
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(
                painter: _StarsPainter(),
              ),
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -1.0,
              emissionFrequency: 0.01,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                AppColors.gold,
                AppColors.purple,
                Colors.white,
              ],
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Header with user info
                  const SizedBox(height: 20),
                  _buildHeader(user),
                  
                  // Refresh button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _refreshDailyData,
                      icon: Icon(
                        Icons.refresh,
                        color: _isLoading ? Colors.grey : AppColors.gold,
                      ),
                    ),
                  ),
                  
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Daily Insight
                          _buildDailyInsight(),
                          const SizedBox(height: 20),
                          
                          // Lucky Numbers Card
                          if (!_isLoading && _todayLuckyNumbers != null)
                            LuckyCard(luckyNumbers: _todayLuckyNumbers!),
                          const SizedBox(height: 20),
                          
                          // Lucky Time Card
                          _buildLuckyTimeCard(),
                          const SizedBox(height: 20),
                          
                          // Number Energy System
                          _buildNumberEnergySystem(),
                          const SizedBox(height: 20),
                          
                          // Personal Formula Button
                          PrimaryButton(
                            onPressed: _showPersonalFormula,
                            text: '🔮 View Your Personal Lucky Formula',
                            isOutlined: true,
                            icon: Icons.visibility,
                          ),
                          const SizedBox(height: 20),
                          
                          // Quick Actions Row
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context, 
                                    AppRoutes.lotteryGenerator,
                                  ),
                                  text: 'Generate Numbers',
                                  icon: Icons.casino,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: PrimaryButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context, 
                                    AppRoutes.history,
                                  ),
                                  text: 'View History',
                                  icon: Icons.history,
                                  isOutlined: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          
                          // Footer Disclaimer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AppStrings.disclaimer,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for stars background
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final random = Random(DateTime.now().millisecond);
    
    // Draw stars
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    // Draw twinkling stars
    final twinklePaint = Paint()
      ..color = AppColors.gold.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;
      
      canvas.drawCircle(Offset(x, y), radius, twinklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}