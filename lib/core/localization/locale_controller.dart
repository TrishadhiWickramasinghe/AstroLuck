import 'package:flutter/material.dart';
import '../../data/local/local_storage.dart';
import 'app_localizations.dart';

class LocaleController extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  Locale _locale = const Locale('en');
  bool _initialized = false;

  Locale get locale => _locale;
  bool get initialized => _initialized;

  Future<void> load() async {
    await _storage.initialize();
    final storedCode = _storage.getLanguageCode();
    if (storedCode != null && AppLocalizations.isSupported(storedCode)) {
      _locale = Locale(storedCode);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (!AppLocalizations.isSupported(languageCode)) return;
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    await _storage.saveLanguageCode(languageCode);
  }
}
