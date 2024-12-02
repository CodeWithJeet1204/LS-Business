import 'package:flutter/material.dart';

class ProductChangeCategoryProvider with ChangeNotifier {
  Map<String, dynamic> _categoryInfo = {};

  Map<String, dynamic> get categoryInfo => _categoryInfo;

  void add(Map<String, dynamic> info, bool isAdding) {
    isAdding ? _categoryInfo.addAll(info) : _categoryInfo = info;

    notifyListeners();
  }
}
