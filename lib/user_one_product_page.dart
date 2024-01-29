// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:find_easy/utils/colors.dart';
// import 'package:find_easy/widgets/product_info_box.dart';
// import 'package:flutter/material.dart';

// class UserProductPage extends StatefulWidget {
//   const UserProductPage({
//     super.key,
//     required this.productData,
//   });

//   final Map<String, dynamic> productData;

//   @override
//   State<UserProductPage> createState() => _UserProductPageState();
// }

// class _UserProductPageState extends State<UserProductPage> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final Map<String, dynamic> data = widget.productData;
//     final String name = data['productName'];
//     final String price = data['productPrice'];
//     final String description = data['productDescription'];
//     final String brand = data['productBrand'];
//     final List images = data['images'];

//     final Map<String, dynamic> properties = data['Properties'];
//     final String propertyName0 = properties['propertyName0'];
//     final String propertyName1 = properties['propertyName1'];
//     final String propertyName2 = properties['propertyName2'];
//     final String propertyName3 = properties['propertyName3'];
//     final String propertyName4 = properties['propertyName4'];
//     final String propertyName5 = properties['propertyName5'];

//     final List propertyValue0 = properties['propertyValue0'];
//     final List propertyValue1 = properties['propertyValue1'];
//     final List propertyValue2 = properties['propertyValue2'];
//     final List propertyValue3 = properties['propertyValue3'];
//     final List propertyValue4 = properties['propertyValue4'];
//     final List propertyValue5 = properties['propertyValue5'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.productData['productName'],
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: ((context, constraints) {
//           // double width = constraints.maxWidth;
//           // double height = constraints.maxHeight;
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // IMAGES
//                   CarouselSlider(
//                     items: (images)
//                         .map(
//                           (e) => Container(
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: primaryDark2,
//                                 width: 1,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Image.network(
//                               e,
//                             ),
//                           ),
//                         )
//                         .toList(),
//                     options: CarouselOptions(
//                       enableInfiniteScroll: images.length > 1 ? true : false,
//                       aspectRatio: 1.2,
//                       enlargeCenterPage: true,
//                       onPageChanged: (index, reason) {
//                         setState(() {
//                           _currentIndex = index;
//                         });
//                       },
//                     ),
//                   ),
//                   // DOTS
//                   images.length > 1
//                       ? Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: (images).map((e) {
//                               int index = images.indexOf(e);

//                               return Container(
//                                 width: _currentIndex == index ? 12 : 8,
//                                 height: _currentIndex == index ? 12 : 8,
//                                 margin: EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: _currentIndex == index
//                                       ? primaryDark
//                                       : primary2,
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         )
//                       : SizedBox(height: 36),

//                   // NAME
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Text(
//                       name,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: primaryDark,
//                         fontSize: name.length > 12
//                             ? 28
//                             : name.length > 10
//                                 ? 30
//                                 : 32,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                   // PRICE
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Text(
//                       price == "" ? 'N/A (price)' : 'Rs. ${price}',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: primaryDark,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),

//                   // DESCRIPTION
//                   // ProductInfoBox(
//                   //   head: "Description",
//                   //   content: description,
//                   // ),

//                   // BRAND
//                   // ProductInfoBox(
//                   //   head: "Brand",
//                   //   content: brand,
//                   // ),

//                   // PROPERTY 0
//                   ProductInfoBox(
//                     head: propertyName0,
//                     content:
//                         propertyValue0.length == 1 ? propertyValue0[0] : null,
//                     value: propertyValue0.length > 1
//                         ? propertyValue0
//                             .map(
//                               (e) => Container(
//                                 height: 40,
//                                 margin: EdgeInsets.only(
//                                   right: 4,
//                                   top: 4,
//                                   bottom: 4,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 4,
//                                 ),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: primary2.withOpacity(0.8),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   e,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: primaryDark2,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList()
//                         : null,
//                   ),

//                   // PROPERTY 1
//                   ProductInfoBox(
//                     head: propertyName1,
//                     content:
//                         propertyValue1.length == 1 ? propertyValue1[0] : null,
//                     value: propertyValue1.length > 1
//                         ? propertyValue1
//                             .map(
//                               (e) => Container(
//                                 height: 40,
//                                 margin: EdgeInsets.only(
//                                   right: 4,
//                                   top: 4,
//                                   bottom: 4,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 4,
//                                 ),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: primary2.withOpacity(0.8),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   e,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: primaryDark2,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList()
//                         : null,
//                   ),

//                   // PROPERTY 2
//                   ProductInfoBox(
//                     head: propertyName2,
//                     content:
//                         propertyValue2.length == 1 ? propertyValue2[0] : null,
//                     value: propertyValue2.length > 1
//                         ? propertyValue2
//                             .map(
//                               (e) => Container(
//                                 height: 40,
//                                 margin: EdgeInsets.only(
//                                   right: 4,
//                                   top: 4,
//                                   bottom: 4,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 4,
//                                 ),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: primary2.withOpacity(0.8),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   e,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: primaryDark2,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList()
//                         : null,
//                   ),

//                   // PROPERTY 3
//                   ProductInfoBox(
//                     head: propertyName3,
//                     content:
//                         propertyValue3.length == 1 ? propertyValue3[0] : null,
//                     value: propertyValue3.length > 1
//                         ? propertyValue3
//                             .map(
//                               (e) => Container(
//                                 height: 40,
//                                 margin: EdgeInsets.only(
//                                   right: 4,
//                                   top: 4,
//                                   bottom: 4,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 4,
//                                 ),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: primary2.withOpacity(0.8),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   e,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: primaryDark2,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList()
//                         : null,
//                   ),

//                   // PROPERTY 4
//                   ProductInfoBox(
//                     head: propertyName4,
//                     content:
//                         propertyValue4.length == 1 ? propertyValue4[0] : null,
//                     value: propertyValue4.length > 1
//                         ? propertyValue4
//                             .map(
//                               (e) => Container(
//                                 height: 40,
//                                 margin: EdgeInsets.only(
//                                   right: 4,
//                                   top: 4,
//                                   bottom: 4,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 4,
//                                 ),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: primary2.withOpacity(0.8),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   e,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: primaryDark2,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList()
//                         : null,
//                   ),

//                   // PROPERTY 5
//                   ProductInfoBox(
//                     head: propertyName5,
//                     content:
//                         propertyValue5.length == 1 ? propertyValue5[0] : null,
//                     value: propertyValue5.length > 1
//                         ? propertyValue5
//                             .map(
//                               (e) => Container(
//                                 height: 40,
//                                 margin: EdgeInsets.only(
//                                   right: 4,
//                                   top: 4,
//                                   bottom: 4,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 4,
//                                 ),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: primary2.withOpacity(0.8),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   e,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: primaryDark2,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList()
//                         : null,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
