// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:feather_icons/feather_icons.dart';
// import 'package:Localsearch/vendors/provider/change_category_provider.dart';
// import 'package:Localsearch/vendors/utils/colors.dart';
// import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
// import 'package:Localsearch/widgets/snack_bar.dart';
// import 'package:Localsearch/widgets/text_button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SelectCategoryForBulkProductsPage extends StatefulWidget {
//   const SelectCategoryForBulkProductsPage({
//     super.key,
//   });

//   @override
//   State<SelectCategoryForBulkProductsPage> createState() =>
//       _SelectCategoryForBulkProductsPageState();
// }

// class _SelectCategoryForBulkProductsPageState
//     extends State<SelectCategoryForBulkProductsPage> {
//   final auth = FirebaseAuth.instance;
//   final store = FirebaseFirestore.instance;
//   final searchController = TextEditingController();
//   bool isGridView = true;
//   Map<String, dynamic> categories = {};
//   bool getData = false;

//   // INIT STATE
//   @override
//   void initState() {
//     getCommonCategories();
//     super.initState();
//   }

//   // DISPOSE
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   // GET COMMON CATEGORIES
//   Future<void> getCommonCategories() async {
//     final vendorSnap = await store
//         .collection('Business')
//         .doc('Owners')
//         .collection('Shops')
//         .doc(auth.currentUser!.uid)
//         .get();

//     final vendorData = vendorSnap.data()!;

//     final List shopTypes = vendorData['Type'];

//     Map<String, dynamic> myCategories = {};

//     for (var type in shopTypes) {
//       final categorySnap = await store
//           .collection('Business')
//           .doc('Special Categories')
//           .collection(type)
//           .get();

//       for (var category in categorySnap.docs) {
//         final categoryData = category.data();

//         final categoryName = categoryData['specialCategoryName'];
//         final imageUrl = categoryData['specialCategoryImageUrl'];

//         myCategories[categoryName] = imageUrl;
//       }
//     }

//     setState(() {
//       categories = myCategories;
//       getData = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final changeCategoryProvider = Provider.of<ChangeCategoryProvider>(context);

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: const Text(
//           'Select Category',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         actions: [
//           MyTextButton(
//             onPressed: () async {
//               if (changeCategoryProvider.selectedCategory != '') {
//                 if (context.mounted) {
//                   Navigator.of(context).pop(
//                     changeCategoryProvider.selectedCategory,
//                   );
//                   changeCategoryProvider.clear();
//                 }
//               } else {
//                 return mySnackBar(context, 'Select Category');
//               }
//             },
//             text: 'DONE',
//             textColor: primaryDark2,
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size(
//             double.infinity,
//             80,
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: MediaQuery.of(context).size.width * 0.0166,
//                   vertical: MediaQuery.of(context).size.width * 0.0225,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: searchController,
//                         autocorrect: false,
//                         onTapOutside: (event) =>
//                             FocusScope.of(context).unfocus(),
//                         decoration: const InputDecoration(
//                           hintText: 'Search ...',
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (value) {
//                           setState(() {});
//                         },
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           isGridView = !isGridView;
//                         });
//                       },
//                       icon: Icon(
//                         isGridView ? FeatherIcons.list : FeatherIcons.grid,
//                       ),
//                       tooltip: isGridView ? 'List View' : 'Grid View',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: ((context, constraints) {
//           final width = constraints.maxWidth;

//           return !getData
//               ? SafeArea(
//                   child: isGridView
//                       ? GridView.builder(
//                           shrinkWrap: true,
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 0,
//                             mainAxisSpacing: 0,
//                             childAspectRatio: width * 0.5 / width * 1.6,
//                           ),
//                           itemCount: 4,
//                           itemBuilder: (context, index) {
//                             return Padding(
//                               padding: EdgeInsets.all(
//                                 width * 0.02,
//                               ),
//                               child: GridViewSkeleton(
//                                 width: width,
//                                 isPrice: false,
//                               ),
//                             );
//                           },
//                         )
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: 4,
//                           itemBuilder: (context, index) {
//                             return Padding(
//                               padding: EdgeInsets.all(
//                                 width * 0.02,
//                               ),
//                               child: ListViewSkeleton(
//                                 width: width,
//                                 isPrice: false,
//                                 height: 30,
//                               ),
//                             );
//                           },
//                         ),
//                 )
//               : isGridView
//                   ? GridView.builder(
//                       shrinkWrap: true,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 0.75,
//                       ),
//                       itemCount: categories.length,
//                       itemBuilder: (context, index) {
//                         final name = categories.keys.toList()[index];
//                         final imageUrl = categories.values.toList()[index];

//                         return GestureDetector(
//                           onTap: () {
//                             changeCategoryProvider.changeCategory(name);
//                           },
//                           child: Stack(
//                             alignment: Alignment.topRight,
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: white,
//                                   border: Border.all(
//                                     width: 0.25,
//                                     color: primaryDark,
//                                   ),
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                                 margin: EdgeInsets.all(width * 0.00625),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     // IMAGE
//                                     Padding(
//                                       padding: EdgeInsets.all(
//                                         width * 0.00625,
//                                       ),
//                                       child: Center(
//                                         child: ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(2),
//                                           child: Image.network(
//                                             imageUrl,
//                                             height: width * 0.5,
//                                             width: width * 0.5,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(
//                                         vertical: width * 0.0125,
//                                       ),
//                                       child: SizedBox(
//                                         width: width * 0.5,
//                                         child: Text(
//                                           name,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: width * 0.06,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               changeCategoryProvider.selectedCategory == name
//                                   ? Container(
//                                       padding: EdgeInsets.all(
//                                         width * 0.00625,
//                                       ),
//                                       margin: EdgeInsets.all(
//                                         width * 0.01,
//                                       ),
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: primaryDark2,
//                                       ),
//                                       child: Icon(
//                                         FeatherIcons.check,
//                                         color: Colors.white,
//                                         size: width * 0.1,
//                                       ),
//                                     )
//                                   : Container()
//                             ],
//                           ),
//                         );
//                       })
//                   : SizedBox(
//                       width: width,
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: categories.length,
//                         itemBuilder: ((context, index) {
//                           final name = categories.keys.toList()[index];
//                           final imageUrl = categories.values.toList()[index];

//                           return GestureDetector(
//                             onTap: () {
//                               changeCategoryProvider.changeCategory(name);
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: white,
//                                 border: Border.all(
//                                   width: 0.5,
//                                   color: primaryDark,
//                                 ),
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                               margin: EdgeInsets.all(
//                                 width * 0.0125,
//                               ),
//                               child: Stack(
//                                 alignment: Alignment.centerRight,
//                                 children: [
//                                   ListTile(
//                                     visualDensity: VisualDensity.standard,
//                                     leading: ClipRRect(
//                                       borderRadius: BorderRadius.circular(2),
//                                       child: Image.network(
//                                         imageUrl,
//                                         width: width * 0.15,
//                                         height: width * 0.15,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                     title: Text(
//                                       name,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         fontSize: width * 0.05,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                   changeCategoryProvider.selectedCategory ==
//                                           name
//                                       ? Container(
//                                           padding: EdgeInsets.all(
//                                             width * 0.00625,
//                                           ),
//                                           margin: EdgeInsets.all(
//                                             width * 0.01,
//                                           ),
//                                           decoration: const BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: primaryDark2,
//                                           ),
//                                           child: Icon(
//                                             FeatherIcons.check,
//                                             color: Colors.white,
//                                             size: width * 0.1,
//                                           ),
//                                         )
//                                       : Container()
//                                 ],
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     );
//         }),
//       ),
//     );
//   }
// }
