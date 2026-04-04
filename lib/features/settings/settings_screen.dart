import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/user_model.dart';
import '../../data/local/local_storage.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import '../auth/profile_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late LocalStorageService _storage;
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _storage = LocalStorageService();
    await _storage.initialize();
    
    _user = await _storage.getUserProfile();

    setState(() {
      _isLoading = false;
    });
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupScreen(isEditing: true),
      ),
    ).then((_) {
      _initializeScreen();
    });
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          AppStrings.appName,
          style: TextStyle(color: AppColors.gold),
        ),
        content: SingleChildScrollView(
          child: Text(
            AppStrings.disclaimer,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.close,
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          AppStrings.confirmLogout,
          style: TextStyle(color: AppColors.white),
        ),
        content: const Text(
          AppStrings.logoutMessage,
          style: TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _storage.clearAllData();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/splash',
                  (route) => false,
                );
              }
            },
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          AppStrings.clearHistory,
          style: TextStyle(color: AppColors.white),
        ),
        content: const Text(
          AppStrings.clearHistoryMessage,
          style: TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _storage.clearLotteryHistory();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.clearedSuccessfully),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              AppStrings.yes,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: AppColors.darkPurple,
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    Text(
                      AppStrings.profile,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      backgroundColor: AppColors.cardBackground,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_user != null) ...[
                            _buildInfoRow(
                              label: AppStrings.name,
                              value: _user!.name,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              label: AppStrings.dateOfBirth,
                              value: _user!.dateOfBirth.toString().split(' ')[0],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              label: AppStrings.zodiacSign,
                              value: _user!.zodiacSign ?? 'Unknown',
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: AppStrings.editProfile,
                              onPressed: _editProfile,
                              backgroundColor: AppColors.gold,
                              textColor: AppColors.darkPurple,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Data Management Section
                    Text(
                      AppStrings.dataManagement,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      backgroundColor: AppColors.cardBackground,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildSettingTile(
                            icon: Icons.history,
                            label: AppStrings.clearHistory,
                            onTap: _clearHistory,
                            textColor: AppColors.warning,
                          ),
                          const Divider(
                            color: AppColors.darkGrey,
                            height: 1,
                          ),
                          _buildSettingTile(
                            icon: Icons.logout,
                            label: AppStrings.logout,
                            onTap: _logout,
                            textColor: AppColors.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Information Section
                    Text(
                      AppStrings.information,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      backgroundColor: AppColors.cardBackground,
                      padding: EdgeInsets.zero,
                      child: _buildSettingTile(
                        icon: Icons.info,
                        label: AppStrings.disclaimer,
                        onTap: _showDisclaimer,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // About Section
                    CustomCard(
                      backgroundColor: AppColors.cardBackground,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.appName,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.appVersion,
                            style: const TextStyle(
                              color: AppColors.lightGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.appTagline,
                            style: const TextStyle(
                              color: AppColors.mediumEnergy,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightGrey,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color textColor = AppColors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
