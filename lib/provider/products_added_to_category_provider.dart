import 'package:flutter/material.dart';

class ProductAddedToCategory with ChangeNotifier {
  List<String> _selectedProducts = [];

  List<String> get selectedProducts => _selectedProducts;

  void addProduct(String productId) {
    if (_selectedProducts.contains(productId)) {
      _selectedProducts.remove(productId);
    } else {
      _selectedProducts.add(productId);
    }

    notifyListeners();
  }

  void clearProducts() {
    _selectedProducts.clear();
    notifyListeners();
  }
}
