import 'package:flutter/material.dart';
import 'package:raazoneyaz/categories_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category Explorer',
      theme: ThemeData(primarySwatch: Colors.blue),
      navigatorKey: navigatorKey,
      home: LanguageSelector(),
    );
  }
}

class LanguageSelector extends StatefulWidget {
  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  @override
  void initState() {
    super.initState();
    _checkAndSelectLanguage();
  }

  Future<void> _checkAndSelectLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if a language is already selected
    if (prefs.containsKey('selectedLanguage')) {
      _navigateToHome();
      return;
    }

    // Display a dialog to select a language
    final languages = ['English', 'RUrdu', 'Urdu', 'Gujarati'];
    String? selectedLanguage;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return ListTile(
                title: Text(language),
                onTap: () {
                  selectedLanguage = language;
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );

    // Save the selected language and navigate to the home screen
    if (selectedLanguage != null) {
      await prefs.setString('selectedLanguage', selectedLanguage!);
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => CategoriesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
