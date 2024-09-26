// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class MyPageView extends StatelessWidget {
//   const MyPageView({
//     super.key,
//     required this.text,
//     required this.animation,
//     required this.textColor,
//     required this.backgroundColor,
//     this.fontSize = 18,
//   });

//   final String text;
//   final String animation;
//   final Color textColor;
//   final Color backgroundColor;
//   final double fontSize;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: backgroundColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Lottie.network(
//                 animation,
//                 reverse: false,
//                 height: 400,
//                 width: 300,
//               ),
//             ),
//             const SizedBox(height: 36),
//             Text(
//               text,
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: fontSize,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
