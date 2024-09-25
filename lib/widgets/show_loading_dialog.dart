// import 'package:flutter/material.dart';

// Future<void> showLoadingDialog(
//   BuildContext context,
//   Future<void> Function() action,
// ) async {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return const PopScope(
//         canPop: false,
//         child: Dialog(
//           child: SizedBox.square(
//             dimension: 100,
//             child: Center(
//               child: CircularProgressIndicator(),
//             ),
//           ),
//         ),
//       );
//     },
//   );

//   await action();
//   if (Navigator.of(context).canPop()) {
//     Navigator.of(context).pop();
//   }
//   return;
// }
