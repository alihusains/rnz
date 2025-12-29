import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raazoneyaz/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen();

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedLanguage;
  bool _isLoading = true;
  String? _currentLanguage;

  final List<LanguageOptionSettings> languages = [
    LanguageOptionSettings(
      code: 'English',
      displayName: 'English',
      flagEmoji: '🇬🇧',
      nativeLanguage: 'English',
    ),
    LanguageOptionSettings(
      code: 'Urdu',
      displayName: 'اردو',
      flagEmoji: '🇵🇰',
      nativeLanguage: 'Urdu',
    ),
    LanguageOptionSettings(
      code: 'RUrdu',
      displayName: 'Urdu (Romanized)',
      flagEmoji: '🇵🇰',
      nativeLanguage: 'Romanized Urdu',
    )
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('selectedLanguage') ?? 'English';
      setState(() {
        _currentLanguage = language;
        _selectedLanguage = language;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLanguageSelection() async {
    if (_selectedLanguage == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', _selectedLanguage!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Language changed successfully'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _currentLanguage = _selectedLanguage;
        });
      }
    } catch (e) {
      debugPrint('Error saving language preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error changing language'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.creamWhite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your preferred language for the app',
                      style: AppTheme.captionStyle,
                    ),
                  ],
                ),
              ),
              // Language Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: List.generate(
                    languages.length,
                    (index) {
                      final language = languages[index];
                      final isSelected = _selectedLanguage == language.code;
                      final isCurrent = _currentLanguage == language.code;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = language.code;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGold.withValues(alpha: 0.1)
                                  : AppTheme.creamWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryGold
                                    : AppTheme.primaryGreen
                                        .withValues(alpha: 0.2),
                                width: isSelected ? 2 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryGreen
                                            .withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  // Flag
                                  Text(
                                    language.flagEmoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(width: 14),
                                  // Language Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          language.displayName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.darkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          language.nativeLanguage,
                                          style: AppTheme.captionStyle,
                                        ),
                                        if (isCurrent)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '✓ Current',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.successGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Radio Button
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryGold
                                            : AppTheme.primaryGreen,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryGold,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
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
              const SizedBox(height: 28),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedLanguage != _currentLanguage
                              ? AppTheme.primaryGreen
                              : AppTheme.primaryGreen.withValues(alpha: 0.5),
                          elevation:
                              _selectedLanguage != _currentLanguage ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _selectedLanguage != _currentLanguage
                            ? _saveLanguageSelection
                            : null,
                        child: Text(
                          'Save Language',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _selectedLanguage != _currentLanguage
                                ? AppTheme.lightText
                                : AppTheme.lightText.withValues(alpha: 0.5),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.primaryGreen,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 1.5,
                color: AppTheme.primaryGold.withValues(alpha: 0.3),
              ),
              // About Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'About',
                  style: AppTheme.subheadingStyle,
                ),
              ),
              // Info Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      title: 'App Version',
                      value: '1.0.0',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.language,
                      title: 'Current Language',
                      value: _currentLanguage ?? 'Not Set',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: AppTheme.islamicCardDecoration(),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkText.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageOptionSettings {
  final String code;
  final String displayName;
  final String flagEmoji;
  final String nativeLanguage;

  LanguageOptionSettings({
    required this.code,
    required this.displayName,
    required this.flagEmoji,
    required this.nativeLanguage,
  });
}
