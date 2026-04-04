import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/user_model.dart';
import '../../core/models/lucky_number_model.dart';
import '../../core/services/lucky_number_service.dart';
import '../../core/utils/lottery_utils.dart';
import '../../data/local/local_storage.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';

class LotteryGeneratorScreen extends StatefulWidget {
  const LotteryGeneratorScreen({super.key});

  @override
  State<LotteryGeneratorScreen> createState() => _LotteryGeneratorScreenState();
}

class _LotteryGeneratorScreenState extends State<LotteryGeneratorScreen> {
  late LocalStorageService _storage;
  UserProfile? _user;
  String? _selectedLotteryType;
  LuckyNumbers? _luckyNumbers;
  List<int>? _generatedNumbers;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _storage = LocalStorageService();
    await _storage.initialize();
    _user = _storage.getUserProfile();
    _luckyNumbers = _storage.getDailyLuckyNumbers();
    
    // Set first favorite lottery type as default
    if (_user?.favoriteLotteryTypes.isNotEmpty ?? false) {
      _selectedLotteryType = _user!.favoriteLotteryTypes.first;
    } else {
      _selectedLotteryType = '6/49';
    }
    setState(() {});
  }

  void _generateNumbers() {
    if (_user == null || _selectedLotteryType == null) return;
    
    setState(() {
      _generatedNumbers = LotteryUtils.generateLotteryNumbers(
        _luckyNumbers?.dailyLuckyNumber ?? 7,
        _selectedLotteryType!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.generatorTitle),
        backgroundColor: AppColors.darkPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.deepCosmicGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info message
              CustomCard(
                backgroundColor: AppColors.cardBackground,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '✨ Select a lottery type and generate your personalized lucky numbers based on your birth chart and cosmic energy!',
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Lottery Type Selection
              Text(
                AppStrings.selectLotteryType,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.gold),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedLotteryType,
                  isExpanded: true,
                  dropdownColor: AppColors.darkPurple,
                  style: const TextStyle(color: AppColors.white),
                  items: LotteryUtils.getAvailableLotteryTypes()
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLotteryType = value;
                      _generatedNumbers = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: AppStrings.generateNumbers,
                  onPressed: _generateNumbers,
                  backgroundColor: AppColors.gold,
                  textColor: AppColors.darkPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 32),

              // Generated Numbers Display
              if (_generatedNumbers != null) ...[
                Text(
                  AppStrings.generatedNumbers,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CustomCard(
                  gradient: AppColors.goldGradient,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Number balls
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _generatedNumbers!
                            .map((number) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.darkPurple,
                                    border: Border.all(
                                      color: AppColors.gold,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      number.toString(),
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      // Fortune message
                      Text(
                        'Play these numbers with confidence! 🌟',
                        style: const TextStyle(
                          color: AppColors.darkPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.casino,
                          size: 48,
                          color: AppColors.gold.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Select a lottery type and tap Generate',
                          style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
