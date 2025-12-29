import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raazoneyaz/app_theme.dart';
import 'categories_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen();

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  final List<LanguageOption> languages = [
    LanguageOption(
      code: 'English',
      displayName: 'English',
      flagEmoji: '🇬🇧',
      nativeLanguage: 'English',
    ),
    LanguageOption(
      code: 'Urdu',
      displayName: 'اردو',
      flagEmoji: '🇵🇰',
      nativeLanguage: 'Urdu',
    ),
    LanguageOption(
      code: 'RUrdu',
      displayName: 'Urdu (Romanized)',
      flagEmoji: '🇵🇰',
      nativeLanguage: 'Romanized Urdu',
    )
  ];

  Future<void> _selectLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', languageCode);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const CategoriesScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving language preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving language preference'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.islamicGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Column(
                  children: [
                    // Islamic Icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.language,
                          size: 55,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // App Title
                    Text(
                      'Raazoneyaz',
                      style: AppTheme.headingStyle.copyWith(
                        color: AppTheme.lightText,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      'Select Your Language',
                      style: AppTheme.bodyTextStyle.copyWith(
                        color: AppTheme.lightText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Languages List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final isSelected = _selectedLanguage == language.code;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = language.code;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGold.withValues(alpha: 0.2)
                                  : AppTheme.creamWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryGold
                                    : AppTheme.primaryGreen
                                        .withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                          .withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: isSelected ? 10 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                                vertical: 14.0,
                              ),
                              child: Row(
                                children: [
                                  // Flag
                                  Text(
                                    language.flagEmoji,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                  const SizedBox(width: 16),
                                  // Language Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          language.displayName,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.darkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          language.nativeLanguage,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.darkText.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Checkmark
                                  if (isSelected)
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGold,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: AppTheme.darkGreen,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Continue Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: AppTheme.darkGreen,
                      elevation: _selectedLanguage != null ? 6 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _selectedLanguage != null
                        ? () => _selectLanguage(_selectedLanguage!)
                        : null,
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedLanguage != null
                            ? AppTheme.darkGreen
                            : AppTheme.darkText.withValues(alpha: 0.3),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String displayName;
  final String flagEmoji;
  final String nativeLanguage;

  LanguageOption({
    required this.code,
    required this.displayName,
    required this.flagEmoji,
    required this.nativeLanguage,
  });
}
