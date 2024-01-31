import 'package:flutter/material.dart';

class ChangeCategoryProvider with ChangeNotifier {
  List<String> _selectedCategory = [];

  List<String> get selectedCategory => _selectedCategory;

  void changeCategory(String id, String categoryName) {
    if (_selectedCategory.contains(id)) {
      _selectedCategory = [];
    } else {
      _selectedCategory.clear();
      _selectedCategory = [id, categoryName];
    }

    notifyListeners();
  }
}
