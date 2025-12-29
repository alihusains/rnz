import 'package:flutter/material.dart';
import 'package:raazoneyaz/categories_screen.dart';
import 'package:raazoneyaz/language_selection_screen.dart';
import 'package:raazoneyaz/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raazoneyaz',
      theme: AppTheme.getTheme(),
      navigatorKey: navigatorKey,
      home: const LanguageCheckerScreen(),
    );
  }
}

/// Initial screen that checks if language is already selected
/// If yes, navigates to CategoriesScreen
/// If no, navigates to LanguageSelectionScreen
class LanguageCheckerScreen extends StatefulWidget {
  const LanguageCheckerScreen();

  @override
  State<LanguageCheckerScreen> createState() => _LanguageCheckerScreenState();
}

class _LanguageCheckerScreenState extends State<LanguageCheckerScreen> {
  @override
  void initState() {
    super.initState();
    _checkLanguageSelection();
  }

  Future<void> _checkLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if a language is already selected
    if (prefs.containsKey('selectedLanguage')) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CategoriesScreen()),
        );
      }
    } else {
      // Navigate to language selection screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LanguageSelectionScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
