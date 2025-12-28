import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

enum Language { English, Urdu, RUrdu, RArabic, Arabic }

class DetailedScreen extends StatefulWidget {
  final String title;
  final int subIndexId;

  DetailedScreen({required this.title, required this.subIndexId});

  @override
  State<DetailedScreen> createState() => _DetailedScreenState();
}

class _DetailedScreenState extends State<DetailedScreen> {
  List<Map<String, dynamic>> _lines = [];
  String? _selectedLanguage;
  bool _showArabic = true;
  bool _showTransliteration = true;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showArabic = prefs.getBool('showArabic') ?? true;
      _showTransliteration = prefs.getBool('showTransliteration') ?? true;
      _showTranslation = prefs.getBool('showTranslation') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showArabic', _showArabic);
    await prefs.setBool('showTransliteration', _showTransliteration);
    await prefs.setBool('showTranslation', _showTranslation);
  }

  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';

      if (!Language.values.map((e) => e.name).contains(_selectedLanguage)) {
        _selectedLanguage = 'English';
      }

      final db = DatabaseHelper();
      final data = await db.getLinesForSubindex(widget.subIndexId);

      setState(() {
        _lines = data;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load data. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        toolbarHeight: 120,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Checkboxes row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Arabic checkbox
                  Tooltip(
                    message: 'Toggle Arabic',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _showArabic,
                          onChanged: (value) {
                            setState(() {
                              _showArabic = value ?? true;
                            });
                            _savePreferences();
                          },
                        ),
                        const Text('Arabic',
                            style:
                                TextStyle(color: Colors.black, fontSize: 11)),
                      ],
                    ),
                  ),
                  // Transliteration checkbox
                  Tooltip(
                    message: 'Toggle Transliteration',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _showTransliteration,
                          onChanged: (value) {
                            setState(() {
                              _showTransliteration = value ?? true;
                            });
                            _savePreferences();
                          },
                        ),
                        const Text('Transliteration',
                            style:
                                TextStyle(color: Colors.black, fontSize: 11)),
                      ],
                    ),
                  ),
                  // Translation checkbox
                  Tooltip(
                    message: 'Toggle Translation',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _showTranslation,
                          onChanged: (value) {
                            setState(() {
                              _showTranslation = value ?? true;
                            });
                            _savePreferences();
                          },
                        ),
                        const Text('Translation',
                            style:
                                TextStyle(color: Colors.black, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Copy button
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              String copied = _generateCopiedText();
              Clipboard.setData(ClipboardData(text: copied));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Content copied to clipboard')),
              );
            },
          )
        ],
      ),
      body: _lines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _lines.length,
              itemBuilder: (context, index) {
                final line = _lines[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _buildTitle(line),
                    // Description
                    _buildDescription(line),
                    // Arabic Content
                    if (_showArabic) _buildArabicContent(line),
                    // Transliteration (RArabic)
                    if (_showTransliteration) _buildTransliteration(line),
                    // Translation (Language content)
                    if (_showTranslation) _buildTranslation(line),
                    // Spacing between items
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTitle(Map<String, dynamic> line) {
    final title = line['${_selectedLanguage}Title'] ?? '';
    if (title.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title.toString(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> line) {
    final description = line['${_selectedLanguage}Description'] ?? '';
    if (description.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        description.toString(),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildArabicContent(Map<String, dynamic> line) {
    final arabicContent = line['ArabicContent'] ?? '';
    if (arabicContent.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(4),
            border: Border(
              right: BorderSide(color: Colors.amber[200]!, width: 3),
            ),
          ),
          child: Text(
            arabicContent.toString(),
            style: const TextStyle(
              fontFamily: 'Arabic',
              fontSize: 26,
              letterSpacing: 0,
              height: 1.8,
              color: Colors.black87,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }

  Widget _buildTransliteration(Map<String, dynamic> line) {
    final transliteration = line['RArabic'] ?? '';
    if (transliteration.toString().trim().isEmpty)
      return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transliteration',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            transliteration.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslation(Map<String, dynamic> line) {
    final translation = line[_selectedLanguage] ?? '';
    if (translation.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translation ($_selectedLanguage)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            translation.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _generateCopiedText() {
    List<String> chunks = [];
    for (var line in _lines) {
      final title = line['${_selectedLanguage}Title'] ?? '';
      final description = line['${_selectedLanguage}Description'] ?? '';
      final translation = line[_selectedLanguage] ?? '';
      final transliteration = line['RArabic'] ?? '';
      final arabicContent = line['ArabicContent'] ?? '';

      StringBuffer buf = StringBuffer();
      if (title.toString().trim().isNotEmpty) buf.writeln(title);
      if (description.toString().trim().isNotEmpty) buf.writeln(description);
      if (_showArabic && arabicContent.toString().trim().isNotEmpty)
        buf.writeln(arabicContent);
      if (_showTransliteration && transliteration.toString().trim().isNotEmpty)
        buf.writeln(transliteration);
      if (_showTranslation && translation.toString().trim().isNotEmpty)
        buf.writeln(translation);

      if (buf.isNotEmpty) chunks.add(buf.toString());
    }
    final content = chunks.join('\n\n---\n\n');
    return '${widget.title}\n\n$content';
  }
}
