import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

enum Language { English, Urdu, RUrdu, RArabic, Arabic }

/// Regex pattern to match text within angle brackets like <abcd-efg>
final RegExp _hyperlinkPattern = RegExp(r'<([^>]+)>');

/// Represents a hyperlink span with its text and hyperlink name
class HyperlinkSpan {
  final String text;
  final String hyperlinkName;

  HyperlinkSpan({required this.text, required this.hyperlinkName});
}

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
        automaticallyImplyLeading: false,
        // scrolledUnderElevation: 0.5,
        toolbarHeight: 110,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BackButton(
                  style: ButtonStyle(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    String copied = _generateCopiedText();
                    Clipboard.setData(ClipboardData(text: copied));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Content copied to clipboard')),
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            // Checkboxes row
            Row(
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
                          style: TextStyle(color: Colors.black, fontSize: 11)),
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
                          style: TextStyle(color: Colors.black, fontSize: 11)),
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
                          style: TextStyle(color: Colors.black, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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

    // Check if description contains hyperlinks
    final spans = _parseHyperlinks(description.toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          children: spans.map((span) {
            if (span is HyperlinkSpan) {
              // Render as hyperlink (clickable)
              return WidgetSpan(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      _onHyperlinkTap(span.hyperlinkName);
                    },
                    child: Text(
                      span.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Render as normal text
              return TextSpan(
                text: span as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              );
            }
          }).toList(),
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
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(4),
            // border: Border(
            //   right: BorderSide(color: Colors.amber[200]!, width: 3),
            // ),
          ),
          child: Text(
            arabicContent.toString(),
            style: const TextStyle(
              fontFamily: 'Arabic',
              fontSize: 26,
              letterSpacing: 0,
              height: 1.8,
              color: Colors.black87,
              // align: TextAlign.center,
              fontFeatures: [
                FontFeature.superscripts(),
                FontFeature.subscripts(),
                FontFeature.enable('curs'),
                FontFeature.enable('ccmp'),
                FontFeature.enable('cpsp'),
              ],
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
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
            transliteration.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
              letterSpacing: 0.2,
              fontFeatures: [
                FontFeature.superscripts(),
                FontFeature.subscripts(),
                FontFeature.enable('curs'),
                FontFeature.enable('ccmp'),
                FontFeature.enable('cpsp'),
              ],
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
          // Text(
          //   'Translation ($_selectedLanguage)',
          //   style: TextStyle(
          //     fontSize: 11,
          //     fontWeight: FontWeight.w600,
          //     color: Colors.grey[700],
          //     letterSpacing: 0.5,
          //   ),
          // ),
          // const SizedBox(height: 6),
          Text(
            translation.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Parse description text and extract hyperlinks
  /// Returns a list of either String (normal text) or HyperlinkSpan (clickable hyperlink)
  List<dynamic> _parseHyperlinks(String text) {
    List<dynamic> spans = [];
    int lastIndex = 0;

    // Find all matches of the hyperlink pattern
    for (final match in _hyperlinkPattern.allMatches(text)) {
      // Add text before the hyperlink
      if (match.start > lastIndex) {
        spans.add(text.substring(lastIndex, match.start));
      }

      // Extract the hyperlink name from the captured group
      final hyperlinkName = match.group(1) ?? '';

      // Add the hyperlink span without the brackets
      spans.add(HyperlinkSpan(
        text: hyperlinkName,
        hyperlinkName: hyperlinkName,
      ));

      lastIndex = match.end;
    }

    // Add remaining text after the last hyperlink
    if (lastIndex < text.length) {
      spans.add(text.substring(lastIndex));
    }

    // If no hyperlinks found, return the original text as a single span
    if (spans.isEmpty) {
      spans.add(text);
    }

    return spans;
  }

  /// Handle hyperlink tap event
  /// Fetches data for the hyperlink and navigates to the detail page
  void _onHyperlinkTap(String hyperlinkName) async {
    try {
      // Show loading indicator
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Loading hyperlink...')),
      // );

      final db = DatabaseHelper();

      // Fetch lines using the hyperlink name
      final lines = await db.getLinesByHyperlinkName(hyperlinkName);

      if (lines.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No content found for this hyperlink'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      if (mounted) {
        // Navigate to the detail page with the hyperlink data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailedScreenFromHyperlink(
              title: hyperlinkName,
              lines: lines,
              showArabic: _showArabic,
              showTransliteration: _showTransliteration,
              showTranslation: _showTranslation,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching hyperlink data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading hyperlink: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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

/// Screen for displaying content loaded from hyperlink navigation
class DetailedScreenFromHyperlink extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> lines;
  final bool showArabic;
  final bool showTransliteration;
  final bool showTranslation;

  DetailedScreenFromHyperlink({
    required this.title,
    required this.lines,
    required this.showArabic,
    required this.showTransliteration,
    required this.showTranslation,
  });

  @override
  State<DetailedScreenFromHyperlink> createState() =>
      _DetailedScreenFromHyperlinkState();
}

class _DetailedScreenFromHyperlinkState
    extends State<DetailedScreenFromHyperlink> {
  late bool _showArabic;
  late bool _showTransliteration;
  late bool _showTranslation;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _showArabic = widget.showArabic;
    _showTransliteration = widget.showTransliteration;
    _showTranslation = widget.showTranslation;
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      if (!Language.values.map((e) => e.name).contains(_selectedLanguage)) {
        _selectedLanguage = 'English';
        // _selectedLanguage = 'RUrdu';
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showArabic', _showArabic);
    await prefs.setBool('showTransliteration', _showTransliteration);
    await prefs.setBool('showTranslation', _showTranslation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 110,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BackButton(
                  style: ButtonStyle(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    String copied = _generateCopiedText();
                    Clipboard.setData(ClipboardData(text: copied));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Content copied to clipboard')),
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            // Checkboxes row
            Row(
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
                          style: TextStyle(color: Colors.black, fontSize: 11)),
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
                          style: TextStyle(color: Colors.black, fontSize: 11)),
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
                          style: TextStyle(color: Colors.black, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: widget.lines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: widget.lines.length,
              itemBuilder: (context, index) {
                final line = widget.lines[index];
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

    // Check if description contains hyperlinks
    final spans = _parseHyperlinks(description.toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          children: spans.map((span) {
            if (span is HyperlinkSpan) {
              // Render as hyperlink (clickable)
              return WidgetSpan(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      _onHyperlinkTap(span.hyperlinkName);
                    },
                    child: Text(
                      span.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Render as normal text
              return TextSpan(
                text: span as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              );
            }
          }).toList(),
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
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(4),
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
            textAlign: TextAlign.center,
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
            translation.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Parse description text and extract hyperlinks
  List<dynamic> _parseHyperlinks(String text) {
    List<dynamic> spans = [];
    int lastIndex = 0;

    for (final match in _hyperlinkPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(text.substring(lastIndex, match.start));
      }

      final hyperlinkName = match.group(1) ?? '';
      spans.add(HyperlinkSpan(
        text: hyperlinkName,
        hyperlinkName: hyperlinkName,
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(text.substring(lastIndex));
    }

    if (spans.isEmpty) {
      spans.add(text);
    }

    return spans;
  }

  /// Handle hyperlink tap event
  void _onHyperlinkTap(String hyperlinkName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading hyperlink...')),
      );

      final db = DatabaseHelper();
      final lines = await db.getLinesByHyperlinkName(hyperlinkName);

      if (lines.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No content found for this hyperlink'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailedScreenFromHyperlink(
              title: hyperlinkName,
              lines: lines,
              showArabic: _showArabic,
              showTransliteration: _showTransliteration,
              showTranslation: _showTranslation,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching hyperlink data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading hyperlink: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _generateCopiedText() {
    List<String> chunks = [];
    for (var line in widget.lines) {
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
