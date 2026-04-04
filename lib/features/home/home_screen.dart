import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/user_model.dart';
import '../../core/models/lucky_number_model.dart';
import '../../core/services/lucky_number_service.dart';
import '../../data/local/local_storage.dart';
import '../../routes/app_routes.dart';
import '../../widgets/lucky_card.dart';
import '../../widgets/energy_indicator.dart';
import '../../widgets/custom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LocalStorageService _storage;
  UserProfile? _user;
  LuckyNumbers? _luckyNumbers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _storage = LocalStorageService();
    await _storage.initialize();
    
    _loadUserAndNumbers();
  }

  void _loadUserAndNumbers() {
    setState(() {
      _isLoading = true;
    });

    _user = _storage.getUserProfile();
    if (_user == null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
      return;
    }

    _luckyNumbers = _storage.getDailyLuckyNumbers();
    
    if (_luckyNumbers == null || !_isSameDay(_luckyNumbers!.generatedDate, DateTime.now())) {
      _generateNewNumbers();
    }

    setState(() {
      _isLoading = false;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _generateNewNumbers() {
    if (_user != null) {
      final numbers = LuckyNumberService.generateDailyLuckyNumbers(
        _user!,
        lotteryType: _user!.favoriteLotteryTypes.isNotEmpty
            ? _user!.favoriteLotteryTypes.first
            : '6/49',
      );
      _storage.saveDailyLuckyNumbers(numbers);
      _luckyNumbers = numbers;
    }
  }

  void _refreshNumbers() {
    _generateNewNumbers();
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lucky numbers refreshed! ✨'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareNumbers() {
    if (_luckyNumbers == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Numbers copied to clipboard! 📋'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.darkPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.deepCosmicGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  _refreshNumbers();
                },
                color: AppColors.gold,
                backgroundColor: AppColors.darkPurple,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getAstrologicalGreeting(),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_user != null)
                        Text(
                          _user!.name,
                          style: const TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 24),

                      if (_luckyNumbers != null) ...[
                        LuckyNumberCard(
                          primaryNumbers: _luckyNumbers!.primaryNumbers,
                          secondaryNumbers: _luckyNumbers!.secondaryNumbers,
                          luckyColor: _luckyNumbers!.luckyColor,
                          luckyColorHex: _luckyNumbers!.luckyColorHex,
                          energyStatus: _luckyNumbers!.energyStatus,
                          fortuneMessage: _luckyNumbers!.fortuneMessage,
                          luckyHour: _luckyNumbers!.luckyHour,
                          moonPhase: _luckyNumbers!.moonPhase,
                          onShare: _shareNumbers,
                          onSave: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Numbers saved! 💾'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (_luckyNumbers != null)
                        Center(
                          child: EnergyIndicator(
                            energyLevel: _luckyNumbers!.energyLevel,
                            energyStatus: _luckyNumbers!.energyStatus,
                            size: 140,
                          ),
                        ),
                      const SizedBox(height: 24),

                      if (_luckyNumbers != null) ...[
                        _buildInfoCard(
                          title: AppStrings.zodiacSign,
                          value: _luckyNumbers!.zodiacInfluence,
                          icon: Icons.star,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: AppStrings.lifePathNumber,
                          value: _luckyNumbers!.lifePathNumber.toString(),
                          icon: Icons.calculate,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: AppStrings.destinyNumber,
                          value: _luckyNumbers!.destinyNumber.toString(),
                          icon: Icons.lightbulb,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: AppStrings.planetaryDay,
                          value: _luckyNumbers!.planetaryDay,
                          icon: Icons.public,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: AppStrings.moonPhase,
                          value: _luckyNumbers!.moonPhase,
                          icon: Icons.brightness_3,
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (_luckyNumbers != null)
                        CustomCard(
                          gradient: AppColors.cosmicGradient,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🔮 Daily Cosmic Insight',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                LuckyNumberService.generateAstrologyInsight(
                                  _luckyNumbers!.zodiacInfluence,
                                  _luckyNumbers!.energyLevel,
                                ),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: 'Generate',
                              icon: Icons.casino,
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.lotteryGenerator);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              label: 'History',
                              icon: Icons.history,
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.history);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkPurple.withValues(alpha: 0.5),
                          border: Border.all(color: AppColors.gold, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          AppStrings.disclaimerText,
                          style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.darkPurple,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.lightGrey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: AppStrings.lottery,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppStrings.history,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.settings,
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).pushNamed(AppRoutes.lotteryGenerator);
              break;
            case 2:
              Navigator.of(context).pushNamed(AppRoutes.history);
              break;
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.settings);
              break;
          }
        },
      ),
    );
  }

  String getAstrologicalGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '🌙 Late Night Insights, Stargazer!';
    } else if (hour < 12) {
      return '🌅 Good Morning, Starseeker!';
    } else if (hour < 18) {
      return '☀️ Good Afternoon, Celestial Friend!';
    } else {
      return '🌙 Good Evening, Mystic Wanderer!';
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 14),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.gold, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
