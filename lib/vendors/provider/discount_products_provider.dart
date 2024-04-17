import 'package:find_easy/widgets/snack_bar.dart';
import 'package:flutter/material.dart';

class SelectProductForDiscountProvider with ChangeNotifier {
  List<String> _selectedProducts = [];

  List<String> get selectedProducts => _selectedProducts;

  void selectProduct(
    String id,
    dynamic price,
    BuildContext context,
  ) {
    if (price == '') {
      mySnackBar(context, "Product with no price cannot be selected");
    } else {
      if (_selectedProducts.contains(id)) {
        _selectedProducts.remove(id);
      } else {
        _selectedProducts.add(id);
      }
    }

    notifyListeners();
  }

  void clear() {
    _selectedProducts = [];
  }
}
