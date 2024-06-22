import 'package:flutter/material.dart';

class SelectCategoryForDiscountProvider with ChangeNotifier {
  List<String> _selectedCategories = [];

  List<String> get selectedCategories => _selectedCategories;

  void selectCategory(String name) {
    if (_selectedCategories.contains(name)) {
      _selectedCategories.remove(name);
    } else {
      _selectedCategories.add(name);
    }

    notifyListeners();
  }

  void clear() {
    _selectedCategories = [];

    notifyListeners();
  }
}
