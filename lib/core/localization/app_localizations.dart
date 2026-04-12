import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  static bool isSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (localizations == null) {
      return const AppLocalizations(Locale('en'));
    }
    return localizations;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'AstroLuck',
      'appTitle': 'AstroLuck - Guided by Stars',
      'appTagline': 'Your Astrology-Based Lucky Number Guide',
      'appVersion': '1.0.0',
      'splashLoading': 'Aligning celestial energies...',
      'splashGreeting': 'Welcome to AstroLuck',
      'onboardingSkip': 'Skip',
      'onboardingNext': 'Next',
      'onboardingGetStarted': 'Get Started',
      'onboardingTitle1': 'Mystical Numbers',
      'onboardingDesc1': 'Discover your lucky numbers based on ancient astrology and numerology',
      'onboardingTitle2': 'Cosmic Alignment',
      'onboardingDesc2': 'Every number is guided by planetary energy and your birth chart',
      'onboardingTitle3': 'Daily Guidance',
      'onboardingDesc3': 'Get personalized lucky numbers that change daily with cosmic energy',
      'profileTitle': 'Your Birth Chart',
      'profileSubtitle': 'Share your cosmic details',
      'profileName': 'Your Name',
      'profileDateOfBirth': 'Date of Birth',
      'profileTimeOfBirth': 'Time of Birth (Optional)',
      'profilePlaceOfBirth': 'Place of Birth',
      'profileGender': 'Gender (Optional)',
      'profileGenderMale': 'Male',
      'profileGenderFemale': 'Female',
      'profileGenderOther': 'Other',
      'profileLotteryTypes': 'Favorite Lottery Types',
      'profileComplete': 'Complete Profile',
      'selectLotteryTypes': 'Select your favorite lottery types',
      'homeWelcome': 'Welcome, Cosmic Seeker!',
      'todayLuckyNumbers': "Today's Lucky Numbers",
      'yourLuckyNumbers': 'Your Lucky Numbers',
      'yourLuckyCode': 'Your Lucky Code',
      'luckyTime': 'Lucky Time Window',
      'energyLevel': 'Cosmic Energy Level',
      'moonPhase': 'Moon Phase',
      'planetaryDay': 'Planetary Day',
      'fortuneMessage': "Today's Fortune",
      'refreshData': 'Refresh',
      'shareNumbers': 'Share',
      'saveNumbers': 'Save',
      'viewGenerator': 'Generate Numbers',
      'viewHistory': 'View History',
      'viewSettings': 'Settings',
      'primaryNumbers': 'Primary Lucky Numbers',
      'secondaryNumbers': 'Secondary Numbers',
      'luckyDigits': 'Lucky Digits',
      'luckyColor': 'Lucky Color',
      'luckyHour': 'Lucky Hour',
      'generatorTitle': 'Lottery Number Generator',
      'selectLotteryType': 'Select Lottery Type',
      'generateNumbers': 'Generate Numbers',
      'generatedNumbers': 'Generated Numbers',
      'bonusNumber': 'Bonus Number',
      'playWith': 'Play with these numbers',
      'riskNumber': 'Risky Number (Optional)',
      'historyTitle': 'Lottery History',
      'addEntry': 'Add Entry',
      'lotteryType': 'Lottery Type',
      'numbersPlayed': 'Numbers Played',
      'drawDate': 'Draw Date',
      'didWin': 'Did Win?',
      'prizeAmount': 'Prize Amount',
      'notes': 'Notes',
      'patternAnalysis': 'Pattern Analysis',
      'frequentDigits': 'Frequent Digits',
      'rarelyUsed': 'Rarely Used',
      'avoidThisWeek': 'Avoid This Week',
      'recommendThisWeek': 'Recommend This Week',
      'noHistory': 'No lottery history yet. Start adding entries!',
      'settingsTitle': 'Settings',
      'accountSection': 'Account',
      'editProfile': 'Edit Profile',
      'changePreferences': 'Change Preferences',
      'appSection': 'App',
      'darkMode': 'Dark Mode',
      'notifications': 'Enable Notifications',
      'aboutSection': 'About',
      'disclaimer': 'Disclaimer',
      'disclaimerText': 'AstroLuck is for entertainment purposes only. Lucky numbers are based on numerology and astrology, which are not scientifically proven. We make no guarantees of winning. Gambling responsibly is encouraged. Never bet money you cannot afford to lose.',
      'privacy': 'Privacy Policy',
      'terms': 'Terms of Service',
      'logout': 'Log Out',
      'deleteAccount': 'Delete Account',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'save': 'Save',
      'close': 'Close',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'sharedSuccessfully': 'Numbers shared successfully! 🎉',
      'savedSuccessfully': 'Numbers saved successfully! ✨',
      'deletedSuccessfully': 'Entry deleted successfully!',
      'errorLoading': 'Error loading data',
      'errorSaving': 'Error saving data. Please try again.',
      'retry': 'Retry',
      'confirmDelete': 'Are you sure you want to delete this entry?',
      'confirmLogout': 'Are you sure you want to log out?',
      'confirmDeleteAccount': 'This action cannot be undone. All your data will be deleted.',
      'fieldRequired': 'This field is required',
      'invalidDate': 'Please enter a valid date',
      'selectAtLeastOne': 'Please select at least one option',
      'highEnergy': '🔥 High Energy',
      'mediumEnergy': '⚡ Medium Energy',
      'lowEnergy': '🌙 Low Energy',
      'home': 'Home',
      'lottery': 'Lottery',
      'history': 'History',
      'settings': 'Settings',
      'zodiacSign': 'Zodiac Sign',
      'lifePathNumber': 'Life Path Number',
      'destinyNumber': 'Destiny Number',
      'luckyColorLabel': 'Lucky Color',
      'profile': 'Profile',
      'name': 'Name',
      'dateOfBirth': 'Date of Birth',
      'dataManagement': 'Data Management',
      'clearHistory': 'Clear History',
      'clearHistoryMessage': 'Clear all lottery history entries? This action cannot be undone.',
      'clearedSuccessfully': 'History cleared successfully!',
      'yes': 'Yes',
      'logoutMessage': 'You will be returned to the onboarding screen.',
      'information': 'Information',
      'unknown': 'Unknown',
      'language': 'Language',
      'selectLanguage': 'Select language',
      'languageEnglish': 'English',
      'languageSinhala': 'සිංහල',
      'languageTamil': 'தமிழ்',
      'greetingLateNight': '🌙 Late Night Insights, Stargazer!',
      'greetingMorning': '🌅 Good Morning, Starseeker!',
      'greetingAfternoon': '☀️ Good Afternoon, Celestial Friend!',
      'greetingEvening': '🌙 Good Evening, Mystic Wanderer!',
      'luckyNumbersRefreshed': 'Lucky numbers refreshed! ✨',
      'numbersCopied': 'Numbers copied to clipboard! 📋',
      'numbersSaved': 'Numbers saved! 💾',
      'dailyCosmicInsight': '🔮 Daily Cosmic Insight',
      'actionGenerate': 'Generate',
      'actionHistory': 'History',
      'lotteryInfoMessage': '✨ Select a lottery type and generate your personalized lucky numbers based on your birth chart and cosmic energy!',
      'playWithConfidence': 'Play these numbers with confidence! 🌟',
      'lotteryEmptyState': 'Select a lottery type and tap Generate',
      'selectDate': 'Select date',
      'timeHint': 'HH:mm (Optional)',
      'errorEnterName': 'Please enter your name',
      'errorSelectDob': 'Please select your date of birth',
      'errorEnterPlace': 'Please enter your place of birth',
      'errorSelectLotteryType': 'Please select at least one lottery type',
      'errorSavingProfile': 'Error saving profile. Please try again.',
      'historyWon': '🎉 Won!',
      'historyPlayed': 'Played',
      'historyNumbersLabel': 'Numbers: ',
      'historyDrawLabel': 'Draw: ',
      'historyPrizeLabel': 'Prize: ',
      'historyRequiredFields': 'Please fill all required fields'
    },
    'si': {
      'appName': 'AstroLuck',
      'appTitle': 'AstroLuck - තාරකා මගින් මාර්ගෝපදේශිත',
      'appTagline': 'ඔබගේ ජ්‍යෝතිෂ්‍යය පදනම් වූ වාසනාවන්ත අංක මාර්ගදර්ශකය',
      'appVersion': '1.0.0',
      'splashLoading': 'ග්‍රහ බල හරස් කරමින්...',
      'splashGreeting': 'AstroLuck වෙත සාදරයෙන් පිළිගනිමු',
      'onboardingSkip': 'කඩිමුඩි',
      'onboardingNext': 'ඊළඟ',
      'onboardingGetStarted': 'ආරම්භ කරන්න',
      'onboardingTitle1': 'අද්භූත අංක',
      'onboardingDesc1': 'පැරණි ජ්‍යෝතිෂ්‍යය හා සංඛ්‍යා විද්‍යාව මත ඔබගේ වාසනාවන්ත අංක සොයන්න',
      'onboardingTitle2': 'කාස्मिक සමාන්විතය',
      'onboardingDesc2': 'සියලුම අංක ඔබගේ උපන් කොන්ඩය හා ග්‍රහ ශක්තිය මගින් මඟ පෙන්වයි',
      'onboardingTitle3': 'දෛනික මඟපෙන්වීම',
      'onboardingDesc3': 'කාස्मिक ශක්තිය අනුව දිනපතා වෙනස් වන පුද්ගලික වාසනාවන්ත අංක ලබා ගන්න',
      'profileTitle': 'ඔබගේ උපන් චාට්',
      'profileSubtitle': 'ඔබගේ කාස्मिक විස්තර හුවමාරු කරන්න',
      'profileName': 'ඔබගේ නම',
      'profileDateOfBirth': 'උපන් දිනය',
      'profileTimeOfBirth': 'උපන් වේලාව (විකල්ප)',
      'profilePlaceOfBirth': 'උපන් ස්ථානය',
      'profileGender': 'ලිංගය (විකල්ප)',
      'profileGenderMale': 'පුරුෂ',
      'profileGenderFemale': 'ස්ත්‍රී',
      'profileGenderOther': 'වෙනත්',
      'profileLotteryTypes': 'කැමති ලොතරැයි වර්ග',
      'profileComplete': 'ප්‍රොෆයිලය සම්පූර්ණ කරන්න',
      'selectLotteryTypes': 'ඔබගේ කැමති ලොතරැයි වර්ග තෝරන්න',
      'homeWelcome': 'සාදරයෙන් පිළිගනිමු, කාස्मिक සෙවන්නා!',
      'todayLuckyNumbers': 'අදගේ වාසනාවන්ත අංක',
      'yourLuckyNumbers': 'ඔබගේ වාසනාවන්ත අංක',
      'yourLuckyCode': 'ඔබගේ වාසනාවන්ත කේතය',
      'luckyTime': 'වාසනාවන්ත වේලාව',
      'energyLevel': 'කාස्मिक ශක්ති මට්ටම',
      'moonPhase': 'චන්ද්‍ර කලාව',
      'planetaryDay': 'ග්‍රහ දිනය',
      'fortuneMessage': 'අදගේ වාසනාව',
      'refreshData': 'නැවත යාවත්කාලීන කරන්න',
      'shareNumbers': 'බෙදාගන්න',
      'saveNumbers': 'සුරකින්න',
      'viewGenerator': 'අංක ජනනය කරන්න',
      'viewHistory': 'ඉතිහාසය බලන්න',
      'viewSettings': 'සැකසුම්',
      'primaryNumbers': 'ප්‍රාථමික වාසනාවන්ත අංක',
      'secondaryNumbers': 'ද්විතීය අංක',
      'luckyDigits': 'වාසනාවන්ත අංක',
      'luckyColor': 'වාසනාවන්ත වර්ණය',
      'luckyHour': 'වාසනාවන්ත පැය',
      'generatorTitle': 'ලොතරැයි අංක ජනකය',
      'selectLotteryType': 'ලොතරැයි වර්ගය තෝරන්න',
      'generateNumbers': 'අංක ජනනය කරන්න',
      'generatedNumbers': 'ජනනය කළ අංක',
      'bonusNumber': 'බෝනස් අංක',
      'playWith': 'මේ අංකවලින් ක්‍රීඩා කරන්න',
      'riskNumber': 'අතිරේක අවදානම් අංක (විකල්ප)',
      'historyTitle': 'ලොතරැයි ඉතිහාසය',
      'addEntry': 'ඇතුල් කිරීම එකතු කරන්න',
      'lotteryType': 'ලොතරැයි වර්ගය',
      'numbersPlayed': 'ක්‍රීඩා කළ අංක',
      'drawDate': 'ඇදීමේ දිනය',
      'didWin': 'දිනුම්ද?',
      'prizeAmount': 'ප්‍රසාද මුදල',
      'notes': 'සටහන්',
      'patternAnalysis': 'මාදිලී විශ්ලේෂණය',
      'frequentDigits': 'නිතර එන අංක',
      'rarelyUsed': 'හිතුවක්කාරයෙන් භාවිතා කර නොමැත',
      'avoidThisWeek': 'මෙම සතියේ වළක්වන්න',
      'recommendThisWeek': 'මෙම සතියේ නිර්දේශ',
      'noHistory': 'ලොතරැයි ඉතිහාසය නැත. ඇතුල් කිරීම් එකතු කරන්න!',
      'settingsTitle': 'සැකසුම්',
      'accountSection': 'ගිණුම',
      'editProfile': 'ප්‍රොෆයිල් සංස්කරණය',
      'changePreferences': 'ආකෘති වෙනස් කරන්න',
      'appSection': 'යෙදුම',
      'darkMode': 'අඳුරු තේමාව',
      'notifications': 'දැනුම්දීමට ඉඩදෙන්න',
      'aboutSection': 'විස්තර',
      'disclaimer': 'වගකීම ඉවත',
      'disclaimerText': 'AstroLuck විනෝදාස්වාදය සඳහා පමණි. වාසනාවන්ත අංක ජ්‍යෝතිෂ්‍යය හා සංඛ්‍යා විද්‍යාව මත පදනම් වේ, එය විද්‍යාත්මකව සනාථ කර නැත. අපි ජයග්‍රහණ සඳහා අ ضمان ප්‍රකාශ නොකරමු. වගකීමෙන් සූදු වටිනාකම් භාවිතා කරන්න. ඔබට අහිමි කළ නොහැකි මුදල් කිසිවිටකත් පත්තු නොකරන්න.',
      'privacy': 'රහස්‍යතා ප්‍රතිපත්තිය',
      'terms': 'සේවා නියම',
      'logout': 'ඉවත් වන්න',
      'deleteAccount': 'ගිණුම මකන්න',
      'confirm': 'තහවුරු',
      'cancel': 'අවලංගු',
      'delete': 'මකන්න',
      'edit': 'සංස්කරණය',
      'save': 'සුරකින්න',
      'close': 'වසන්න',
      'loading': 'ලෝඩ් වේ...',
      'error': 'දෝෂය',
      'success': 'සාර්ථකයි',
      'warning': 'අවවාදය',
      'sharedSuccessfully': 'අංක සාර්ථකව බෙදාගත්තා! 🎉',
      'savedSuccessfully': 'අංක සාර්ථකව සුරකින ලදී! ✨',
      'deletedSuccessfully': 'ඇතුළත් කිරීම මකා දැමුවා!',
      'errorLoading': 'දත්ත පූරණය කිරීමේ දෝෂය',
      'errorSaving': 'සුරැකීමේ දෝෂය. නැවත උත්සාහ කරන්න.',
      'retry': 'නැවත උත්සාහ කරන්න',
      'confirmDelete': 'මෙම ඇතුළත් කිරීම මකන්නද?',
      'confirmLogout': 'ඔබට ඉවත් වීමට අවශ්‍යද?',
      'confirmDeleteAccount': 'මෙම ක්‍රියාව අහෝසි කළ නොහැක. ඔබගේ දත්ත සියල්ල මකා දමනු ඇත.',
      'fieldRequired': 'මෙම ක්ෂේත්‍රය අවශ්‍යයි',
      'invalidDate': 'වලංගු දිනයක් ඇතුළත් කරන්න',
      'selectAtLeastOne': 'අවම වශයෙන් එක් එකක් තෝරන්න',
      'highEnergy': '🔥 ඉහළ ශක්තිය',
      'mediumEnergy': '⚡ මධ්‍යම ශක්තිය',
      'lowEnergy': '🌙 අඩු ශක්තිය',
      'home': 'මුල්',
      'lottery': 'ලොතරැයි',
      'history': 'ඉතිහාසය',
      'settings': 'සැකසුම්',
      'zodiacSign': 'රැස',
      'lifePathNumber': 'ජීවමාර්ග අංක',
      'destinyNumber': 'භාග්‍ය අංක',
      'luckyColorLabel': 'වාසනාවන්ත වර්ණය',
      'profile': 'ප්‍රොෆයිල්',
      'name': 'නම',
      'dateOfBirth': 'උපන් දිනය',
      'dataManagement': 'දත්ත කළමනාකරණය',
      'clearHistory': 'ඉතිහාසය හිස් කරන්න',
      'clearHistoryMessage': 'සියලුම ලොතරැයි ඉතිහාස ඇතුළත් කිරීම් මකා දැමීමටද? මෙය අහෝසි කළ නොහැක.',
      'clearedSuccessfully': 'ඉතිහාසය සාර්ථකව හිස් කළා!',
      'yes': 'ඔව්',
      'logoutMessage': 'ඔබ ඔන්බෝඩිං තිරයට ආපසු යනු ඇත.',
      'information': 'තොරතුරු',
      'unknown': 'නොදන්නා',
      'language': 'භාෂාව',
      'selectLanguage': 'භාෂාව තෝරන්න',
      'languageEnglish': 'English',
      'languageSinhala': 'සිංහල',
      'languageTamil': 'தமிழ்',
      'greetingLateNight': '🌙 අළුයම අවසන් මොහොතේ අවබෝධය, තාරකා නිරීක්ෂකය!',
      'greetingMorning': '🌅 සුභ උදෑසනක්, තාරකා සෙවන්නා!',
      'greetingAfternoon': '☀️ සුභ මධ්‍යහනක්, කාස्मिक මිතුරා!',
      'greetingEvening': '🌙 සුභ සවසක්, අද්භූත සංචාරකයා!',
      'luckyNumbersRefreshed': 'වාසනාවන්ත අංක යාවත්කාලීන කළා! ✨',
      'numbersCopied': 'අංක ක්ලිප්බෝර්ඩ්ට පිටපත් කළා! 📋',
      'numbersSaved': 'අංක සුරකින ලදී! 💾',
      'dailyCosmicInsight': '🔮 දෛනික කාසમિક අවබෝධය',
      'actionGenerate': 'ජනනය කරන්න',
      'actionHistory': 'ඉතිහාසය',
      'lotteryInfoMessage': '✨ ඔබගේ උපන් චාට් හා කාස್ಮಿಕ ශක්තිය මත පුද්ගලික වාසනාවන්ත අංක ජනනය කිරීමට ලොතරැයි වර්ගයක් තෝරන්න!',
      'playWithConfidence': 'මෙම අංක විශ්වාසයෙන් ක්‍රීඩා කරන්න! 🌟',
      'lotteryEmptyState': 'ලොතරැයි වර්ගයක් තෝරලා ජනනය කරන්න',
      'selectDate': 'දිනය තෝරන්න',
      'timeHint': 'HH:mm (විකල්ප)',
      'errorEnterName': 'කරුණාකර ඔබගේ නම ඇතුළත් කරන්න',
      'errorSelectDob': 'කරුණාකර ඔබගේ උපන් දිනය තෝරන්න',
      'errorEnterPlace': 'කරුණාකර ඔබගේ උපන් ස්ථානය ඇතුළත් කරන්න',
      'errorSelectLotteryType': 'කරුණාකර අවම වශයෙන් එක් ලොතරැයි වර්ගයක් තෝරන්න',
      'errorSavingProfile': 'ප්‍රොෆයිලය සුරැකීමේ දෝෂය. නැවත උත්සාහ කරන්න.',
      'historyWon': '🎉 ජය!',
      'historyPlayed': 'ක්‍රීඩා කළා',
      'historyNumbersLabel': 'අංක: ',
      'historyDrawLabel': 'ඇදීම: ',
      'historyPrizeLabel': 'ජයමුදල: ',
      'historyRequiredFields': 'කරුණාකර අවශ්‍ය ක්ෂේත්‍ර සියල්ල පුරවන්න'
    },
    'ta': {
      'appName': 'AstroLuck',
      'appTitle': 'AstroLuck - நட்சத்திர வழிகாட்டுதல்',
      'appTagline': 'ஜோதிட அடிப்படையிலான அதிர்ஷ்ட எண்ண வழிகாட்டி',
      'appVersion': '1.0.0',
      'splashLoading': 'வானியல் ஆற்றலை ஒழுங்குபடுத்துகிறது...',
      'splashGreeting': 'AstroLuck இற்கு வரவேற்கிறோம்',
      'onboardingSkip': 'தவிர்',
      'onboardingNext': 'அடுத்து',
      'onboardingGetStarted': 'தொடங்குங்கள்',
      'onboardingTitle1': 'மாய எண்கள்',
      'onboardingDesc1': 'பண்டைய ஜோதிடம் மற்றும் எண் கணிதத்தின் அடிப்படையில் உங்கள் அதிர்ஷ்ட எண்களை கண்டறியுங்கள்',
      'onboardingTitle2': 'கோசமிக் ஒத்திசைவு',
      'onboardingDesc2': 'ஒவ்வொரு எண்ணும் கிரக ஆற்றலும் உங்கள் பிறப்பு பட்டையும் வழிநடத்தும்',
      'onboardingTitle3': 'தினசரி வழிகாட்டுதல்',
      'onboardingDesc3': 'கோசமிக் ஆற்றலுடன் தினமும் மாறும் தனிப்பயன் அதிர்ஷ்ட எண்களை பெறுங்கள்',
      'profileTitle': 'உங்கள் பிறப்பு சார்ட்',
      'profileSubtitle': 'உங்கள் கோசமிக் விவரங்களை பகிரவும்',
      'profileName': 'உங்கள் பெயர்',
      'profileDateOfBirth': 'பிறந்த தேதி',
      'profileTimeOfBirth': 'பிறந்த நேரம் (விருப்பம்)',
      'profilePlaceOfBirth': 'பிறந்த இடம்',
      'profileGender': 'பாலினம் (விருப்பம்)',
      'profileGenderMale': 'ஆண்',
      'profileGenderFemale': 'பெண்',
      'profileGenderOther': 'மற்றது',
      'profileLotteryTypes': 'விருப்பமான லாட்டரி வகைகள்',
      'profileComplete': 'சுயவிவரம் முடிக்கவும்',
      'selectLotteryTypes': 'உங்கள் விருப்பமான லாட்டரி வகைகளை தேர்ந்தெடுக்கவும்',
      'homeWelcome': 'வரவேற்கிறோம், கோசமிக் தேடுபவர்!',
      'todayLuckyNumbers': 'இன்றைய அதிர்ஷ்ட எண்கள்',
      'yourLuckyNumbers': 'உங்கள் அதிர்ஷ்ட எண்கள்',
      'yourLuckyCode': 'உங்கள் அதிர்ஷ்ட குறியீடு',
      'luckyTime': 'அதிர்ஷ்ட நேரம்',
      'energyLevel': 'கோசமிக் ஆற்றல் நிலை',
      'moonPhase': 'நிலா நிலை',
      'planetaryDay': 'கிரக நாள்',
      'fortuneMessage': 'இன்றைய அதிர்ஷ்ட செய்தி',
      'refreshData': 'புதுப்பிப்பு',
      'shareNumbers': 'பகிர்',
      'saveNumbers': 'சேமி',
      'viewGenerator': 'எண்களை உருவாக்கு',
      'viewHistory': 'வரலாறு பார்க்க',
      'viewSettings': 'அமைப்புகள்',
      'primaryNumbers': 'முதன்மை அதிர்ஷ்ட எண்கள்',
      'secondaryNumbers': 'இரண்டாம் நிலை எண்கள்',
      'luckyDigits': 'அதிர்ஷ்ட இலக்கங்கள்',
      'luckyColor': 'அதிர்ஷ்ட நிறம்',
      'luckyHour': 'அதிர்ஷ்ட மணி',
      'generatorTitle': 'லாட்டரி எண் உருவாக்கி',
      'selectLotteryType': 'லாட்டரி வகையை தேர்ந்தெடுக்கவும்',
      'generateNumbers': 'எண்களை உருவாக்கு',
      'generatedNumbers': 'உருவாக்கப்பட்ட எண்கள்',
      'bonusNumber': 'போனஸ் எண்',
      'playWith': 'இந்த எண்களுடன் விளையாடுங்கள்',
      'riskNumber': 'ஆபத்து எண் (விருப்பம்)',
      'historyTitle': 'லாட்டரி வரலாறு',
      'addEntry': 'பதிவு சேர்க்க',
      'lotteryType': 'லாட்டரி வகை',
      'numbersPlayed': 'விளையாடிய எண்கள்',
      'drawDate': 'பரிசு தேதி',
      'didWin': 'வெற்றி பெற்றீர்களா?',
      'prizeAmount': 'பரிசு தொகை',
      'notes': 'குறிப்புகள்',
      'patternAnalysis': 'மாதிரி பகுப்பாய்வு',
      'frequentDigits': 'அடிக்கடி வரும் எண்கள்',
      'rarelyUsed': 'அரிதாக பயன்படும்',
      'avoidThisWeek': 'இந்த வாரம் தவிர்க்க',
      'recommendThisWeek': 'இந்த வாரம் பரிந்துரை',
      'noHistory': 'லாட்டரி வரலாறு இல்லை. பதிவுகளை சேர்க்க தொடங்குங்கள்!',
      'settingsTitle': 'அமைப்புகள்',
      'accountSection': 'கணக்கு',
      'editProfile': 'சுயவிவரம் திருத்து',
      'changePreferences': 'விருப்பங்களை மாற்று',
      'appSection': 'பயன்பாடு',
      'darkMode': 'இருண்ட பயன்முறை',
      'notifications': 'அறிவிப்புகளை இயக்கு',
      'aboutSection': 'பற்றி',
      'disclaimer': 'பொறுப்புத்துறப்பு',
      'disclaimerText': 'AstroLuck என்பது பொழுதுபோக்கிற்காக மட்டுமே. அதிர்ஷ்ட எண்கள் எண் கணிதம் மற்றும் ஜோதிடத்தின் அடிப்படையில் உள்ளவை; இது அறிவியல்பூர்வமாக நிரூபிக்கப்படவில்லை. வெற்றிக்கான எந்த உத்தரவாதமும் இல்லை. பொறுப்புடன் சூதாட வேண்டும். நீங்கள் இழக்க முடியாத பணத்தை வைத்து சூதாட வேண்டாம்.',
      'privacy': 'தனியுரிமைக் கொள்கை',
      'terms': 'சேவை விதிமுறைகள்',
      'logout': 'வெளியேறு',
      'deleteAccount': 'கணக்கை நீக்கு',
      'confirm': 'உறுதிப்படுத்து',
      'cancel': 'ரத்து',
      'delete': 'நீக்கு',
      'edit': 'திருத்து',
      'save': 'சேமி',
      'close': 'மூடு',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை',
      'success': 'வெற்றி',
      'warning': 'எச்சரிக்கை',
      'sharedSuccessfully': 'எண்கள் வெற்றிகரமாக பகிரப்பட்டது! 🎉',
      'savedSuccessfully': 'எண்கள் வெற்றிகரமாக சேமிக்கப்பட்டது! ✨',
      'deletedSuccessfully': 'பதிவு நீக்கப்பட்டது!',
      'errorLoading': 'தகவலை ஏற்றுவதில் பிழை',
      'errorSaving': 'சேமிப்பதில் பிழை. மீண்டும் முயற்சிக்கவும்.',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'confirmDelete': 'இந்த பதிவை நீக்க வேண்டுமா?',
      'confirmLogout': 'வெளியேற வேண்டுமா?',
      'confirmDeleteAccount': 'இந்த செயலை மீட்டெடுக்க முடியாது. உங்கள் தரவு அனைத்தும் நீக்கப்படும்.',
      'fieldRequired': 'இந்த புலம் அவசியம்',
      'invalidDate': 'சரியான தேதியை உள்ளிடவும்',
      'selectAtLeastOne': 'குறைந்தது ஒன்றை தேர்ந்தெடுக்கவும்',
      'highEnergy': '🔥 உயர் ஆற்றல்',
      'mediumEnergy': '⚡ நடுத்தர ஆற்றல்',
      'lowEnergy': '🌙 குறைந்த ஆற்றல்',
      'home': 'முகப்பு',
      'lottery': 'லாட்டரி',
      'history': 'வரலாறு',
      'settings': 'அமைப்புகள்',
      'zodiacSign': 'ராசி',
      'lifePathNumber': 'வாழ்க்கை பாதை எண்',
      'destinyNumber': 'விதி எண்',
      'luckyColorLabel': 'அதிர்ஷ்ட நிறம்',
      'profile': 'சுயவிவரம்',
      'name': 'பெயர்',
      'dateOfBirth': 'பிறந்த தேதி',
      'dataManagement': 'தரவு மேலாண்மை',
      'clearHistory': 'வரலாறு நீக்கு',
      'clearHistoryMessage': 'அனைத்து லாட்டரி வரலாறு பதிவுகளையும் நீக்க வேண்டுமா? இதை மீட்டெடுக்க முடியாது.',
      'clearedSuccessfully': 'வரலாறு வெற்றிகரமாக நீக்கப்பட்டது!',
      'yes': 'ஆம்',
      'logoutMessage': 'நீங்கள் ஆன்சோர்டிங் திரைக்கு திரும்புவீர்கள்.',
      'information': 'தகவல்',
      'unknown': 'தெரியாதது',
      'language': 'மொழி',
      'selectLanguage': 'மொழியை தேர்ந்தெடுக்கவும்',
      'languageEnglish': 'English',
      'languageSinhala': 'සිංහල',
      'languageTamil': 'தமிழ்',
      'greetingLateNight': '🌙 இரவு நேர இறுதி அறிவுரை, நட்சத்திர பார்வையாளர்!',
      'greetingMorning': '🌅 காலை வணக்கம், நட்சத்திர தேடுபவர்!',
      'greetingAfternoon': '☀️ மதிய வணக்கம், கோசமிக் நண்பரே!',
      'greetingEvening': '🌙 மாலை வணக்கம், மாய பயணியுங்கள்!',
      'luckyNumbersRefreshed': 'அதிர்ஷ்ட எண்கள் புதுப்பிக்கப்பட்டது! ✨',
      'numbersCopied': 'எண்கள் கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது! 📋',
      'numbersSaved': 'எண்கள் சேமிக்கப்பட்டது! 💾',
      'dailyCosmicInsight': '🔮 தினசரி கோசமிக் உள்ளுணர்வு',
      'actionGenerate': 'உருவாக்கு',
      'actionHistory': 'வரலாறு',
      'lotteryInfoMessage': '✨ உங்கள் பிறப்பு சார்ட் மற்றும் கோசமிக் ஆற்றலின் அடிப்படையில் தனிப்பயன் அதிர்ஷ்ட எண்களை உருவாக்க ஒரு லாட்டரி வகையைத் தேர்ந்தெடுக்கவும்!',
      'playWithConfidence': 'இந்த எண்களுடன் நம்பிக்கையுடன் விளையாடுங்கள்! 🌟',
      'lotteryEmptyState': 'லாட்டரி வகையைத் தேர்ந்தெடுத்து உருவாக்கு என்பதை தட்டவும்',
      'selectDate': 'தேதியை தேர்ந்தெடுக்கவும்',
      'timeHint': 'HH:mm (விருப்பம்)',
      'errorEnterName': 'உங்கள் பெயரை உள்ளிடவும்',
      'errorSelectDob': 'உங்கள் பிறந்த தேதியை தேர்ந்தெடுக்கவும்',
      'errorEnterPlace': 'உங்கள் பிறந்த இடத்தை உள்ளிடவும்',
      'errorSelectLotteryType': 'குறைந்தது ஒரு லாட்டரி வகையை தேர்ந்தெடுக்கவும்',
      'errorSavingProfile': 'சுயவிவரத்தை சேமிப்பதில் பிழை. மீண்டும் முயற்சிக்கவும்.',
      'historyWon': '🎉 வெற்றி!',
      'historyPlayed': 'விளையாடியது',
      'historyNumbersLabel': 'எண்கள்: ',
      'historyDrawLabel': 'வெற்றி தேதி: ',
      'historyPrizeLabel': 'பரிசு: ',
      'historyRequiredFields': 'தேவையான அனைத்து புலங்களையும் நிரப்பவும்'
    }
  };

  String _getString(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  String get appName => _getString('appName');
  String get appTitle => _getString('appTitle');
  String get appTagline => _getString('appTagline');
  String get appVersion => _getString('appVersion');
  String get splashLoading => _getString('splashLoading');
  String get splashGreeting => _getString('splashGreeting');
  String get onboardingSkip => _getString('onboardingSkip');
  String get onboardingNext => _getString('onboardingNext');
  String get onboardingGetStarted => _getString('onboardingGetStarted');
  String get onboardingTitle1 => _getString('onboardingTitle1');
  String get onboardingDesc1 => _getString('onboardingDesc1');
  String get onboardingTitle2 => _getString('onboardingTitle2');
  String get onboardingDesc2 => _getString('onboardingDesc2');
  String get onboardingTitle3 => _getString('onboardingTitle3');
  String get onboardingDesc3 => _getString('onboardingDesc3');
  String get profileTitle => _getString('profileTitle');
  String get profileSubtitle => _getString('profileSubtitle');
  String get profileName => _getString('profileName');
  String get profileDateOfBirth => _getString('profileDateOfBirth');
  String get profileTimeOfBirth => _getString('profileTimeOfBirth');
  String get profilePlaceOfBirth => _getString('profilePlaceOfBirth');
  String get profileGender => _getString('profileGender');
  String get profileGenderMale => _getString('profileGenderMale');
  String get profileGenderFemale => _getString('profileGenderFemale');
  String get profileGenderOther => _getString('profileGenderOther');
  String get profileLotteryTypes => _getString('profileLotteryTypes');
  String get profileComplete => _getString('profileComplete');
  String get selectLotteryTypes => _getString('selectLotteryTypes');
  String get homeWelcome => _getString('homeWelcome');
  String get todayLuckyNumbers => _getString('todayLuckyNumbers');
  String get yourLuckyNumbers => _getString('yourLuckyNumbers');
  String get yourLuckyCode => _getString('yourLuckyCode');
  String get luckyTime => _getString('luckyTime');
  String get energyLevel => _getString('energyLevel');
  String get moonPhase => _getString('moonPhase');
  String get planetaryDay => _getString('planetaryDay');
  String get fortuneMessage => _getString('fortuneMessage');
  String get refreshData => _getString('refreshData');
  String get shareNumbers => _getString('shareNumbers');
  String get saveNumbers => _getString('saveNumbers');
  String get viewGenerator => _getString('viewGenerator');
  String get viewHistory => _getString('viewHistory');
  String get viewSettings => _getString('viewSettings');
  String get primaryNumbers => _getString('primaryNumbers');
  String get secondaryNumbers => _getString('secondaryNumbers');
  String get luckyDigits => _getString('luckyDigits');
  String get luckyColor => _getString('luckyColor');
  String get luckyHour => _getString('luckyHour');
  String get generatorTitle => _getString('generatorTitle');
  String get selectLotteryType => _getString('selectLotteryType');
  String get generateNumbers => _getString('generateNumbers');
  String get generatedNumbers => _getString('generatedNumbers');
  String get bonusNumber => _getString('bonusNumber');
  String get playWith => _getString('playWith');
  String get riskNumber => _getString('riskNumber');
  String get historyTitle => _getString('historyTitle');
  String get addEntry => _getString('addEntry');
  String get lotteryType => _getString('lotteryType');
  String get numbersPlayed => _getString('numbersPlayed');
  String get drawDate => _getString('drawDate');
  String get didWin => _getString('didWin');
  String get prizeAmount => _getString('prizeAmount');
  String get notes => _getString('notes');
  String get patternAnalysis => _getString('patternAnalysis');
  String get frequentDigits => _getString('frequentDigits');
  String get rarelyUsed => _getString('rarelyUsed');
  String get avoidThisWeek => _getString('avoidThisWeek');
  String get recommendThisWeek => _getString('recommendThisWeek');
  String get noHistory => _getString('noHistory');
  String get settingsTitle => _getString('settingsTitle');
  String get accountSection => _getString('accountSection');
  String get editProfile => _getString('editProfile');
  String get changePreferences => _getString('changePreferences');
  String get appSection => _getString('appSection');
  String get darkMode => _getString('darkMode');
  String get notifications => _getString('notifications');
  String get aboutSection => _getString('aboutSection');
  String get disclaimer => _getString('disclaimer');
  String get disclaimerText => _getString('disclaimerText');
  String get privacy => _getString('privacy');
  String get terms => _getString('terms');
  String get logout => _getString('logout');
  String get deleteAccount => _getString('deleteAccount');
  String get confirm => _getString('confirm');
  String get cancel => _getString('cancel');
  String get delete => _getString('delete');
  String get edit => _getString('edit');
  String get save => _getString('save');
  String get close => _getString('close');
  String get loading => _getString('loading');
  String get error => _getString('error');
  String get success => _getString('success');
  String get warning => _getString('warning');
  String get sharedSuccessfully => _getString('sharedSuccessfully');
  String get savedSuccessfully => _getString('savedSuccessfully');
  String get deletedSuccessfully => _getString('deletedSuccessfully');
  String get errorLoading => _getString('errorLoading');
  String get errorSaving => _getString('errorSaving');
  String get retry => _getString('retry');
  String get confirmDelete => _getString('confirmDelete');
  String get confirmLogout => _getString('confirmLogout');
  String get confirmDeleteAccount => _getString('confirmDeleteAccount');
  String get fieldRequired => _getString('fieldRequired');
  String get invalidDate => _getString('invalidDate');
  String get selectAtLeastOne => _getString('selectAtLeastOne');
  String get highEnergy => _getString('highEnergy');
  String get mediumEnergy => _getString('mediumEnergy');
  String get lowEnergy => _getString('lowEnergy');
  String get home => _getString('home');
  String get lottery => _getString('lottery');
  String get history => _getString('history');
  String get settings => _getString('settings');
  String get zodiacSign => _getString('zodiacSign');
  String get lifePathNumber => _getString('lifePathNumber');
  String get destinyNumber => _getString('destinyNumber');
  String get luckyColorLabel => _getString('luckyColorLabel');
  String get profile => _getString('profile');
  String get name => _getString('name');
  String get dateOfBirth => _getString('dateOfBirth');
  String get dataManagement => _getString('dataManagement');
  String get clearHistory => _getString('clearHistory');
  String get clearHistoryMessage => _getString('clearHistoryMessage');
  String get clearedSuccessfully => _getString('clearedSuccessfully');
  String get yes => _getString('yes');
  String get logoutMessage => _getString('logoutMessage');
  String get information => _getString('information');
  String get unknown => _getString('unknown');
  String get language => _getString('language');
  String get selectLanguage => _getString('selectLanguage');
  String get languageEnglish => _getString('languageEnglish');
  String get languageSinhala => _getString('languageSinhala');
  String get languageTamil => _getString('languageTamil');
  String get greetingLateNight => _getString('greetingLateNight');
  String get greetingMorning => _getString('greetingMorning');
  String get greetingAfternoon => _getString('greetingAfternoon');
  String get greetingEvening => _getString('greetingEvening');
  String get luckyNumbersRefreshed => _getString('luckyNumbersRefreshed');
  String get numbersCopied => _getString('numbersCopied');
  String get numbersSaved => _getString('numbersSaved');
  String get dailyCosmicInsight => _getString('dailyCosmicInsight');
  String get actionGenerate => _getString('actionGenerate');
  String get actionHistory => _getString('actionHistory');
  String get lotteryInfoMessage => _getString('lotteryInfoMessage');
  String get playWithConfidence => _getString('playWithConfidence');
  String get lotteryEmptyState => _getString('lotteryEmptyState');
  String get selectDate => _getString('selectDate');
  String get timeHint => _getString('timeHint');
  String get errorEnterName => _getString('errorEnterName');
  String get errorSelectDob => _getString('errorSelectDob');
  String get errorEnterPlace => _getString('errorEnterPlace');
  String get errorSelectLotteryType => _getString('errorSelectLotteryType');
  String get errorSavingProfile => _getString('errorSavingProfile');
  String get historyWon => _getString('historyWon');
  String get historyPlayed => _getString('historyPlayed');
  String get historyNumbersLabel => _getString('historyNumbersLabel');
  String get historyDrawLabel => _getString('historyDrawLabel');
  String get historyPrizeLabel => _getString('historyPrizeLabel');
  String get historyRequiredFields => _getString('historyRequiredFields');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.isSupported(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
