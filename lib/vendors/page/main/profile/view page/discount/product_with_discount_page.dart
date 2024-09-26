// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ls_business/vendors/utils/colors.dart';
// import 'package:ls_business/widgets/text_button.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';

// class ProductWithDiscountPage extends StatefulWidget {
//   const ProductWithDiscountPage({
//     super.key,
//     required this.discountId,
//   });

//   final String discountId;

//   @override
//   State<ProductWithDiscountPage> createState() =>
//       _ProductWithDiscountPageState();
// }

// class _ProductWithDiscountPageState extends State<ProductWithDiscountPage> {
//   final store = FirebaseFirestore.instance;
//   final searchController = TextEditingController();
//   bool isGridView = true;

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   Future<void> confirmRemove(String productId, String productName) async {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Remove $productName',
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           content: Text(
//             'Are you sure you want to remove $productName from Discount?',
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           actions: [
//             MyTextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               text: 'NO',
//               textColor: Colors.green,
//             ),
//             MyTextButton(
//               onPressed: () async {
//                 await remove(productId);
//               },
//               text: 'YES',
//               textColor: Colors.red,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> remove(String productId) async {
//     final discountData = await store
//         .collection('Business')
//         .doc('Data')
//         .collection('Discounts')
//         .doc(widget.discountId)
//         .get();

//     final List products = discountData['products'];

//     await store
//         .collection('Business')
//         .doc('Data')
//         .collection('Discounts')
//         .doc(widget.discountId)
//         .update({
//       'products': products.remove(productId),
//     });
//     if (mounted) {
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productDiscountStream = store
//         .collection('Business')
//         .doc('Data')
//         .collection('Discounts')
//         .doc(widget.discountId)
//         .snapshots()
//         .map((snapshot) => snapshot.data()!['products'] as List)
//         .switchMap((productIds) => Rx.combineLatest(
//               productIds.map((productId) => store
//                   .collection('Business')
//                   .doc('Data')
//                   .collection('Products')
//                   .doc(productId)
//                   .snapshots()),
//               (List<DocumentSnapshot<Map<String, dynamic>>> snapshots) =>
//                   snapshots
//                       .map((snapshot) => {
//                             'productId': snapshot.id,
//                             'productName':
//                                 snapshot.data()!['productName'] as String,
//                             'imageUrl': snapshot.data()!['images'][0] as String,
//                           })
//                       .toList()
//                       .cast<Map<String, String>>(),
//             ));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'PRODUCTS',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size(
//             MediaQuery.of(context).size.width,
//             80,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 6,
//               vertical: 8,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: searchController,
//                     autocorrect: false,
//                     onTapOutside: (event) => FocusScope.of(context).unfocus(),
//                     decoration: const InputDecoration(
//                       hintText: 'Search ...',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) {
//                       setState(() {});
//                     },
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       isGridView = !isGridView;
//                     });
//                   },
//                   icon: Icon(
//                     isGridView ? Icons.list : Icons.grid_view_rounded,
//                   ),
//                   tooltip: isGridView ? 'List View' : 'Grid View',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double width = constraints.maxWidth;

//           return StreamBuilder(
//             stream: productDiscountStream,
//             builder: ((context, snapshot) {
//               if (snapshot.hasError) {
//                 return const Center(
//                   child: Text(
//                     'Something went wrong',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 );
//               }

//               if (snapshot.hasData) {
//                 final products = snapshot.data!;
//                 return isGridView
//                     ? GridView.builder(
//                         shrinkWrap: true,
//                         physics: ClampingScrollPhysics(),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           childAspectRatio: width / 415,
//                         ),
//                         itemCount: products.length,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: width * 0.01,
//                             ),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: primary2.withOpacity(0.8),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: width * 0.02,
//                                     ),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(12),
//                                       child: Image.network(
//                                         products[index]['images']![0],
//                                         width: width * 0.45,
//                                         height: width * 0.4,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.only(
//                                       left: width * 0.01,
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           width: width * 0.45,
//                                           child: Text(
//                                             products[index]['productName']!,
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                               color: primaryDark,
//                                               fontSize: width * 0.05,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ),
//                                         // IconButton(
//                                         //   onPressed: () {
//                                         //     confirmRemove(
//                                         //       products[index]
//                                         //           ['productId']!,
//                                         //       products[index]
//                                         //           ['productName']!,
//                                         //     );
//                                         //   },
//                                         //   icon: Icon(
//                                         //     Icons
//                                         //         .highlight_remove_outlined,
//                                         //     color: Colors.red,
//                                         //     size: width * 0.075,
//                                         //   ),
//                                         //   tooltip: 'Remove',
//                                         // ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       )
//                     : ListView.builder(
//                         shrinkWrap: true,
//                         physics: ClampingScrollPhysics(),
//                         itemCount: products.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             visualDensity: VisualDensity.standard,
//                             leading: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.network(
//                                 products[index]['images']![0],
//                                 width: width * 0.1125,
//                                 height: width * 0.1125,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             title: Text(
//                               products[index]['productName']!,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color: primaryDark,
//                                 fontSize: width * 0.05,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           );
//                         },
//                       );
//               }

//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }),
//           );
//         }),
//       ),
//     );
//   }
// }
