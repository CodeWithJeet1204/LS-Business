import 'package:flutter/material.dart';

class SelectBrandForDiscountProvider with ChangeNotifier {
  List<String> _selectedBrands = [];

  List<String> get selectedBrands => _selectedBrands;

  void selectBrands(String id) {
    if (_selectedBrands.contains(id)) {
      _selectedBrands.remove(id);
    } else {
      _selectedBrands.add(id);
    }

    notifyListeners();
  }

  void clear() {
    _selectedBrands = [];
  }
}
