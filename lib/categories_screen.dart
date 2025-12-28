import 'package:flutter/material.dart';
import 'package:raazoneyaz/detail_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    if (widget.categoryId == 0) {
      _fetchCategories();
    } else {
      _fetchSubcategories();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final result = await _dbHelper.getCategories();
      debugPrint('Fetched categories: $result');
      setState(() {
        items = result;
      });
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      _showErrorSnackBar('Failed to load categories.');
    }
  }

  Future<void> _fetchSubcategories() async {
    try {
      final result = await _dbHelper.getSubcategories(
          widget.categoryId, widget.parentId, widget.level);
      debugPrint(
          'Fetched subcategories (CategoryId=${widget.categoryId}, ParentId=${widget.parentId}, Level=${widget.level}): $result');
      setState(() {
        items = result;
      });
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      _showErrorSnackBar('Failed to load subcategories.');
    }
  }

  Future<void> _navigateToDetailScreen(int subIndexId, String title) async {
    try {
      debugPrint(
          'Navigating to detail screen for subIndexId=$subIndexId, title=$title');
      final lines = await _dbHelper.getLinesForSubindex(subIndexId);
      debugPrint('Fetched ${lines.length} lines for subIndexId=$subIndexId');
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
        SnackBar(content: Text(message)),
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
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final hasChildren = item['HasChildren'] == 1;
                final displayText =
                    item['EnglishIndexName'] ?? item['EnglishName'] ?? '';
                return ListTile(
                  title: Text(displayText),
                  trailing: hasChildren ? Icon(Icons.arrow_forward) : null,
                  onTap: () {
                    if (isRoot) {
                      // tapped a top-level category
                      final catId = item['Id'] as int;
                      debugPrint(
                          'Tapped top-level category: CategoryId=$catId, title=$displayText');
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
                      // deeper level
                      final nextParent = item['Id'] as int;
                      debugPrint(
                          'Tapped subcategory: CategoryId=${widget.categoryId}, ParentId=$nextParent, Level=${widget.level + 1}, title=$displayText');
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
                      // no children, navigate to detail
                      debugPrint(
                          'Tapped leaf item: Id=${item['Id']}, title=$displayText');
                      _navigateToDetailScreen(item['Id'] as int, displayText);
                    }
                  },
                );
              },
            ),
    );
  }
}
