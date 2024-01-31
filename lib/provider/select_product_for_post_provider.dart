import 'package:flutter/material.dart';

class SelectProductForPostProvider with ChangeNotifier {
  List<String> _selectedProduct = [];

  List<String> get selectedProduct => _selectedProduct;

  void changeSelectedProduct(String id, String name) {
    if (_selectedProduct.contains(id)) {
      _selectedProduct = [];
    } else {
      _selectedProduct = [];
      _selectedProduct = [id, name];
    }

    notifyListeners();
  }

  void clear() {
    _selectedProduct = [];
  }

  // ---

  bool? isTextPost;

  void changePostType(bool isText) {
    isTextPost = isText;

    notifyListeners();
  }
}
