// import 'package:ls_business/vendors/models/business_categories.dart';
// import 'package:ls_business/vendors/models/household_categories.dart';
// import 'package:ls_business/widgets/image_text_container.dart';
// import 'package:flutter/material.dart';

// class ImageContainer extends StatelessWidget {
//   const ImageContainer({
//     super.key,
//     required this.isShop,
//   });

//   final bool isShop;

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: const RoundedRectangleBorder(),
//       child: GridView.builder(
//         itemCount: businessCategories.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 515 / 500,
//         ),
//         itemBuilder: ((context, index) {
//           return ImageTextContainer(
//             imageUrl: isShop
//                 ? businessCategories[index][1]
//                 : householdCategories[index]![1],
//             text: isShop
//                 ? businessCategories[index][0]
//                 : householdCategories[index]![0],
//           );
//         }),
//       ),
//     );
//   }
// }
