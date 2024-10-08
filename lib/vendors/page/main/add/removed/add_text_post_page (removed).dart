// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:ls_business/vendors/utils/colors.dart';
// import 'package:ls_business/widgets/my_button.dart';
// import 'package:ls_business/widgets/snack_bar.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:uuid/uuid.dart';
// import 'package:ls_business/widgets/video_tutorial.dart';

// class AddTextPostPage extends StatefulWidget {
//   const AddTextPostPage({
//     super.key,
//     required this.textPostRemaining,
//   });

//   final int textPostRemaining;

//   @override
//   State<AddTextPostPage> createState() => _AddTextPostPageState();
// }

// class _AddTextPostPageState extends State<AddTextPostPage> {
//   final auth = FirebaseAuth.instance;
//   final store = FirebaseFirestore.instance;
//   final postKey = GlobalKey<FormState>();
//   final postController = TextEditingController();
//   bool isPosting = false;
//   bool isDialog = false;

//   // POST
//   Future<void> post() async {
//     if (postKey.currentState!.validate()) {
//       setState(() {
//         isPosting = true;
//         isDialog = true;
//       });

//       try {
//         final String postId = const Uuid().v4();

//         Map<String, dynamic> postInfo = {
//           'postText': postController.text,
//           'postId': postId,
//           'postVendorId': auth.currentUser!.uid,
//           'postViews': 0,
//           'postLikes': 0,
//           'postImages': null,
//           'postComments': {},
//           'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
//             DateTime.now().millisecondsSinceEpoch,
//           ),
//           'isTextPost': true,
//         };

//         await store
//             .collection('Business')
//             .doc('Owners')
//             .collection('Shops')
//             .doc(auth.currentUser!.uid)
//             .update({
//           'noOfTextPosts': widget.textPostRemaining - 1,
//         });

//         await store
//             .collection('Business')
//             .doc('Data')
//             .collection('Posts')
//             .doc(postId)
//             .set(postInfo);

//         setState(() {
//           isPosting = false;
//           isDialog = false;
//         });

//         if (mounted) {
//           mySnackBar(context, 'Posted');
//           Navigator.of(context).pop();
//           Navigator.of(context).pop();
//         }
//       } catch (e) {
//         setState(() {
//           isPosting = false;
//           isDialog = false;
//         });
//         if (mounted) {
//           mySnackBar(context, e.toString());
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: isDialog ? false : true,
//       child: ModalProgressHUD(
//         inAsyncCall: isDialog,
//         color: primaryDark,
//         blur: 0.5,
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Add Text Post'),
//             actions: [
//               IconButton(
//                 onPressed: () async {
//                   await showYouTubePlayerDialog(
//                     context,
//                     getYoutubeVideoId(
//                       '',
//                     ),
//                   );
//                 },
//                 icon: const Icon(
//                   Icons.question_mark_outlined,
//                 ),
//                 tooltip: 'Help',
//               ),
//             ],
//           ),
//           body: SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 final width = constraints.maxWidth;

//                 return SingleChildScrollView(
//                   child: Form(
//                     key: postKey,
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: width,
//                           child: Padding(
//                             padding: EdgeInsets.all(width * 0.0225),
//                             child: TextFormField(
//                               autofocus: true,
//                               controller: postController,
//                               minLines: 1,
//                               maxLines: 10,
//                               maxLength: 1000,
//                               onTapOutside: (event) =>
//                                   FocusScope.of(context).unfocus(),
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(4),
//                                   borderSide: BorderSide(
//                                     color: Colors.cyan.shade700,
//                                   ),
//                                 ),
//                                 hintText: 'Post...',
//                               ),
//                               validator: (value) {
//                                 if (value != null) {
//                                   if (value.isNotEmpty) {
//                                     return null;
//                                   } else {
//                                     return 'Pls enter something';
//                                   }
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                         ),

//                         // DONE
//                         MyButton(
//                           text: 'DONE',
//                           onTap: () async {
//                             await post();
//                           },
//                           horizontalPadding: width * 0.0225,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
