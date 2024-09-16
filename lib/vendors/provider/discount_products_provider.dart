import 'package:flutter/material.dart';

class SelectProductForDiscountProvider with ChangeNotifier {
  List<String> _selectedProducts = [];

  List<String> get selectedProducts => _selectedProducts;

  void selectProduct(
    String id,
    BuildContext context,
  ) {
    if (_selectedProducts.contains(id)) {
      _selectedProducts.remove(id);
    } else {
      _selectedProducts.add(id);
    }

    notifyListeners();
  }

  void clear() {
    _selectedProducts = [];
  }
}
