import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _accentColor = const Color(0xFF9C27B0);

  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners(); // notify widgets to rebuild
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners(); // IMPORTANT: notify widgets to rebuild
  }
}
