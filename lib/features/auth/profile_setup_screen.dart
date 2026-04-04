import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/numerology_utils.dart';
import '../../core/utils/date_utils.dart' as app_date_utils;
import '../../core/utils/lottery_utils.dart';
import '../../data/local/local_storage.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  
  const ProfileSetupScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  final _selectedLotteryTypes = <String>{};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              surface: AppColors.darkPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _noop() {}

  void _saveProfile() {
    _doSaveProfile();
  }

  Future<void> _doSaveProfile() async {
    // Validation
    if (_nameController.text.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select your date of birth');
      return;
    }
    if (_placeController.text.isEmpty) {
      _showError('Please enter your place of birth');
      return;
    }
    if (_selectedLotteryTypes.isEmpty) {
      _showError('Please select at least one lottery type');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calculate numerology numbers
      final lifePathNumber = NumerologyUtils.calculateLifePathNumber(_selectedDate!);
      final destinyNumber = NumerologyUtils.calculateDestinyNumber(_nameController.text);
      final zodiacSign = app_date_utils.DateUtils.getZodiacSign(_selectedDate!);

      // Create user profile
      final user = UserProfile(
        id: const Uuid().v4(),
        name: _nameController.text,
        dateOfBirth: _selectedDate!,
        timeOfBirth: _timeController.text.isNotEmpty ? _timeController.text : null,
        birthPlace: _placeController.text,
        gender: _selectedGender,
        zodiacSign: zodiacSign,
        lifePathNumber: lifePathNumber,
        destinyNumber: destinyNumber,
        favoriteLotteryTypes: _selectedLotteryTypes.toList(),
        createdAt: DateTime.now(),
      );

      // Save to local storage
      final storage = LocalStorageService();
      await storage.initialize();
      await storage.saveUserProfile(user);
      await storage.setOnboardingComplete(true);
      await storage.saveLastAppVisit(DateTime.now());

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error saving profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
        backgroundColor: AppColors.darkPurple,
        elevation: 0,
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
              // Subtitle
              Text(
                AppStrings.profileSubtitle,
                style: const TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              _buildTextField(
                label: AppStrings.profileName,
                controller: _nameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Date of Birth
              _buildDateField(
                label: AppStrings.profileDateOfBirth,
                value: _selectedDate,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Time of Birth
              _buildTextField(
                label: AppStrings.profileTimeOfBirth,
                controller: _timeController,
                icon: Icons.access_time,
                tooltip: 'HH:mm (Optional)',
              ),
              const SizedBox(height: 16),

              // Place of Birth
              _buildTextField(
                label: AppStrings.profilePlaceOfBirth,
                controller: _placeController,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),

              // Gender Selection
              _buildGenderSelection(),
              const SizedBox(height: 24),

              // Lottery Types Selection
              _buildLotteryTypeSelection(),
              const SizedBox(height: 32),

              // Complete Profile Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: AppStrings.profileComplete,
                  onPressed: _isLoading ? _noop : _saveProfile,
                  backgroundColor: AppColors.gold,
                  textColor: AppColors.darkPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 2),
            ),
            hintText: tooltip,
            hintStyle: const TextStyle(color: AppColors.darkGrey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.gold),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null
                      ? 'Select date'
                      : '${value.day}/${value.month}/${value.year}',
                  style: TextStyle(
                    color: value == null ? AppColors.darkGrey : AppColors.white,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.expand_more, color: AppColors.gold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.wc, color: AppColors.gold, size: 18),
            SizedBox(width: 8),
            Text(
              AppStrings.profileGender,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            AppStrings.profileGenderMale,
            AppStrings.profileGenderFemale,
            AppStrings.profileGenderOther,
          ].map((gender) {
            return ChoiceChip(
              label: Text(gender),
              selected: _selectedGender == gender,
              onSelected: (selected) {
                setState(() {
                  _selectedGender = selected ? gender : null;
                });
              },
              backgroundColor: AppColors.cardBackground,
              selectedColor: AppColors.gold,
              labelStyle: TextStyle(
                color: _selectedGender == gender
                    ? AppColors.darkPurple
                    : AppColors.white,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLotteryTypeSelection() {
    final lotteryTypes = LotteryUtils.getAvailableLotteryTypes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.stars, color: AppColors.gold, size: 18),
            SizedBox(width: 8),
            Text(
              AppStrings.profileLotteryTypes,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: lotteryTypes.map((type) {
            return FilterChip(
              label: Text(type),
              selected: _selectedLotteryTypes.contains(type),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLotteryTypes.add(type);
                  } else {
                    _selectedLotteryTypes.remove(type);
                  }
                });
              },
              backgroundColor: AppColors.cardBackground,
              selectedColor: AppColors.gold,
              labelStyle: TextStyle(
                color: _selectedLotteryTypes.contains(type)
                    ? AppColors.darkPurple
                    : AppColors.white,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
