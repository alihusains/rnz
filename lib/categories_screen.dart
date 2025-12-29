// // // import 'package:flutter/material.dart';
// // // import 'package:raazoneyaz/detail_screen.dart';
// // // import 'package:raazoneyaz/settings_screen.dart';
// // // import 'package:raazoneyaz/bookmarks_screen.dart';
// // // import 'package:raazoneyaz/app_theme.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'database_helper.dart';

// // // class CategoriesScreen extends StatefulWidget {
// // //   final int categoryId;
// // //   final int parentId;
// // //   final int level;
// // //   final String? title;

// // //   const CategoriesScreen({
// // //     Key? key,
// // //     this.categoryId = 0,
// // //     this.parentId = 0,
// // //     this.level = 0,
// // //     this.title,
// // //   }) : super(key: key);

// // //   @override
// // //   _CategoriesScreenState createState() => _CategoriesScreenState();
// // // }

// // // class _CategoriesScreenState extends State<CategoriesScreen> {
// // //   List<Map<String, dynamic>> items = [];
// // //   late DatabaseHelper _dbHelper;
// // //   String? _selectedLanguage;
// // //   bool _isLoading = true;

// // //   @override
// // //   void initState() {
// // //     _loadLanguagePreferenceAndData();
// // //     _dbHelper = DatabaseHelper();

// // //     super.initState();
// // //   }

// // //   Future<void> _loadLanguagePreferenceAndData() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final language = prefs.getString('selectedLanguage') ?? 'English';

// // //       if (mounted) {
// // //         setState(() {
// // //           _selectedLanguage = language;
// // //         });
// // //       }

// // //       // Fetch data after language is set
// // //       if (widget.categoryId == 0) {
// // //         await _fetchCategories();
// // //       } else {
// // //         await _fetchSubcategories();
// // //       }

// // //       if (mounted) {
// // //         setState(() {
// // //           _isLoading = false;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error loading language preference: $e');
// // //       if (mounted) {
// // //         setState(() {
// // //           _selectedLanguage = 'English';
// // //           _isLoading = false;
// // //         });
// // //       }
// // //       if (widget.categoryId == 0) {
// // //         await _fetchCategories();
// // //       } else {
// // //         await _fetchSubcategories();
// // //       }
// // //     }
// // //   }

// // //   /// Get the display column name based on selected language
// // //   String _getDisplayColumnName() {
// // //     switch (_selectedLanguage) {
// // //       case 'English':
// // //         return 'English';
// // //       case 'Urdu':
// // //         return 'Urdu';
// // //       case 'RUrdu':
// // //         return 'RUrdu';
// // //       default:
// // //         return 'English';
// // //     }
// // //   }

// // //   /// Get display text from item based on selected language
// // //   String _getDisplayText(Map<String, dynamic> item) {
// // //     final columnName = _getDisplayColumnName();
// // //     final indexColumnName = '${columnName}IndexName';

// // //     // Try index name first, then regular name, fallback to English
// // //     return item[indexColumnName] ??
// // //         item[columnName] ??
// // //         item['EnglishIndexName'] ??
// // //         item['EnglishName'] ??
// // //         '';
// // //   }

// // //   Future<void> _fetchCategories() async {
// // //     try {
// // //       final result = await _dbHelper.getCategories();
// // //       debugPrint('Fetched categories: $result');
// // //       if (mounted) {
// // //         setState(() {
// // //           items = result;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error fetching categories: $e');
// // //       _showErrorSnackBar('Failed to load categories.');
// // //     }
// // //   }

// // //   Future<void> _fetchSubcategories() async {
// // //     try {
// // //       final result = await _dbHelper.getSubcategories(
// // //           widget.categoryId, widget.parentId, widget.level);
// // //       debugPrint(
// // //           'Fetched subcategories (CategoryId=${widget.categoryId}, ParentId=${widget.parentId}, Level=${widget.level}): $result');
// // //       if (mounted) {
// // //         setState(() {
// // //           items = result;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error fetching subcategories: $e');
// // //       _showErrorSnackBar('Failed to load subcategories.');
// // //     }
// // //   }

// // //   Future<void> _navigateToDetailScreen(int subIndexId, String title) async {
// // //     try {
// // //       debugPrint(
// // //           'Navigating to detail screen for subIndexId=$subIndexId, title=$title');
// // //       final lines = await _dbHelper.getLinesForSubindex(subIndexId);
// // //       debugPrint('Fetched ${lines.length} lines for subIndexId=$subIndexId');
// // //       if (mounted) {
// // //         Navigator.push(
// // //           context,
// // //           MaterialPageRoute(
// // //             builder: (context) =>
// // //                 DetailedScreen(title: title, subIndexId: subIndexId),
// // //           ),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error navigating to detail screen: $e');
// // //       _showErrorSnackBar('Failed to load details.');
// // //     }
// // //   }

// // //   void _showErrorSnackBar(String message) {
// // //     if (mounted) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text(message)),
// // //       );
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final isRoot = widget.categoryId == 0;
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text(widget.title ?? (isRoot ? 'Categories' : 'Subcategories')),
// // //         automaticallyImplyLeading: !isRoot,
// // //         actions: isRoot
// // //             ? [
// // //                 IconButton(
// // //                   icon: const Icon(Icons.favorite),
// // //                   onPressed: () {
// // //                     Navigator.push(
// // //                       context,
// // //                       MaterialPageRoute(
// // //                         builder: (context) => const BookmarksScreen(),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //                 IconButton(
// // //                   icon: const Icon(Icons.settings),
// // //                   onPressed: () {
// // //                     Navigator.push(
// // //                       context,
// // //                       MaterialPageRoute(
// // //                         builder: (context) => const SettingsScreen(),
// // //                       ),
// // //                     ).then((_) {
// // //                       // Reload data and language when returning from settings
// // //                       _loadLanguagePreferenceAndData();
// // //                     });
// // //                   },
// // //                 ),
// // //               ]
// // //             : null,
// // //       ),
// // //       body: Container(
// // //         color: AppTheme.creamWhite,
// // //         child: _isLoading
// // //             ? const Center(child: CircularProgressIndicator())
// // //             : items.isEmpty
// // //                 ? const Center(child: CircularProgressIndicator())
// // //                 : ListView.builder(
// // //                     padding:
// // //                         const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// // //                     itemCount: items.length,
// // //                     itemBuilder: (context, index) {
// // //                       final item = items[index];
// // //                       final hasChildren = item['HasChildren'] == 1;
// // //                       final displayText = _getDisplayText(item);

// // //                       return Padding(
// // //                         padding: const EdgeInsets.symmetric(
// // //                             horizontal: 8.0, vertical: 4.0),
// // //                         child: Card(
// // //                           elevation: 2,
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(10),
// // //                             side: BorderSide(
// // //                               color:
// // //                                   AppTheme.primaryGold.withValues(alpha: 0.3),
// // //                               width: 1,
// // //                             ),
// // //                           ),
// // //                           child: ListTile(
// // //                             contentPadding: const EdgeInsets.symmetric(
// // //                                 horizontal: 16, vertical: 8),
// // //                             title: Text(
// // //                               displayText,
// // //                               style: const TextStyle(
// // //                                 color: AppTheme.darkGreen,
// // //                                 fontWeight: FontWeight.w600,
// // //                                 fontSize: 15,
// // //                               ),
// // //                             ),
// // //                             trailing: hasChildren
// // //                                 ? const Icon(
// // //                                     Icons.arrow_forward_ios,
// // //                                     size: 18,
// // //                                     color: AppTheme.primaryGold,
// // //                                   )
// // //                                 : Icon(
// // //                                     Icons.chevron_right,
// // //                                     color: AppTheme.primaryGreen
// // //                                         .withValues(alpha: 0.4),
// // //                                   ),
// // //                             onTap: () {
// // //                               if (isRoot) {
// // //                                 final catId = item['Id'] as int;
// // //                                 debugPrint(
// // //                                     'Tapped top-level category: CategoryId=$catId, title=$displayText');
// // //                                 Navigator.push(
// // //                                   context,
// // //                                   MaterialPageRoute(
// // //                                     builder: (context) => CategoriesScreen(
// // //                                       categoryId: catId,
// // //                                       parentId: catId,
// // //                                       level: 0,
// // //                                       title: displayText,
// // //                                     ),
// // //                                   ),
// // //                                 );
// // //                               } else if (hasChildren) {
// // //                                 final nextParent = item['Id'] as int;
// // //                                 debugPrint(
// // //                                     'Tapped subcategory: CategoryId=${widget.categoryId}, ParentId=$nextParent, Level=${widget.level + 1}, title=$displayText');
// // //                                 Navigator.push(
// // //                                   context,
// // //                                   MaterialPageRoute(
// // //                                     builder: (context) => CategoriesScreen(
// // //                                       categoryId: widget.categoryId,
// // //                                       parentId: nextParent,
// // //                                       level: widget.level + 1,
// // //                                       title: displayText,
// // //                                     ),
// // //                                   ),
// // //                                 );
// // //                               } else {
// // //                                 debugPrint(
// // //                                     'Tapped leaf item: Id=${item['Id']}, title=$displayText');
// // //                                 _navigateToDetailScreen(
// // //                                     item['Id'] as int, displayText);
// // //                               }
// // //                             },
// // //                           ),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:raazoneyaz/detail_screen.dart';
// // import 'package:raazoneyaz/settings_screen.dart';
// // import 'package:raazoneyaz/bookmarks_screen.dart';
// // import 'package:raazoneyaz/app_theme.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'database_helper.dart';

// // class CategoriesScreen extends StatefulWidget {
// //   final int categoryId;
// //   final int parentId;
// //   final int level;
// //   final String? title;

// //   const CategoriesScreen({
// //     Key? key,
// //     this.categoryId = 0,
// //     this.parentId = 0,
// //     this.level = 0,
// //     this.title,
// //   }) : super(key: key);

// //   @override
// //   _CategoriesScreenState createState() => _CategoriesScreenState();
// // }

// // class _CategoriesScreenState extends State<CategoriesScreen> {
// //   List<Map<String, dynamic>> items = [];
// //   late DatabaseHelper _dbHelper;
// //   String? _selectedLanguage;
// //   bool _isLoading = true;
// //   String? _errorMessage;

// //   @override
// //   void initState() {
// //     _dbHelper = DatabaseHelper();
// //     _loadLanguagePreferenceAndData();
// //     super.initState();
// //   }

// //   /// Fetch data with proper error handling
// //   Future<void> _loadLanguagePreferenceAndData() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final language = prefs.getString('selectedLanguage') ?? 'English';

// //       if (mounted) {
// //         setState(() {
// //           _selectedLanguage = language;
// //           _errorMessage = null;
// //         });
// //       }

// //       // Fetch data after language is set
// //       if (widget.categoryId == 0) {
// //         await _fetchCategories();
// //       } else {
// //         await _fetchSubcategories();
// //       }

// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint('Error loading language preference: $e');
// //       if (mounted) {
// //         setState(() {
// //           _selectedLanguage = 'English';
// //           _isLoading = false;
// //           _errorMessage = 'Failed to load categories: $e';
// //         });
// //       }
// //       _showErrorSnackBar('Failed to load categories.');
// //     }
// //   }

// //   /// Get the display column name based on selected language
// //   String _getDisplayColumnName() {
// //     switch (_selectedLanguage) {
// //       case 'English':
// //         return 'English';
// //       case 'Urdu':
// //         return 'Urdu';
// //       case 'RUrdu':
// //         return 'RUrdu';
// //       default:
// //         return 'English';
// //     }
// //   }

// //   /// Get display text from item based on selected language
// //   String _getDisplayText(Map<String, dynamic> item) {
// //     final columnName = _getDisplayColumnName();
// //     final indexColumnName = '${columnName}IndexName';

// //     // Try index name first, then regular name, fallback to English
// //     return item[indexColumnName] ??
// //         item[columnName] ??
// //         item['EnglishIndexName'] ??
// //         item['EnglishName'] ??
// //         'Unnamed';
// //   }

// //   Future<void> _fetchCategories() async {
// //     try {
// //       final result = await _dbHelper.getCategories();
// //       debugPrint('Fetched categories: ${result.length} items');
// //       if (mounted) {
// //         setState(() {
// //           items = result;
// //           _errorMessage = null;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint('Error fetching categories: $e');
// //       if (mounted) {
// //         setState(() {
// //           items = [];
// //           _errorMessage = 'Failed to load categories: $e';
// //         });
// //       }
// //       _showErrorSnackBar('Failed to load categories.');
// //     }
// //   }

// //   Future<void> _fetchSubcategories() async {
// //     try {
// //       final result = await _dbHelper.getSubcategories(
// //           widget.categoryId, widget.parentId, widget.level);
// //       debugPrint(
// //           'Fetched subcategories (CategoryId=${widget.categoryId}, ParentId=${widget.parentId}, Level=${widget.level}): ${result.length} items');
// //       if (mounted) {
// //         setState(() {
// //           items = result;
// //           _errorMessage = null;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint('Error fetching subcategories: $e');
// //       if (mounted) {
// //         setState(() {
// //           items = [];
// //           _errorMessage = 'Failed to load subcategories: $e';
// //         });
// //       }
// //       _showErrorSnackBar('Failed to load subcategories.');
// //     }
// //   }

// //   Future<void> _navigateToDetailScreen(int subIndexId, String title) async {
// //     try {
// //       debugPrint(
// //           'Navigating to detail screen for subIndexId=$subIndexId, title=$title');
// //       final lines = await _dbHelper.getLinesForSubindex(subIndexId);
// //       debugPrint('Fetched ${lines.length} lines for subIndexId=$subIndexId');
// //       if (mounted) {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) =>
// //                 DetailedScreen(title: title, subIndexId: subIndexId),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint('Error navigating to detail screen: $e');
// //       _showErrorSnackBar('Failed to load details.');
// //     }
// //   }

// //   void _showErrorSnackBar(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final isRoot = widget.categoryId == 0;
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(widget.title ?? (isRoot ? 'Categories' : 'Subcategories')),
// //         automaticallyImplyLeading: !isRoot,
// //         actions: isRoot
// //             ? [
// //                 IconButton(
// //                   icon: const Icon(Icons.favorite),
// //                   onPressed: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) => const BookmarksScreen(),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.settings),
// //                   onPressed: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) => const SettingsScreen(),
// //                       ),
// //                     ).then((_) {
// //                       // Reload data and language when returning from settings
// //                       _loadLanguagePreferenceAndData();
// //                     });
// //                   },
// //                 ),
// //               ]
// //             : null,
// //       ),
// //       body: Container(
// //         color: AppTheme.creamWhite,
// //         child: _isLoading
// //             ? const Center(child: CircularProgressIndicator())
// //             : _errorMessage != null
// //                 ? Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         const Icon(Icons.error_outline,
// //                             size: 64, color: Colors.red),
// //                         const SizedBox(height: 16),
// //                         Text(
// //                           _errorMessage!,
// //                           textAlign: TextAlign.center,
// //                           style:
// //                               const TextStyle(fontSize: 16, color: Colors.red),
// //                         ),
// //                         const SizedBox(height: 16),
// //                         ElevatedButton(
// //                           onPressed: () {
// //                             setState(() {
// //                               _isLoading = true;
// //                               _errorMessage = null;
// //                             });
// //                             _loadLanguagePreferenceAndData();
// //                           },
// //                           child: const Text('Retry'),
// //                         ),
// //                       ],
// //                     ),
// //                   )
// //                 : items.isEmpty
// //                     ? const Center(
// //                         child: Text('No categories found'),
// //                       )
// //                     : ListView.builder(
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 8, vertical: 8),
// //                         itemCount: items.length,
// //                         itemBuilder: (context, index) {
// //                           final item = items[index];
// //                           final hasChildren = item['HasChildren'] == 1;
// //                           final displayText = _getDisplayText(item);

// //                           return Padding(
// //                             padding: const EdgeInsets.symmetric(
// //                                 horizontal: 8.0, vertical: 4.0),
// //                             child: Card(
// //                               elevation: 2,
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 side: BorderSide(
// //                                   color: AppTheme.primaryGold
// //                                       .withValues(alpha: 0.3),
// //                                   width: 1,
// //                                 ),
// //                               ),
// //                               child: ListTile(
// //                                 contentPadding: const EdgeInsets.symmetric(
// //                                     horizontal: 16, vertical: 8),
// //                                 title: Text(
// //                                   displayText,
// //                                   style: const TextStyle(
// //                                     color: AppTheme.darkGreen,
// //                                     fontWeight: FontWeight.w600,
// //                                     fontSize: 15,
// //                                   ),
// //                                 ),
// //                                 trailing: hasChildren
// //                                     ? const Icon(
// //                                         Icons.arrow_forward_ios,
// //                                         size: 18,
// //                                         color: AppTheme.primaryGold,
// //                                       )
// //                                     : Icon(
// //                                         Icons.chevron_right,
// //                                         color: AppTheme.primaryGreen
// //                                             .withValues(alpha: 0.4),
// //                                       ),
// //                                 onTap: () {
// //                                   if (isRoot) {
// //                                     final catId = item['Id'] as int;
// //                                     debugPrint(
// //                                         'Tapped top-level category: CategoryId=$catId, title=$displayText');
// //                                     Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) => CategoriesScreen(
// //                                           categoryId: catId,
// //                                           parentId: catId,
// //                                           level: 0,
// //                                           title: displayText,
// //                                         ),
// //                                       ),
// //                                     );
// //                                   } else if (hasChildren) {
// //                                     final nextParent = item['Id'] as int;
// //                                     debugPrint(
// //                                         'Tapped subcategory: CategoryId=${widget.categoryId}, ParentId=$nextParent, Level=${widget.level + 1}, title=$displayText');
// //                                     Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) => CategoriesScreen(
// //                                           categoryId: widget.categoryId,
// //                                           parentId: nextParent,
// //                                           level: widget.level + 1,
// //                                           title: displayText,
// //                                         ),
// //                                       ),
// //                                     );
// //                                   } else {
// //                                     debugPrint(
// //                                         'Tapped leaf item: Id=${item['Id']}, title=$displayText');
// //                                     _navigateToDetailScreen(
// //                                         item['Id'] as int, displayText);
// //                                   }
// //                                 },
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:raazoneyaz/detail_screen.dart';
// import 'package:raazoneyaz/settings_screen.dart';
// import 'package:raazoneyaz/bookmarks_screen.dart';
// import 'package:raazoneyaz/app_theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'database_helper.dart';

// class CategoriesScreen extends StatefulWidget {
//   final int categoryId;
//   final int parentId;
//   final int level;
//   final String? title;

//   const CategoriesScreen({
//     Key? key,
//     this.categoryId = 0,
//     this.parentId = 0,
//     this.level = 0,
//     this.title,
//   }) : super(key: key);

//   @override
//   _CategoriesScreenState createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen> {
//   List<Map<String, dynamic>> items = [];
//   late DatabaseHelper _dbHelper;
//   String? _selectedLanguage;
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     _dbHelper = DatabaseHelper();
//     _loadLanguagePreferenceAndData();
//     super.initState();
//   }

//   /// Load language and fetch data with comprehensive error handling
//   Future<void> _loadLanguagePreferenceAndData() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final language = prefs.getString('selectedLanguage') ?? 'English';

//       if (mounted) {
//         setState(() {
//           _selectedLanguage = language;
//         });
//       }

//       // Fetch data
//       if (widget.categoryId == 0) {
//         await _fetchCategories();
//       } else {
//         await _fetchSubcategories();
//       }

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading language preference: $e');
//       if (mounted) {
//         setState(() {
//           _selectedLanguage = 'English';
//           _isLoading = false;
//           _errorMessage = 'Failed to load data: ${e.toString()}';
//         });
//       }
//       _showErrorSnackBar('Failed to load categories.');
//     }
//   }

//   String _getDisplayColumnName() {
//     switch (_selectedLanguage) {
//       case 'English':
//         return 'English';
//       case 'Urdu':
//         return 'Urdu';
//       case 'RUrdu':
//         return 'RUrdu';
//       default:
//         return 'English';
//     }
//   }

//   String _getDisplayText(Map<String, dynamic> item) {
//     final columnName = _getDisplayColumnName();
//     final indexColumnName = '${columnName}IndexName';

//     return item[indexColumnName] ??
//         item[columnName] ??
//         item['EnglishIndexName'] ??
//         item['EnglishName'] ??
//         'Unnamed';
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       debugPrint('Fetching categories...');
//       final result = await _dbHelper.getCategories();
//       if (mounted) {
//         setState(() {
//           items = result;
//           _errorMessage = null;
//           debugPrint('Successfully loaded ${result.length} categories');
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching categories: $e');
//       if (mounted) {
//         setState(() {
//           items = [];
//           _errorMessage = 'Database Error: ${e.toString()}';
//         });
//       }
//       _showErrorSnackBar('Failed to load categories.');
//     }
//   }

//   Future<void> _fetchSubcategories() async {
//     try {
//       debugPrint(
//           'Fetching subcategories (CategoryId=${widget.categoryId}, ParentId=${widget.parentId}, Level=${widget.level})...');
//       final result = await _dbHelper.getSubcategories(
//           widget.categoryId, widget.parentId, widget.level);
//       if (mounted) {
//         setState(() {
//           items = result;
//           _errorMessage = null;
//           debugPrint('Successfully loaded ${result.length} subcategories');
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching subcategories: $e');
//       if (mounted) {
//         setState(() {
//           items = [];
//           _errorMessage = 'Database Error: ${e.toString()}';
//         });
//       }
//       _showErrorSnackBar('Failed to load subcategories.');
//     }
//   }

//   Future<void> _navigateToDetailScreen(int subIndexId, String title) async {
//     try {
//       debugPrint('Navigating to detail screen for subIndexId=$subIndexId...');
//       await _dbHelper.getLinesForSubindex(subIndexId);
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 DetailedScreen(title: title, subIndexId: subIndexId),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error navigating to detail screen: $e');
//       _showErrorSnackBar('Failed to load details.');
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isRoot = widget.categoryId == 0;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title ?? (isRoot ? 'Categories' : 'Subcategories')),
//         automaticallyImplyLeading: !isRoot,
//         actions: isRoot
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.favorite),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const BookmarksScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.settings),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SettingsScreen(),
//                       ),
//                     ).then((_) {
//                       _loadLanguagePreferenceAndData();
//                     });
//                   },
//                 ),
//               ]
//             : null,
//       ),
//       body: Container(
//         color: AppTheme.creamWhite,
//         child: _isLoading
//             ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Loading categories...'),
//                   ],
//                 ),
//               )
//             : _errorMessage != null
//                 ? Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.error_outline,
//                               size: 64, color: Colors.red),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Oops! Something went wrong',
//                             style: Theme.of(context).textTheme.titleLarge,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _errorMessage!,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                                 fontSize: 14, color: Colors.grey),
//                           ),
//                           const SizedBox(height: 24),
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               _loadLanguagePreferenceAndData();
//                             },
//                             icon: const Icon(Icons.refresh),
//                             label: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : items.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.folder_open,
//                                 size: 64, color: Colors.grey),
//                             const SizedBox(height: 16),
//                             const Text('No categories found'),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               onPressed: () {
//                                 _loadLanguagePreferenceAndData();
//                               },
//                               child: const Text('Retry'),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 8),
//                         itemCount: items.length,
//                         itemBuilder: (context, index) {
//                           final item = items[index];
//                           final hasChildren = item['HasChildren'] == 1;
//                           final displayText = _getDisplayText(item);

//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8.0, vertical: 4.0),
//                             child: Card(
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 side: BorderSide(
//                                   color: AppTheme.primaryGold
//                                       .withValues(alpha: 0.3),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: ListTile(
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 8),
//                                 title: Text(
//                                   displayText,
//                                   style: const TextStyle(
//                                     color: AppTheme.darkGreen,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                                 trailing: hasChildren
//                                     ? const Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 18,
//                                         color: AppTheme.primaryGold,
//                                       )
//                                     : Icon(
//                                         Icons.chevron_right,
//                                         color: AppTheme.primaryGreen
//                                             .withValues(alpha: 0.4),
//                                       ),
//                                 onTap: () {
//                                   if (isRoot) {
//                                     final catId = item['Id'] as int;
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => CategoriesScreen(
//                                           categoryId: catId,
//                                           parentId: catId,
//                                           level: 0,
//                                           title: displayText,
//                                         ),
//                                       ),
//                                     );
//                                   } else if (hasChildren) {
//                                     final nextParent = item['Id'] as int;
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => CategoriesScreen(
//                                           categoryId: widget.categoryId,
//                                           parentId: nextParent,
//                                           level: widget.level + 1,
//                                           title: displayText,
//                                         ),
//                                       ),
//                                     );
//                                   } else {
//                                     _navigateToDetailScreen(
//                                         item['Id'] as int, displayText);
//                                   }
//                                 },
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:raazoneyaz/detail_screen.dart';
import 'package:raazoneyaz/settings_screen.dart';
import 'package:raazoneyaz/bookmarks_screen.dart';
import 'package:raazoneyaz/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class CategoriesScreen extends StatefulWidget {
  final int categoryId;
  final int parentId;
  final int level;
  final String? title;

  const CategoriesScreen({
    Key? key,
    this.categoryId = 0,
    this.parentId = 0,
    this.level = 0,
    this.title,
  }) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> items = [];
  late DatabaseHelper _dbHelper;
  String? _selectedLanguage;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    _dbHelper = DatabaseHelper();
    _loadLanguagePreferenceAndData();
    super.initState();
  }

  /// Load language and fetch data with comprehensive error handling
  Future<void> _loadLanguagePreferenceAndData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('selectedLanguage') ?? 'English';

      if (mounted) {
        setState(() {
          _selectedLanguage = language;
        });
      }

      // Fetch data
      if (widget.categoryId == 0) {
        await _fetchCategories();
      } else {
        await _fetchSubcategories();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      if (mounted) {
        setState(() {
          _selectedLanguage = 'English';
          _isLoading = false;
          _errorMessage = 'Failed to load data: ${e.toString()}';
        });
      }
      _showErrorSnackBar('Failed to load categories.');
    }
  }

  String _getDisplayColumnName() {
    switch (_selectedLanguage) {
      case 'English':
        return 'English';
      case 'Urdu':
        return 'Urdu';
      case 'RUrdu':
        return 'RUrdu';
      default:
        return 'English';
    }
  }

  String _getDisplayText(Map<String, dynamic> item) {
    final columnName = _getDisplayColumnName();
    final langName = '${columnName}Name';
    final indexColumnName = '${columnName}IndexName';

    debugPrint('Getting display text for item: $item');
    debugPrint(
        'Using columnName: $columnName, indexColumnName: $indexColumnName');
    return item[indexColumnName] ??
        item[langName] ??
        item[columnName] ??
        item['EnglishIndexName'] ??
        item['EnglishName'] ??
        'Unnamed';
  }

  Future<void> _fetchCategories() async {
    try {
      debugPrint('Fetching categories...');
      final result = await _dbHelper.getCategories();
      if (mounted) {
        setState(() {
          items = result;
          _errorMessage = null;
          debugPrint('Successfully loaded ${result.length} categories');
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          items = [];
          _errorMessage = 'Database Error: ${e.toString()}';
        });
      }
      _showErrorSnackBar('Failed to load categories.');
    }
  }

  Future<void> _fetchSubcategories() async {
    try {
      debugPrint(
          'Fetching subcategories (CategoryId=${widget.categoryId}, ParentId=${widget.parentId}, Level=${widget.level})...');
      final result = await _dbHelper.getSubcategories(
          widget.categoryId, widget.parentId, widget.level);
      if (mounted) {
        setState(() {
          items = result;
          _errorMessage = null;
          debugPrint('Successfully loaded ${result.length} subcategories');
        });
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      if (mounted) {
        setState(() {
          items = [];
          _errorMessage = 'Database Error: ${e.toString()}';
        });
      }
      _showErrorSnackBar('Failed to load subcategories.');
    }
  }

  Future<void> _navigateToDetailScreen(int subIndexId, String title) async {
    try {
      debugPrint('Navigating to detail screen for subIndexId=$subIndexId...');
      await _dbHelper.getLinesForSubindex(subIndexId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailedScreen(title: title, subIndexId: subIndexId),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error navigating to detail screen: $e');
      _showErrorSnackBar('Failed to load details.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRoot = widget.categoryId == 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? (isRoot ? 'Categories' : 'Subcategories')),
        automaticallyImplyLeading: !isRoot,
        actions: isRoot
            ? [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookmarksScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () async {
                    // Navigate to settings and wait for result
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                    // When returning from settings, reload with new language
                    debugPrint(
                        'Returning from settings screen, reloading data...');
                    _loadLanguagePreferenceAndData();
                  },
                ),
              ]
            : null,
      ),
      body: Container(
        color: AppTheme.creamWhite,
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading categories...'),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _loadLanguagePreferenceAndData();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No categories found'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _loadLanguagePreferenceAndData();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final hasChildren = item['HasChildren'] == 1;
                          final displayText = _getDisplayText(item);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: AppTheme.primaryGold
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text(
                                  displayText,
                                  style: const TextStyle(
                                    color: AppTheme.darkGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: hasChildren
                                    ? const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: AppTheme.primaryGold,
                                      )
                                    : Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.primaryGreen
                                            .withValues(alpha: 0.4),
                                      ),
                                onTap: () {
                                  if (isRoot) {
                                    final catId = item['Id'] as int;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategoriesScreen(
                                          categoryId: catId,
                                          parentId: catId,
                                          level: 0,
                                          title: displayText,
                                        ),
                                      ),
                                    );
                                  } else if (hasChildren) {
                                    final nextParent = item['Id'] as int;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategoriesScreen(
                                          categoryId: widget.categoryId,
                                          parentId: nextParent,
                                          level: widget.level + 1,
                                          title: displayText,
                                        ),
                                      ),
                                    );
                                  } else {
                                    _navigateToDetailScreen(
                                        item['Id'] as int, displayText);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
