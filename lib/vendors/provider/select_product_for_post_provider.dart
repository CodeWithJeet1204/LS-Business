// import 'package:ls_business/widgets/snack_bar.dart';
// import 'package:flutter/material.dart';

// class SelectProductForPostProvider with ChangeNotifier {
//   List<String> _selectedProducts = [];

//   List<String> get selectedProducts => _selectedProducts;

//   void addSelectedProduct(
//       String id, int length, bool isTextPost, BuildContext context) {
//     if (_selectedProducts.contains(id)) {
//       _selectedProducts.remove(id);
//     } else {
//       if (_selectedProducts.length < length) {
//         _selectedProducts.add(id);
//       } else {
//         mySnackBar(
//           context,
//           'You have reached the limit of remaining ${isTextPost ? 'Text' : 'Image'} Posts Remaining',
//         );
//       }
//     }

//     notifyListeners();
//   }

//   void clear() {
//     _selectedProducts = [];
//   }

//   // ---

//   bool? isTextPost;

//   void changePostType(bool isText) {
//     isTextPost = isText;

//     notifyListeners();
//   }
// }
