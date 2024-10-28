// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:feather_icons/feather_icons.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:ls_business/vendors/page/main/add/post/add_post_page.dart';
// import 'package:ls_business/vendors/page/main/add/status/add_status_page.dart';
// import 'package:ls_business/widgets/add_box.dart';

// class SharePage extends StatefulWidget {
//   const SharePage({
//     super.key,
//     required this.imagePaths,
//   });

//   final List<String> imagePaths;

//   @override
//   State<SharePage> createState() => _SharePageState();
// }

// class _SharePageState extends State<SharePage> {
//   final auth = FirebaseAuth.instance;
//   final store = FirebaseFirestore.instance;
//   bool? isRegistration;

//   // INIT STATE
//   @override
//   void initState() {
//     getVendorData();
//     super.initState();
//   }

//   // GET VENDOR DATA
//   Future<void> getVendorData() async {
//     final vendorSnap = await store
//         .collection('Business')
//         .doc('Owners')
//         .collection('Shops')
//         .doc(auth.currentUser!.uid)
//         .get();

//     final vendorData = vendorSnap.data()!;

//     final membershipName = vendorData['MembershipName'];

//     setState(() {
//       if (membershipName == 'Registration') {
//         isRegistration = true;
//       } else {
//         isRegistration = false;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Share To'),
//       ),
//       body: SafeArea(
//         child: isRegistration == null
//             ? Center(
//                 child: CircularProgressIndicator(),
//               )
//             : LayoutBuilder(
//                 builder: (context, constraints) {
//                   final width = constraints.maxWidth;

//                   return SingleChildScrollView(
//                     child: isRegistration != null && isRegistration!
//                         ? Center(
//                             child: SizedBox(
//                               height: 80,
//                               child: Text(
//                                 'Your current membership does not support to add Posts',
//                               ),
//                             ),
//                           )
//                         : Column(
//                             children: [
//                               // POST
//                               AddBox(
//                                 context: context,
//                                 width: width,
//                                 icon: FeatherIcons.compass,
//                                 label: 'POST',
//                                 page: AddPostPage(
//                                   imagePaths: widget.imagePaths,
//                                 ),
//                               ),

//                               // STATUS
//                               AddBox(
//                                 context: context,
//                                 width: width,
//                                 icon: FeatherIcons.upload,
//                                 label: 'STATUS',
//                                 page: AddStatusPage(
//                                   imagePaths: widget.imagePaths,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }
