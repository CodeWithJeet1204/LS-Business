import 'package:flutter/material.dart';

class ChangeCategoryProvider with ChangeNotifier {
  String _selectedCategory = '';

  String get selectedCategory => _selectedCategory;

  void changeCategory(String id) {
    if (_selectedCategory == id) {
      _selectedCategory = '';
    } else {
      _selectedCategory = id;
    }

    notifyListeners();
  }

  void clear() {
    _selectedCategory = '';

    notifyListeners();
  }
}
