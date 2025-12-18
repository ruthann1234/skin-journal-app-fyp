import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = "English";

  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // Simple translation map
  Map<String, Map<String, String>> translations = {
    "English": {
      "welcome": "Welcome to Skin Journal",
      "get_started": "Get Started",
    },
    "Malay": {
      "welcome": "Selamat datang ke Skin Journal",
      "get_started": "Mula",
    },
    "Chinese": {"welcome": "欢迎使用 Skin Journal", "get_started": "开始"},
  };

  String t(String key) {
    return translations[_language]?[key] ?? key;
  }
}
