// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:Localsearch/vendors/utils/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class HeadText extends StatelessWidget {
//   const HeadText({
//     super.key,
//     required this.text,
//   });
//   final String text;

//   String textFormat(String text) {
//     int length = text.length;
//     String formattedText = '';
//     for (var i = 0; i < length; i++) {
//       formattedText += '${text[i]} ';
//     }
//     return formattedText;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AutoSizeText(
//       textFormat(text),
//       textAlign: TextAlign.center,
//       maxLines: 2,
//       overflow: TextOverflow.ellipsis,
//       style: GoogleFonts.josefinSans(
//         fontSize: MediaQuery.of(context).size.width * 0.085,
//         color: primaryDark,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
// }
