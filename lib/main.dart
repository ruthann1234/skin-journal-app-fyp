import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'welcome_page.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SkinJournalApp());
}

class SkinJournalApp extends StatelessWidget {
  const SkinJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Skin Journal',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: themeProvider.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              primaryColor: themeProvider.accentColor,
              colorScheme: themeProvider.isDarkMode
                  ? ColorScheme.dark(primary: themeProvider.accentColor)
                  : ColorScheme.light(primary: themeProvider.accentColor),
            ),
            home: const WelcomePage(),
          );
        },
      ),
    );
  }
}
