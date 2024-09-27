// import 'package:flutter/material.dart';

// class SelectBrandForProductProvider with ChangeNotifier {
//   String _selectedBrandId = '0';
//   String _selectedBrandName = 'No Brand';

//   String? get selectedBrandName => _selectedBrandName;
//   String? get selectedBrandId => _selectedBrandId;

//   void selectBrand(String name, String id) {
//     if (_selectedBrandId == id) {
//       _selectedBrandName = 'No Brand';
//       _selectedBrandId = '0';
//     } else {
//       _selectedBrandName = name;
//       _selectedBrandId = id;
//     }

//     notifyListeners();
//   }

//   void clear() {
//     _selectedBrandId = '0';
//     _selectedBrandName = 'No Brand';
//   }
// }
