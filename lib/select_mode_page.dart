// import 'package:ls_business/auth/login_page.dart';
// import 'package:ls_business/widgets/button.dart';
// import 'package:ls_business/widgets/mode_card.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SelectModePage extends StatefulWidget {
//   const SelectModePage({super.key});

//   @override
//   State<SelectModePage> createState() => _SelectModePageState();
// }

// class _SelectModePageState extends State<SelectModePage> {
//   bool isVendorSelected = false;
//   bool isServicesSelected = false;
//   bool isEventsSelected = false;

//   // SET VENDOR SELECTED
//   void setVendorSelected() {
//     setState(() {
//       isVendorSelected = true;
//       isServicesSelected = false;
//       isEventsSelected = false;
//     });
//   }

//   // SET SERVICES SELECTED
//   void setServicesSelected() {
//     setState(() {
//       isVendorSelected = false;
//       isServicesSelected = true;
//       isEventsSelected = false;
//     });
//   }

//   // SET EVENTS SELECTED
//   void setEventsSelected() {
//     setState(() {
//       isVendorSelected = false;
//       isServicesSelected = false;
//       isEventsSelected = true;
//     });
//   }

//   // SET SELECTED TEXT
//   Future<void> saveSelectedText() async {
//     String text = '';
//     if (isVendorSelected) {
//       text = 'vendor';
//     } else if (isServicesSelected) {
//       text = 'services';
//     } else if (isEventsSelected) {
//       text = 'events';
//     } else {
//       return;
//     }
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selectedText', text);
//     if (isVendorSelected) {
//       if (mounted) {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => const LoginPage(
//                   mode: 'vendor',
//                 ),
//           ),
//         );
//       }
//     } else if (isServicesSelected) {
//       if (mounted) {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => const LoginPage(
//                   mode: 'services',
//                 ),
//           ),
//         );
//       }
//     } else if (isEventsSelected) {
//       if (mounted) {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => const LoginPage(
//                   mode: 'events',
//                 ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.sizeOf(context).width;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Mode'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // VENDOR
//             ModeCard(
//               isSelected: isVendorSelected,
//               name: 'Vendor',
//               onTap: setVendorSelected,
//               selectedTextColor: const Color.fromARGB(255, 210, 14, 0),
//               selectedBackgroundColor: const Color.fromARGB(255, 255, 238, 237),
//             ),

//             // SERVICES
//             ModeCard(
//               isSelected: isServicesSelected,
//               name: 'Services',
//               onTap: setServicesSelected,
//               selectedTextColor: const Color.fromARGB(255, 0, 122, 4),
//               selectedBackgroundColor: const Color.fromARGB(255, 240, 255, 240),
//             ),
//             // EVENTS
//             ModeCard(
//               isSelected: isEventsSelected,
//               name: 'Events',
//               onTap: setEventsSelected,
//               selectedTextColor: const Color.fromARGB(255, 0, 131, 225),
//               selectedBackgroundColor: const Color.fromARGB(255, 236, 247, 255),
//             ),

//             const SizedBox(height: 40),

//             // NEXT
//             MyButton(
//               text: 'NEXT',
//               onTap: isVendorSelected || isServicesSelected || isEventsSelected
//                   ? saveSelectedText
//                   : null,
//               isLoading: false,
//               horizontalPadding: width * 0.1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
