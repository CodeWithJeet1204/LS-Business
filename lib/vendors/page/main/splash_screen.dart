// import 'package:ls_business/auth/register_method_page.dart';
// import 'package:ls_business/vendors/page/main/main_page.dart';
// import 'package:ls_business/vendors/utils/colors.dart';
// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({
//     super.key,
//     required this.isLoggedIn,
//   });

//   final bool isLoggedIn;

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(
//       const Duration(milliseconds: 1500),
//       () {
//         if (mounted) {

//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: ((context) => widget.isLoggedIn
//                 ? const MainPage()
//                 : const RegisterMethodPage(
//                     // mode: 'vendor',
//                     )),
//           ),
//         );
//         }
//       },
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         alignment: Alignment.center,
//         decoration: const BoxDecoration(
//           gradient: RadialGradient(
//             colors: [
//               primary,
//               primary2,
//             ],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'files/ls_business Transparent.png',
//               width: width * 0.5,
//             ),
//             SizedBox(height: width * 0.25),
//             Text(
//               'ls_business',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: primaryDark2,
//                 fontSize: width * 0.08875,
//                 fontWeight: FontWeight.w700,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
