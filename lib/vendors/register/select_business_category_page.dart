// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:localy/vendors/models/business_special_categories_images.dart';
// import 'package:localy/vendors/models/household_special_categories_images.dart';
// import 'package:localy/vendors/register/business_timings_page.dart';
// import 'package:localy/vendors/utils/colors.dart';
// import 'package:localy/widgets/button.dart';
// import 'package:localy/widgets/head_text.dart';
// import 'package:localy/widgets/image_container.dart';
// import 'package:localy/widgets/image_text_container.dart';
// import 'package:localy/widgets/snack_bar.dart';
// import 'package:localy/widgets/text_form_field.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SelectBusinessCategoryPage extends StatefulWidget {
//   const SelectBusinessCategoryPage({super.key});

//   @override
//   State<SelectBusinessCategoryPage> createState() =>
//       _SelectBusinessCategoryPageState();
// }

// class _SelectBusinessCategoryPageState
//     extends State<SelectBusinessCategoryPage> {
//   final auth = FirebaseAuth.instance;
//   final store = FirebaseFirestore.instance;
//   final otherCategoryController = TextEditingController();
//   bool isShop = true;
//   bool isSaving = false;

//   // DISPOSE
//   @override
//   void dispose() {
//     otherCategoryController.dispose();
//     super.dispose();
//   }

//   // SHOW ALL CATEGORY
//   Future<void> showCategoryDialog() async {
//     await showDialog(
//       context: context,
//       builder: ((context) => ImageContainer(
//             isShop: isShop,
//           )),
//     );
//     setState(() {});
//   }

//   // UPLOAD DETAILS
//   Future<void> uploadDetails() async {
//     if (selectedCategories != 'Select Category') {
//       if (selectedCategories == 'Other' &&
//           otherCategoryController.text.isEmpty) {
//         return mySnackBar(context, 'Enter Name of Category');
//       } else {
//         try {
//           await store
//               .collection('Business')
//               .doc('Owners')
//               .collection('Shops')
//               .doc(auth.currentUser!.uid)
//               .update({
//             'Type': selectedCategories,
//           });

//           Map<String, String> subCategories = isShop
//               ? businessSpecialCategories[selectedCategories]!
//               : householdSpecialCategories[selectedCategories]!;


//           for (specialCategory)
//           final specialCategoriesCollection = store
//               .collection('Business')
//               .doc('Special Categories')
//               .collection(selectedCategories);

//           subCategories.forEach((subcategoryName, imageUrl) async {
//             await specialCategoriesCollection.doc(subcategoryName).set({
//               'specialCategoryName': subcategoryName,
//               'specialCategoryImageUrl': imageUrl,
//               'vendorId': [auth.currentUser!.uid],
//             });
//           });

//           if (mounted) {
//             Navigator.of(context).pop();
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                   builder: (context) => const SelectBusinessTimingsPage()),
//             );
//           }
//         } catch (e) {
//           if (mounted) {
//             return mySnackBar(context, e.toString());
//           }
//         }
//       }
//     } else {
//       if (mounted) {
//         return mySnackBar(context, 'Select Category');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final width = constraints.maxWidth;

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: width * 0.025,
//                   vertical: width * 0.0125,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // HEAD TEXT
//                     SizedBox(height: width * 0.1125),
//                     const HeadText(
//                       text: 'SELECT\nCATEGORY',
//                     ),
//                     SizedBox(height: width * 0.1125),

//                     // SHOP VS HOUSEHOLD
//                     Container(
//                       width: width,
//                       height: 130,
//                       decoration: BoxDecoration(
//                         color: primary2.withOpacity(0.75),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           // SHOP
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 isShop = true;
//                                 selectedCategories = 'Select Category';
//                               });
//                             },
//                             child: SizedBox(
//                               width: width,
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.025,
//                                   vertical: 4,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Shop',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: primaryDark,
//                                         fontSize: width * 0.06,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     Checkbox(
//                                       activeColor: primaryDark,
//                                       checkColor: white,
//                                       value: isShop,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           isShop = value!;
//                                         });
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Divider(),

//                           // HOUSEHOLD
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 isShop = false;
//                                 selectedCategories = 'Select Category';
//                               });
//                             },
//                             child: SizedBox(
//                               width: width,
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.025,
//                                   vertical: 4,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Household',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: primaryDark,
//                                         fontSize: width * 0.06,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     Checkbox(
//                                       activeColor: primaryDark,
//                                       checkColor: white,
//                                       value: !isShop,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           isShop = !value!;
//                                         });
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: width * 0.025),

//                     // SELECT CATEGORY BUTTON
//                     GestureDetector(
//                       onTap: () async {
//                         await showCategoryDialog();
//                       },
//                       child: Container(
//                         width: width,
//                         height: width * 0.15,
//                         margin: EdgeInsets.symmetric(
//                           vertical: width * 0.05,
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           vertical: width * 0.025,
//                         ),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: primary2,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           selectedCategories,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: primaryDark,
//                             fontSize: width * 0.06,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: width * 0.025),

//                     // OTHER CATEGORY TEXTFORMFIELD
//                     selectedCategories == 'Other'
//                         ? MyTextFormField(
//                             hintText: 'Other Category Name',
//                             controller: otherCategoryController,
//                             borderRadius: 12,
//                             horizontalPadding: 0,
//                             autoFillHints: null,
//                           )
//                         : Container(),
//                     SizedBox(height: width * 0.025),

//                     // NEXT BUTTON
//                     Padding(
//                       padding: EdgeInsets.only(
//                         top: width * 0.0225,
//                         bottom: MediaQuery.of(context).viewInsets.bottom,
//                       ),
//                       child: SizedBox(
//                         width: width,
//                         height: width * 0.15,
//                         child: MyButton(
//                           text: 'NEXT',
//                           onTap: () async {
//                             await uploadDetails();
//                           },
//                           isLoading: isSaving,
//                           horizontalPadding: 0,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
