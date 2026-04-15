import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/models/user_model.dart';
import '../../data/local/local_storage.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_appbar.dart';
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
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _storage = LocalStorageService();
    await _storage.initialize();
    
    _user = await _storage.getUserProfile();
    _notificationsEnabled = _storage.getNotificationsEnabled();

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
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          strings.appName,
          style: const TextStyle(color: AppColors.gold),
        ),
        content: SingleChildScrollView(
          child: Text(
            strings.disclaimer,
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
            child: Text(
              strings.close,
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          strings.confirmLogout,
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          strings.logoutMessage,
          style: const TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
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
            child: Text(
              strings.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          strings.clearHistory,
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          strings.clearHistoryMessage,
          style: const TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _storage.clearLotteryHistory();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.clearedSuccessfully),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(
              strings.yes,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _storage.setNotificationsEnabled(value);
  }

  void _showLanguageSelector() {
    final strings = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        final localeController = Provider.of<LocaleController>(context, listen: false);
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            strings.selectLanguage,
            style: const TextStyle(color: AppColors.gold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                'English',
                'en',
                localeController.locale.languageCode == 'en',
                () => _changeLanguage('en', localeController),
              ),
              _buildLanguageOption(
                strings.languageSinhala,
                'si',
                localeController.locale.languageCode == 'si',
                () => _changeLanguage('si', localeController),
              ),
              _buildLanguageOption(
                strings.languageTamil,
                'ta',
                localeController.locale.languageCode == 'ta',
                () => _changeLanguage('ta', localeController),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                strings.close,
                style: const TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(String languageCode, LocaleController controller) {
    controller.setLocale(languageCode);
    Navigator.pop(context);
  }

  Widget _buildLanguageOption(
    String label,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.gold : AppColors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.gold)
          : null,
      onTap: onTap,
    );
  }

  void _showPrivacyPolicy() {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          strings.privacy,
          style: const TextStyle(color: AppColors.gold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'AstroLuck respects your privacy. We collect only essential information needed to generate your personalized lucky numbers:\n\n'
            '• Birth date and time\n'
            '• Birth location\n'
            '• Lottery game preferences\n\n'
            'All data is stored locally on your device and is never transmitted to external servers. We do not share your information with third parties.\n\n'
            'For more information, please contact us at support@astroluck.com',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              strings.close,
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          strings.terms,
          style: const TextStyle(color: AppColors.gold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Terms of Service\n\n'
            '1. Disclaimer: AstroLuck is for entertainment purposes only. Numbers are generated using numerology and astrology algorithms, which are not scientifically proven.\n\n'
            '2. No Guarantee: We make no guarantee of winning any lottery or game. Use numbers at your own discretion.\n\n'
            '3. Responsible Gaming: Always play responsibly. Never wager money you cannot afford to lose.\n\n'
            '4. Data Storage: All personal data is stored locally and can be deleted at any time.\n\n'
            '5. Age Requirement: Users must be 18+ to use this application.\n\n'
            '6. Modifications: We reserve the right to modify these terms at any time.',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              strings.close,
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          strings.deleteAccount,
          style: const TextStyle(color: AppColors.error),
        ),
        content: Text(
          strings.confirmDeleteAccount,
          style: const TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
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
            child: Text(
              strings.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppAppBar(
        title: strings.settings,
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
                      strings.profile,
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
                              label: strings.name,
                              value: _user!.name,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              label: strings.dateOfBirth,
                              value: _user!.dateOfBirth.toString().split(' ')[0],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              label: strings.zodiacSign,
                              value: _user!.zodiacSign,
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: strings.editProfile,
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
                      strings.dataManagement,
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
                            label: strings.clearHistory,
                            onTap: _clearHistory,
                            textColor: AppColors.warning,
                          ),
                          const Divider(
                            color: AppColors.darkGrey,
                            height: 1,
                          ),
                          _buildSettingTile(
                            icon: Icons.logout,
                            label: strings.logout,
                            onTap: _logout,
                            textColor: AppColors.error,
                          ),
                          const Divider(
                            color: AppColors.darkGrey,
                            height: 1,
                          ),
                          _buildSettingTile(
                            icon: Icons.delete_forever,
                            label: strings.deleteAccount,
                            onTap: _deleteAccount,
                            textColor: AppColors.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Preferences Section
                    Text(
                      strings.changePreferences,
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
                            icon: Icons.language,
                            label: strings.language,
                            onTap: _showLanguageSelector,
                          ),
                          const Divider(
                            color: AppColors.darkGrey,
                            height: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notifications,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    strings.notifications,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _notificationsEnabled,
                                  onChanged: _toggleNotifications,
                                  activeColor: AppColors.gold,
                                  inactiveThumbColor: AppColors.lightGrey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Information Section
                    Text(
                      strings.information,
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
                            icon: Icons.info,
                            label: strings.disclaimer,
                            onTap: _showDisclaimer,
                          ),
                          const Divider(
                            color: AppColors.darkGrey,
                            height: 1,
                          ),
                          _buildSettingTile(
                            icon: Icons.privacy_tip,
                            label: strings.privacy,
                            onTap: _showPrivacyPolicy,
                          ),
                          const Divider(
                            color: AppColors.darkGrey,
                            height: 1,
                          ),
                          _buildSettingTile(
                            icon: Icons.description,
                            label: strings.terms,
                            onTap: _showTermsOfService,
                          ),
                        ],
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
                            strings.appName,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.appVersion,
                            style: const TextStyle(
                              color: AppColors.lightGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.appTagline,
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
