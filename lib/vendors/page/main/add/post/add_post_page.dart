// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:Localsearch/vendors/page/main/add/post/add_status_page.dart';
// import 'package:Localsearch/vendors/page/main/add/post/add_text_post_page.dart';
// import 'package:Localsearch/vendors/utils/colors.dart';
// import 'package:Localsearch/widgets/button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:Localsearch/widgets/image_pick_dialog.dart';
// import 'package:Localsearch/widgets/snack_bar.dart';

// class AddPostPage extends StatefulWidget {
//   const AddPostPage({super.key});

//   @override
//   State<AddPostPage> createState() => _AddPostPageState();
// }

// class _AddPostPageState extends State<AddPostPage> {
//   final auth = FirebaseAuth.instance;
//   final store = FirebaseFirestore.instance;
//   bool isFit = false;
//   int currentImageIndex = 0;
//   bool isPosting = false;
//   int textPostRemaining = 0;
//   int imagePostRemaining = 0;

//   // INIT STATE
//   @override
//   void initState() {
//     getNoOfPosts();
//     super.initState();
//   }

//   // GET NO OF POSTS
//   Future<void> getNoOfPosts() async {
//     final productData = await store
//         .collection('Business')
//         .doc('Owners')
//         .collection('Shops')
//         .doc(auth.currentUser!.uid)
//         .get();

//     setState(() {
//       textPostRemaining = productData['noOfTextPosts'];
//       imagePostRemaining = productData['noOfImagePosts'];
//     });
//   }

//   // SELECT IMAGE
//   Future<void> selectImage() async {
//     final XFile im = await showImagePickDialog(context);
//     if (im != null) {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => AddStatusPage(),
//         ),
//       );
//     } else {
//       if (mounted) {
//         mySnackBar(context, 'Select an Image');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: const Text(
//           'CREATE POST',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         bottom: PreferredSize(
//           preferredSize:
//               isPosting ? const Size(double.infinity, 10) : const Size(0, 0),
//           child: isPosting ? const LinearProgressIndicator() : Container(),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: ((context, constraints) {
//           double width = constraints.maxWidth;

//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: width * 0.9,
//                 height: width * 0.2,
//                 margin: EdgeInsets.symmetric(vertical: width * 0.05),
//                 decoration: BoxDecoration(
//                   color: primary2.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Remaining Text Post - $textPostRemaining',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: primaryDark,
//                         fontWeight: FontWeight.w500,
//                         fontSize: width * 0.05,
//                       ),
//                     ),
//                     Text(
//                       'Remaining Image Post - $imagePostRemaining',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: primaryDark,
//                         fontWeight: FontWeight.w500,
//                         fontSize: width * 0.05,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               textPostRemaining > 0 || imagePostRemaining > 0
//                   ? Column(
//                       children: [
//                         Text(
//                           'Select the type of post you want to create',
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: primaryDark,
//                             fontSize: width * 0.045,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         // Text(
//                         //   'Just select the product you want the post',
//                         //   maxLines: 2,
//                         //   overflow: TextOverflow.ellipsis,
//                         //   textAlign: TextAlign.center,
//                         //   style: TextStyle(
//                         //     color: primaryDark,
//                         //     fontSize: width * 0.045,
//                         //     fontWeight: FontWeight.w500,
//                         //   ),
//                         // ),
//                         // Text(
//                         //   'Then the product details will automatically be added',
//                         //   maxLines: 2,
//                         //   overflow: TextOverflow.ellipsis,
//                         //   textAlign: TextAlign.center,
//                         //   style: TextStyle(
//                         //     color: primaryDark,
//                         //     fontSize: width * 0.045,
//                         //     fontWeight: FontWeight.w500,
//                         //   ),
//                         // ),
//                       ],
//                     )
//                   : Text(
//                       'Your no of Text & Image Posts has reached 0\nYou cannot post another post until your current membership ends',
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: primaryDark,
//                         fontSize: width * 0.045,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//               SizedBox(height: width * 0.055),
//               Opacity(
//                 opacity: textPostRemaining > 0 ? 1 : 0.5,
//                 child: MyButton(
//                   text: 'TEXT POST',
//                   onTap: textPostRemaining > 0
//                       ? () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => AddTextPostPage(
//                                 textPostRemaining: textPostRemaining,
//                               ),
//                             ),
//                           );
//                         }
//                       : null,
//                   isLoading: false,
//                   horizontalPadding: width * 0.055,
//                 ),
//               ),
//               SizedBox(height: width * 0.055),
//               Opacity(
//                 opacity: imagePostRemaining > 0 ? 1 : 0.5,
//                 child: MyButton(
//                   text: 'IMAGE POST',
//                   onTap: imagePostRemaining > 0
//                       ? () async {
//                           await selectImage();
//                         }
//                       : null,
//                   isLoading: false,
//                   horizontalPadding: width * 0.055,
//                 ),
//               ),
//               // SizedBox(height: width * 0.055),
//               // Opacity(
//               //   opacity: textPostRemaining > 0 ? 1 : 0.5,
//               //   child: MyButton(
//               //     text: 'TEXT POST (Linked With Product)',
//               //     onTap: textPostRemaining > 0
//               //         ? () {
//               //             Navigator.of(context).push(
//               //               MaterialPageRoute(
//               //                 builder: ((context) => SelectProductForPostPage(
//               //                       isTextPost: true,
//               //                       textPostRemaining: textPostRemaining,
//               //                       imagePostRemaining: imagePostRemaining,
//               //                     )),
//               //               ),
//               //             );
//               //           }
//               //         : null,
//               //     isLoading: false,
//               //     horizontalPadding: width * 0.055,
//               //   ),
//               // ),
//               // SizedBox(height: width * 0.055),
//               // Opacity(
//               //   opacity: imagePostRemaining > 0 ? 1 : 0.5,
//               //   child: MyButton(
//               //     text: 'IMAGE POST (Linked With Product)',
//               //     onTap: imagePostRemaining > 0
//               //         ? () {
//               //             Navigator.of(context).push(
//               //               MaterialPageRoute(
//               //                 builder: ((context) => SelectProductForPostPage(
//               //                       isTextPost: false,
//               //                       textPostRemaining: textPostRemaining,
//               //                       imagePostRemaining: imagePostRemaining,
//               //                     )),
//               //               ),
//               //             );
//               //           }
//               //         : null,
//               //     isLoading: false,
//               //     horizontalPadding: width * 0.055,
//               //   ),
//               // ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
