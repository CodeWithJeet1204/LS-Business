import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final Map<String, Map<String, String>> _category = {};

  Map<String, Map<String, String>> get getCategory {
    return _category;
  }

  void addNewCategory(
    String categoryName,
    String categoryId,
    String imageUrl,
  ) {
    _category.putIfAbsent(
      categoryId,
      () => {
        'categoryName': categoryName,
        'categoryId': categoryId,
        'imageUrl': imageUrl,
      },
    );
    notifyListeners();
  }
}
