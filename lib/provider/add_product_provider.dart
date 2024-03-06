import 'package:flutter/material.dart';

class AddProductProvider with ChangeNotifier {
  Map<String, dynamic> _productInfo = {};

  Map<String, dynamic> get productInfo => _productInfo;

  void add(Map<String, dynamic> info, bool isAdding) {
    isAdding ? _productInfo.addAll(info) : _productInfo = info;
  }

  void remove(String name) {
    _productInfo.remove(name);
  }
}
