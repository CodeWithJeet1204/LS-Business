import 'package:flutter/material.dart';

class SelectCategoryForDiscountProvider with ChangeNotifier {
  List<String> _selectedCategories = [];

  List<String> get selectedCategories => _selectedCategories;

  void selectCategory(String id) {
    if (_selectedCategories.contains(id)) {
      _selectedCategories.remove(id);
    } else {
      _selectedCategories.add(id);
    }

    notifyListeners();
  }

  void clear() {
    _selectedCategories = [];
  }
}
