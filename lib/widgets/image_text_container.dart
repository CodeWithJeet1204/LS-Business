// import 'package:localy/vendors/utils/colors.dart';
// import 'package:flutter/material.dart';

// class ImageTextContainer extends StatefulWidget {
//   const ImageTextContainer({
//     super.key,
//     required this.imageUrl,
//     required this.text,
//   });

//   final String text;
//   final String imageUrl;

//   @override
//   State<ImageTextContainer> createState() => _ImageTextContainerState();
// }

// void selectCategory(text) {
//   selectedCategories = text;
// }

// List selectedCategories = [];

// class _ImageTextContainerState extends State<ImageTextContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: GestureDetector(
//         onTap: () {
//           selectCategory(widget.text);
//           Navigator.of(context).pop();
//         },
//         child: SizedBox(
//           height: double.infinity,
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: primary2,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(11),
//                   child: Image.network(
//                     widget.imageUrl,
//                     width: double.infinity,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(2),
//                   child: Text(
//                     widget.text,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       color: primaryDark,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
