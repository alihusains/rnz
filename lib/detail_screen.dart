// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class DetailedScreen extends StatelessWidget {
//   final String title;
//   final List<Map<String, dynamic>> lines;

//   DetailedScreen({required this.title, required this.lines});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.copy),
//             onPressed: () {

//               final tabIndex = DefaultTabController.of(context).index;
//               final tabLanguage = _getTabLanguage(tabIndex);
//               final copiedText = _generateCopiedText(tabLanguage);
//               debugPrint(copiedText.toString());
// //                   // Copy to clipboard
//               Clipboard.setData(ClipboardData(text: copiedText.toString()));

//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('$title copied')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: DefaultTabController(
//         length: 5,
//         child: Column(
//           children: [
//             const TabBar(
//               tabs: [
//                 Tab(text: 'English'), //english
//                 Tab(text: 'Urdu'), //urdu
//                 Tab(text: 'RUrdu'), //translation
//                 Tab(text: 'RArabic'), //transliteration
//                 Tab(
//                   text: 'Arabic',
//                 ) //arabic
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   _buildTabContent('English'),
//                   _buildTabContent('Urdu'),
//                   _buildTabContent('RUrdu'),
//                   _buildTabContent('RArabic'),
//                   _buildTabContent('Arabic'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent(String language) {
//     return ListView.builder(
//       itemCount: lines.length,
//       itemBuilder: (context, index) {
//         final line = lines[index];
//         return ListTile(
//           title: language == 'Arabic'
//               ? Text(line['ArabicText1'] ?? '')
//               : Text(line['${language}'] ?? ''),
//           // subtitle: Text(line['${language}Description'] ?? 'No Description'),
//         );
//       },
//     );
//   }

//   String _generateCopiedText(String language) {
//     final titleTag =
//         language == 'Arabic' ? 'arabictitle' : '${language.toLowerCase()}title';
//     final contentTag = language == 'Arabic'
//         ? 'arabiccontent'
//         : '${language.toLowerCase()}content';

//     // Generate the content based on what is displayed in the ListTile
//     final contentLines = lines
//         .map((line) {
//           final content =
//               language == 'Arabic' ? line['ArabicText1'] : line[language];
//           return content ?? ''; // Fallback to empty string if null
//         })
//         .where((content) => content.isNotEmpty)
//         .join('<br>');
//     debugPrint("copytext:   " + contentLines);
//     return '''
// <div class="$titleTag">$title</div>
// <div class='$contentTag'>$contentLines</div>
// ''';
//   }
// }

// String _getTabLanguage(int index) {
//   switch (index) {
//     case 0:
//       return 'English';
//     case 1:
//       return 'Urdu';
//     case 2:
//       return 'RUrdu';
//     case 3:
//       return 'RArabic';
//     case 4:
//       return 'Arabic';
//     default:
//       return 'English';
//   }
// }

//===========================================================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailedScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> lines;

  DetailedScreen({required this.title, required this.lines});

  @override
  State<DetailedScreen> createState() => _DetailedScreenState();
}

class _DetailedScreenState extends State<DetailedScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    final tabController = DefaultTabController.of(context);
                    final tabIndex = tabController.index;
                    final tabLanguage = _getTabLanguage(tabIndex);
                    final copiedText = _generateCopiedText(tabLanguage);

                    Clipboard.setData(ClipboardData(text: copiedText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.title} copied')),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'English'), // English
                    Tab(text: 'Urdu'), // Urdu
                    Tab(text: 'RUrdu'), // Translation
                    Tab(text: 'RArabic'), // Transliteration
                    Tab(text: 'Arabic'), // Arabic
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTabContent('English'),
                      _buildTabContent('Urdu'),
                      _buildTabContent('RUrdu'),
                      _buildTabContent('RArabic'),
                      _buildTabContent('Arabic'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(String language) {
    return ListView.builder(
      itemCount: widget.lines.length,
      itemBuilder: (context, index) {
        final line = widget.lines[index];
        return ListTile(
          title: language == 'Arabic'
              ? Text(line['ArabicText1'] ?? '')
              : Text(line['${language}'] ?? ''),
        );
      },
    );
  }

  String _generateCopiedText(String language) {
    final titleTag =
        language == 'Arabic' ? 'arabictitle' : '${language.toLowerCase()}title';
    final contentTag = language == 'Arabic'
        ? 'arabiccontent'
        : '${language.toLowerCase()}content';

    final contentLines = widget.lines
        .map((line) {
          final content =
              language == 'Arabic' ? line['ArabicText1'] : line[language];
          return content ?? ''; // Fallback to empty string if null
        })
        .where((content) => content.isNotEmpty)
        .join('<br>');
    return '''
${widget.title}===<div class="$titleTag">${widget.title}</div>===<div class='$contentTag'>$contentLines</div>
''';
  }
}

String _getTabLanguage(int index) {
  switch (index) {
    case 0:
      return 'English';
    case 1:
      return 'Urdu';
    case 2:
      return 'RUrdu';
    case 3:
      return 'RArabic';
    case 4:
      return 'Arabic';
    default:
      return 'English';
  }
}
