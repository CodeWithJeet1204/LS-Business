// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ls_business/vendors/utils/colors.dart';
// import 'package:ls_business/widgets/text_button.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';

// class BrandWithDiscountPage extends StatefulWidget {
//   const BrandWithDiscountPage({
//     super.key,
//     required this.discountId,
//   });

//   final String discountId;

//   @override
//   State<BrandWithDiscountPage> createState() => _BrandWithDiscountPageState();
// }

// class _BrandWithDiscountPageState extends State<BrandWithDiscountPage> {
//   final store = FirebaseFirestore.instance;
//   final searchController = TextEditingController();
//   bool isGridView = true;

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   // CONFIRM REMOVE
//   Future<void> confirmRemove(String brandId, String brandName) async {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Remove $brandName',
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           content: Text(
//             'Are you sure you want to remove $brandName from Discount?',
//             maxLines: 1,
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
//                 await remove(brandId);
//               },
//               text: 'YES',
//               textColor: Colors.red,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // REMOVE
//   Future<void> remove(String brandId) async {
//     final discountData = await store
//         .collection('Business')
//         .doc('Data')
//         .collection('Discounts')
//         .doc(widget.discountId)
//         .get();

//     final List brands = discountData['brands'];

//     await store
//         .collection('Business')
//         .doc('Data')
//         .collection('Discounts')
//         .doc(widget.discountId)
//         .update({
//       'brands': brands.remove(brandId),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // GET DISCOUNT BRAND STREAM
//     Stream<List<Map<String, String>>> discountBrandsStream = store
//         .collection('Business')
//         .doc('Data')
//         .collection('Discounts')
//         .doc(widget.discountId)
//         .snapshots()
//         .map((snapshot) {
//       final brandsData = snapshot.data()?['brands'];
//       if (brandsData is List<Map<String, String>>) {
//         return brandsData;
//       } else {
//         return []; // Return an empty list if brands data is not present or not of the correct type
//       }
//     }).switchMap((brandIds) => Rx.combineLatest(
//               brandIds.map((brandId) => store
//                   .collection('Business')
//                   .doc('Data')
//                   .collection('Brands')
//                   .doc(brandId)
//                   .snapshots()),
//               (List<DocumentSnapshot<Map<String, dynamic>>> snapshots) =>
//                   snapshots
//                       .map((snapshot) => {
//                             'brandId': snapshot.id,
//                             'brandName':
//                                 snapshot.data()!['brandName'] as String,
//                             'imageUrl': snapshot.data()!['imageUrl'] as String,
//                           })
//                       .toList()
//                       .cast<Map<String, String>>(),
//             ));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'BRANDS',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size(
//             MediaQuery.sizeOf(context).width,
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
//           final width = constraints.maxWidth;

//           return StreamBuilder(
//             stream: discountBrandsStream,
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
//                 final brands = snapshot.data!;
//                 return isGridView
//                     ? GridView.builder(
//                         shrinkWrap: true,
//                         physics: ClampingScrollPhysics(),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           childAspectRatio: width / 415,
//                         ),
//                         itemCount: brands.length,
//                         itemBuilder: (context, index) {
//                           return brands[index]['brandName']!
//                                   .toLowerCase()
//                                   .contains(searchController.text
//                                       .toString()
//                                       .toLowerCase())
//                               ? Padding(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.01,
//                                   ),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: primary2.withOpacity(0.8),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             vertical: width * 0.02,
//                                           ),
//                                           child: ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             child: Image.network(
//                                               brands[index]['imageUrl']!,
//                                               width: width * 0.45,
//                                               height: width * 0.4,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.only(
//                                             left: width * 0.01,
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               SizedBox(
//                                                 width: width * 0.45,
//                                                 height: width * 0.1,
//                                                 child: Text(
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   brands[index]['brandName']!,
//                                                   maxLines: 1,
//                                                   style: TextStyle(
//                                                     color: primaryDark,
//                                                     fontSize: width * 0.06,
//                                                     fontWeight: FontWeight.w500,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                               ),
//                                               // IconButton(
//                                               //   onPressed: () {
//                                               //     confirmRemove(
//                                               //       brands[index]
//                                               //           ['brandId']!,
//                                               //       brands[index]
//                                               //           ['brandName']!,
//                                               //     );
//                                               //   },
//                                               //   icon: Icon(
//                                               //     Icons
//                                               //         .highlight_remove_outlined,
//                                               //     color: Colors.red,
//                                               //     size: width * 0.075,
//                                               //   ),
//                                               //   tooltip: 'Remove',
//                                               // ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               : Container();
//                         },
//                       )
//                     : SizedBox(
//                         width: width,
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           physics: ClampingScrollPhysics(),
//                           itemCount: brands.length,
//                           itemBuilder: (context, index) {
//                             return Container(
//                               margin: EdgeInsets.symmetric(
//                                 horizontal: width * 0.0225,
//                                 vertical: width * 0.02,
//                               ),
//                               width: width,
//                               height: width * 0.2,
//                               decoration: BoxDecoration(
//                                 color: primary2.withOpacity(0.8),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: ListTile(
//                                 leading: Padding(
//                                   padding: EdgeInsets.only(
//                                     top: width * 0.02,
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(
//                                       4,
//                                     ),
//                                     child: Image.network(
//                                       brands[index]['imageUrl']!,
//                                       width: width * 0.15,
//                                       height: width * 0.15,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                                 title: Text(
//                                   brands[index]['brandName']!,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     fontSize: width * 0.0525,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//               }

//               return const Center(
//                 child: LoadingIndicator(),
//               );
//             }),
//           );
//         }),
//       ),
//     );
//   }
// }
