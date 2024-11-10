// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ls_business/vendors/page/main/add/bulk_add/select_brand_for_bulk_products_page.dart';
// import 'package:ls_business/vendors/page/main/add/bulk_add/select_category_for_bulk_products_page.dart';
// import 'package:ls_business/widgets/bulk_add.dart';
// import 'package:ls_business/widgets/button.dart';
// import 'package:ls_business/widgets/image_pick_dialog.dart';
// import 'package:ls_business/widgets/snack_bar.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';

// class AddBulkProduct extends StatefulWidget {
//   const AddBulkProduct({super.key});

//   @override
//   State<AddBulkProduct> createState() => _AddBulkProductState();
// }

// class _AddBulkProductState extends State<AddBulkProduct> {
//   final auth = FirebaseAuth.instance;
//   final store = FirebaseFirestore.instance;
//   final nameController1 = TextEditingController();
//   final nameController2 = TextEditingController();
//   final nameController3 = TextEditingController();
//   final nameController4 = TextEditingController();
//   final priceController1 = TextEditingController();
//   final priceController2 = TextEditingController();
//   final priceController3 = TextEditingController();
//   final priceController4 = TextEditingController();
//   File? image1;
//   File? image2;
//   File? image3;
//   File? image4;
//   String? selectedCategory;
//   String? selectedBrandId;
//   String? selectedBrandName;
//   bool isUploading = false;

//   // ADD PRODUCT IMAGE
//   Future<void> addProductImages(int index) async {
//     final XFile im = await showImagePickDialog(context);
//     if (im != null) {
//       setState(() {
//         if (index == 1) {
//           image1 = File(im.path);
//         } else if (index == 2) {
//           image2 = File(im.path);
//         } else if (index == 3) {
//           image3 = File(im.path);
//         } else {
//           image4 = File(im.path);
//         }
//       });
//     }
//   }

//   // REMOVE PRODUCT IMAGE
//   void removeProductImages(int index) {
//     setState(() {
//       if (index == 1) {
//         image1 = null;
//       }
//       if (index == 2) {
//         image2 = null;
//       }
//       if (index == 3) {
//         image3 = null;
//       } else {
//         image4 = null;
//       }
//     });
//   }

//   // SAVE
//   Future<void> save() async {
//     setState(() {
//       isUploading = true;
//     });
//     // PRODUCT 1
//     if (image1 == null &&
//         nameController1.text.isEmpty &&
//         priceController1.text.isEmpty) {
//       null;
//       // image
//     } else if (image1 != null &&
//         nameController1.text.isEmpty &&
//         priceController1.text.isEmpty) {
//       return mySnackBar(context, 'Enter Name & Price for Product 1');
//     } else if (image1 != null &&
//         nameController1.text.isNotEmpty &&
//         priceController1.text.isEmpty) {
//       return mySnackBar(context, 'Enter Price for Product 1');
//     } else if (image1 != null &&
//         nameController1.text.isEmpty &&
//         priceController1.text.isNotEmpty) {
//       return mySnackBar(context, 'Enter Name for Product 1');
//     } else if (double.parse(priceController1.text) > 1000000000 ||
//         double.parse(priceController1.text) < 0.999999999999999) {
//       return mySnackBar(
//         context,
//         'Price Range is Rs. 1 - 1000000000 (Product 1)',
//       );
//     }
//     // name
//     else if (image1 == null &&
//         nameController1.text.isNotEmpty &&
//         priceController1.text.isEmpty) {
//       return mySnackBar(context, 'Select Image and Enter Price for Product 1');
//     } else if (image1 != null &&
//         nameController1.text.isNotEmpty &&
//         priceController1.text.isEmpty) {
//       return mySnackBar(context, 'Enter Price for Product 1');
//     } else if (image1 == null &&
//         nameController1.text.isNotEmpty &&
//         priceController1.text.isNotEmpty) {
//       return mySnackBar(context, 'Select Image for Product 1');
//     } else if (double.parse(priceController1.text) > 1000000000 ||
//         double.parse(priceController1.text) < 0.999999999999999) {
//       return mySnackBar(
//         context,
//         'Price Range is Rs. 1 - 1000000000 (Product 1)',
//       );
//     }
//     // price
//     else if (image1 == null &&
//         nameController1.text.isEmpty &&
//         priceController1.text.isNotEmpty) {
//       return mySnackBar(context, 'Select Image and Enter Name for Product 1');
//     } else if (image1 != null &&
//         nameController1.text.isEmpty &&
//         priceController1.text.isNotEmpty) {
//       return mySnackBar(context, 'Enter Name for Product 1');
//     } else if (image1 == null &&
//         nameController1.text.isNotEmpty &&
//         priceController1.text.isNotEmpty) {
//       return mySnackBar(context, 'Select Image for Product 1');
//     } else if (double.parse(priceController1.text) > 1000000000 ||
//         double.parse(priceController1.text) < 0.999999999999999) {
//       return mySnackBar(
//           context, 'Price Range is Rs. 1 - 1000000000 (Product 1)');
//     } else if (image1 != null &&
//         nameController1.text.isNotEmpty &&
//         priceController1.text.isNotEmpty) {
//       try {
//         final previousProducts = await store
//             .collection('Business')
//             .doc('Data')
//             .collection('Products')
//             .where('vendorId', isEqualTo: auth.currentUser!.uid)
//             .get();

//         bool productAlreadyExists = false;

//         if (previousProducts.docs.isNotEmpty) {
//           for (QueryDocumentSnapshot doc in previousProducts.docs) {
//             if (doc['productName'] == nameController1.text.toString().trim()) {
//               productAlreadyExists = true;
//               break;
//             }
//           }
//         }

//         if (productAlreadyExists) {
//           if (mounted) {
//             return mySnackBar(
//               context,
//               'Product 1 with the same name already exists',
//             );
//           }
//         } else {
//           await addProduct(1);
//         }
//       } catch (e) {
//         setState(() {
//           isUploading = false;
//         });
//         if (mounted) {
//           return mySnackBar(context, 'Some error occurred');
//         }
//       }
//     }

//     // ------------

//     // PRODUCT 2
//     if (mounted) {
//       if (image2 == null &&
//           nameController2.text.isEmpty &&
//           priceController2.text.isEmpty) {
//         null;
//         // image
//       } else if (image2 != null &&
//           nameController2.text.isEmpty &&
//           priceController2.text.isEmpty) {
//         return mySnackBar(context, 'Enter Name & Price for Product 2');
//       } else if (image2 != null &&
//           nameController2.text.isNotEmpty &&
//           priceController2.text.isEmpty) {
//         return mySnackBar(context, 'Enter Price for Product 2');
//       } else if (image2 != null &&
//           nameController2.text.isEmpty &&
//           priceController2.text.isNotEmpty) {
//         return mySnackBar(context, 'Enter Name for Product 2');
//       } else if (double.parse(priceController2.text) > 1000000000 ||
//           double.parse(priceController2.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 2)');
//       }
//       // name
//       else if (image2 == null &&
//           nameController2.text.isNotEmpty &&
//           priceController2.text.isEmpty) {
//         return mySnackBar(
//             context, 'Select Image and Enter Price for Product 2');
//       } else if (image2 != null &&
//           nameController2.text.isNotEmpty &&
//           priceController2.text.isEmpty) {
//         return mySnackBar(context, 'Enter Price for Product 2');
//       } else if (image2 == null &&
//           nameController2.text.isNotEmpty &&
//           priceController2.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image for Product 2');
//       } else if (double.parse(priceController2.text) > 1000000000 ||
//           double.parse(priceController2.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 2)');
//       }
//       // price
//       else if (image2 == null &&
//           nameController2.text.isEmpty &&
//           priceController2.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image and Enter Name for Product 2');
//       } else if (image2 != null &&
//           nameController2.text.isEmpty &&
//           priceController2.text.isNotEmpty) {
//         return mySnackBar(context, 'Enter Name for Product 2');
//       } else if (image2 == null &&
//           nameController2.text.isNotEmpty &&
//           priceController2.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image for Product 2');
//       } else if (double.parse(priceController2.text) > 1000000000 ||
//           double.parse(priceController2.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 2)');
//       } else if (image2 != null &&
//           nameController2.text.isNotEmpty &&
//           priceController2.text.isNotEmpty) {
//         try {
//           final previousProducts = await store
//               .collection('Business')
//               .doc('Data')
//               .collection('Products')
//               .where('vendorId', isEqualTo: auth.currentUser!.uid)
//               .get();

//           bool productAlreadyExists = false;

//           if (previousProducts.docs.isNotEmpty) {
//             for (QueryDocumentSnapshot doc in previousProducts.docs) {
//               if (doc['productName'] == nameController2.text.toString().trim()) {
//                 productAlreadyExists = true;
//                 break;
//               }
//             }
//           }

//           if (productAlreadyExists) {
//             if (mounted) {
//               return mySnackBar(
//                 context,
//                 'Product 2 with the same name already exists',
//               );
//             }
//           } else {
//             await addProduct(2);
//           }
//         } catch (e) {
//           setState(() {
//             isUploading = false;
//           });
//           if (mounted) {
//             return mySnackBar(context, 'Some error occurred');
//           }
//         }
//       }
//     }

//     // ------------

//     // PRODUCT 3
//     if (mounted) {
//       if (image3 == null &&
//           nameController3.text.isEmpty &&
//           priceController3.text.isEmpty) {
//         null;
//         // image
//       } else if (image3 != null &&
//           nameController3.text.isEmpty &&
//           priceController3.text.isEmpty) {
//         return mySnackBar(context, 'Enter Name & Price for Product 3');
//       } else if (image3 != null &&
//           nameController3.text.isNotEmpty &&
//           priceController3.text.isEmpty) {
//         return mySnackBar(context, 'Enter Price for Product 3');
//       } else if (image3 != null &&
//           nameController3.text.isEmpty &&
//           priceController3.text.isNotEmpty) {
//         return mySnackBar(context, 'Enter Name for Product 3');
//       } else if (double.parse(priceController3.text) > 1000000000 ||
//           double.parse(priceController3.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 3)');
//       }
//       // name
//       else if (image3 == null &&
//           nameController3.text.isNotEmpty &&
//           priceController3.text.isEmpty) {
//         return mySnackBar(
//             context, 'Select Image and Enter Price for Product 3');
//       } else if (image3 != null &&
//           nameController3.text.isNotEmpty &&
//           priceController3.text.isEmpty) {
//         return mySnackBar(context, 'Enter Price for Product 3');
//       } else if (image3 == null &&
//           nameController3.text.isNotEmpty &&
//           priceController3.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image for Product 3');
//       } else if (double.parse(priceController3.text) > 1000000000 ||
//           double.parse(priceController3.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 3)');
//       }
//       // price
//       else if (image3 == null &&
//           nameController3.text.isEmpty &&
//           priceController3.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image and Enter Name for Product 3');
//       } else if (image3 != null &&
//           nameController3.text.isEmpty &&
//           priceController3.text.isNotEmpty) {
//         return mySnackBar(context, 'Enter Name for Product 3');
//       } else if (image3 == null &&
//           nameController3.text.isNotEmpty &&
//           priceController3.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image for Product 3');
//       } else if (double.parse(priceController3.text) > 1000000000 ||
//           double.parse(priceController3.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 3)');
//       } else if (image3 != null &&
//           nameController3.text.isNotEmpty &&
//           priceController3.text.isNotEmpty) {
//         try {
//           final previousProducts = await store
//               .collection('Business')
//               .doc('Data')
//               .collection('Products')
//               .where('vendorId', isEqualTo: auth.currentUser!.uid)
//               .get();

//           bool productAlreadyExists = false;

//           if (previousProducts.docs.isNotEmpty) {
//             for (QueryDocumentSnapshot doc in previousProducts.docs) {
//               if (doc['productName'] == nameController3.text.toString().trim()) {
//                 productAlreadyExists = true;
//                 break;
//               }
//             }
//           }

//           if (productAlreadyExists) {
//             if (mounted) {
//               return mySnackBar(
//                 context,
//                 'Product 3 with the same name already exists',
//               );
//             }
//           } else {
//             await addProduct(3);
//           }
//         } catch (e) {
//           setState(() {
//             isUploading = false;
//           });
//           if (mounted) {
//             return mySnackBar(context, 'Some error occurred');
//           }
//         }
//       }
//     }

//     // ------------

//     // PRODUCT 4
//     if (mounted) {
//       if (image4 == null &&
//           nameController4.text.isEmpty &&
//           priceController4.text.isEmpty) {
//         null;
//         // image
//       } else if (image4 != null &&
//           nameController4.text.isEmpty &&
//           priceController4.text.isEmpty) {
//         return mySnackBar(context, 'Enter Name & Price for Product 4');
//       } else if (image4 != null &&
//           nameController4.text.isNotEmpty &&
//           priceController4.text.isEmpty) {
//         return mySnackBar(context, 'Enter Price for Product 4');
//       } else if (image4 != null &&
//           nameController4.text.isEmpty &&
//           priceController4.text.isNotEmpty) {
//         return mySnackBar(context, 'Enter Name for Product 4');
//       } else if (double.parse(priceController4.text) > 1000000000 ||
//           double.parse(priceController4.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 4)');
//       }
//       // name
//       else if (image4 == null &&
//           nameController4.text.isNotEmpty &&
//           priceController4.text.isEmpty) {
//         return mySnackBar(
//             context, 'Select Image and Enter Price for Product 4');
//       } else if (image4 != null &&
//           nameController4.text.isNotEmpty &&
//           priceController4.text.isEmpty) {
//         return mySnackBar(context, 'Enter Price for Product 4');
//       } else if (image4 == null &&
//           nameController4.text.isNotEmpty &&
//           priceController4.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image for Product 4');
//       } else if (double.parse(priceController4.text) > 1000000000 ||
//           double.parse(priceController4.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 4)');
//       }
//       // price
//       else if (image4 == null &&
//           nameController4.text.isEmpty &&
//           priceController4.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image and Enter Name for Product 4');
//       } else if (image4 != null &&
//           nameController4.text.isEmpty &&
//           priceController4.text.isNotEmpty) {
//         return mySnackBar(context, 'Enter Name for Product 4');
//       } else if (image4 == null &&
//           nameController4.text.isNotEmpty &&
//           priceController4.text.isNotEmpty) {
//         return mySnackBar(context, 'Select Image for Product 4');
//       } else if (double.parse(priceController4.text) > 1000000000 ||
//           double.parse(priceController4.text) < 0.999999999999999) {
//         return mySnackBar(
//             context, 'Price Range is Rs. 1 - 1000000000 (Product 4)');
//       } else if (image4 != null &&
//           nameController4.text.isNotEmpty &&
//           priceController4.text.isNotEmpty) {
//         try {
//           final previousProducts = await store
//               .collection('Business')
//               .doc('Data')
//               .collection('Products')
//               .where('vendorId', isEqualTo: auth.currentUser!.uid)
//               .get();

//           bool productAlreadyExists = false;

//           if (previousProducts.docs.isNotEmpty) {
//             for (QueryDocumentSnapshot doc in previousProducts.docs) {
//               if (doc['productName'] == nameController4.text.toString().trim()) {
//                 productAlreadyExists = true;
//                 break;
//               }
//             }
//           }

//           if (productAlreadyExists) {
//             if (mounted) {
//               return mySnackBar(
//                 context,
//                 'Product 4 with the same name already exists',
//               );
//             }
//           } else {
//             await addProduct(4);
//           }
//         } catch (e) {
//           setState(() {
//             isUploading = false;
//           });
//           if (mounted) {
//             return mySnackBar(context, 'Some error occurred');
//           }
//         }
//       }
//     }

//     setState(() {
//       isUploading = false;
//     });
//     if (mounted) {
//       Navigator.of(context).pop();
//     }
//   }

//   // ADD PRODUCT
//   Future<void> addProduct(int index) async {
//     TextEditingController? nameController;
//     TextEditingController? priceController;
//     File? image;
//     if (index == 1) {
//       nameController = nameController1;
//       priceController = priceController1;
//       image = image1;
//     } else if (index == 2) {
//       nameController = nameController2;
//       priceController = priceController2;
//       image = image2;
//     } else if (index == 3) {
//       nameController = nameController3;
//       priceController = priceController3;
//       image = image3;
//     } else {
//       nameController = nameController4;
//       priceController = priceController4;
//       image = image4;
//     }

//     String imageUrl = '';

//     try {
//       Reference ref = FirebaseStorage.instance
//           .ref()
//           .child('Vendor/Products')
//           .child(const Uuid().v4());
//       await ref.putFile(image!).whenComplete(() async {
//         await ref.getDownloadURL().then((value) {
//           setState(() {
//             imageUrl = value;
//           });
//         });
//       });
//     } catch (e) {
//       if (mounted) {
//         mySnackBar(context, e.toString());
//       }
//     }

//     final String productId = const Uuid().v4();

//     await store
//         .collection('Business')
//         .doc('Data')
//         .collection('Products')
//         .doc(productId)
//         .set(
//       {
//         'productName': nameController.text,
//         'productPrice': priceController.text,
//         'productDescription': '',
//         'productBrand': selectedBrandName ?? 'No Brand',
//         'productBrandId': selectedBrandId ?? '0',
//         'productShares': 0,
//         'productViewsTimestamp': [],
//         'productLikesTimestamp': {},
//         'productWishlistTimestamp': {},
//         'productId': productId,
//         'images': [
//           imageUrl,
//         ],
//         'shortsThumbnail': '',
//         'shortsURL': '',
//         'datetime': Timestamp.fromMillisecondsSinceEpoch(
//           DateTime.now().millisecondsSinceEpoch,
//         ),
//         'isAvailable': 0,
//         'categoryName': selectedCategory ?? '0',
//         'vendorId': auth.currentUser!.uid,
//         'ratings': {},
//         'Properties': {
//           'propertyName0': '',
//           'propertyName1': '',
//           'propertyName2': '',
//           'propertyName3': '',
//           'propertyName4': '',
//           'propertyName5': '',
//           'propertyValue0': [],
//           'propertyValue1': [],
//           'propertyValue2': [],
//           'propertyValue3': [],
//           'propertyValue4': [],
//           'propertyValue5': [],
//           'propertyNoOfAnswers0': 2,
//           'propertyNoOfAnswers1': 2,
//           'propertyNoOfAnswers2': 2,
//           'propertyNoOfAnswers3': 2,
//           'propertyNoOfAnswers4': 2,
//           'propertyNoOfAnswers5': 2,
//           'propertyChangable0': false,
//           'propertyChangable1': false,
//           'propertyChangable2': false,
//           'propertyChangable3': false,
//           'propertyChangable4': false,
//           'propertyChangable5': false,
//           'propertyInputType0': true,
//           'propertyInputType1': true,
//           'propertyInputType2': true,
//           'propertyInputType3': true,
//           'propertyInputType4': true,
//           'propertyInputType5': true,
//         },
//         'deliveryAvailable': false,
//         'codAvailable': false,
//         'refundAvailable': false,
//         'replacementAvailable': false,
//         'giftWrapAvailable': false,
//         'bulkSellAvailable': false,
//         'gstInvoiceAvailable': false,
//         'cardOffersAvailable': false,
//         'deliveryRange': 0,
//         'refundRange': 0,
//         'replacementRange': 0,
//         'Tags': [],
//       },
//     );

//     //   await sendNotificationToFollowers(
//     //     auth.currentUser!.uid,
//     //     nameController.text,
//     //   );
//     // }

//     // Future<void> sendNotificationToFollowers(
//     //   String vendorId,
//     //   String productName,
//     // ) async {
//     //   final serviceAccount = {
//     //     'type': 'service_account',
//     //     'project_id': 'ls_business-1204',
//     //     'private_key_id': '77b067e56f3b083400168ad07456b8742affcd75',
//     //     'private_key':
//     //         '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDF410m/DqKJx86\nKtx5sXu+7R47TUJef1IgSJkYQesrb2EiplaLfLrId9UDaxb5ddmlDa4w1XMh1S2X\ne/znKYaoZsFlEcD8FlWKhC+/7eofxuQZn3zMfR121ptYMa8U78+fFRdyuu938UBt\n79hLXCFgIT9YiFDZaifxlUmzIwXdIWrqRbZy0dusdJ9YzGUO2Jli63poc1mGkT2v\nHvGvkraVxUcd3PAsvUtRF8hnrRC6+yyHPEKs84ho84pNmZUqhBucfCXxamnD/9Z0\nJkICtOuooSHnPzn5Uc3aIT34J1w99n7ZJSqhGcZ75Mc7rwrETWZ3wrGZOuBo3TmB\nr78bgACfAgMBAAECggEAPzhztrRHWYLFKbauyFwo/ibQDT8SEJGZocG/022f3bkQ\nLds5dAfNvqT2E0j/xoPdnCsiNuzCgxERpz9P3WQ5ZoyphYol/wN9oaq4fJdcQHmw\nvvTikIv6QVCvwX3iAwzYZmj9HETXo5iaLmU9U1okOYt1quml9sfA6h/5MzdhtLLb\nrc5s0QjbDByS3xqPCxqTrhlkUTyWMLkaEZNHsfzMbZxUac0XlCcgPJbLppKl30ZN\nqDME/rZhMKZRM1hJK8xwEzVHtZVytDLP8480dhNO2gxpjMAPzJsefZbU8YG+2e3Z\nl+M7HpRjvtPO2l0uSGEZmESmLgEY5fJUj6Mls72JlQKBgQDzXeCkWsDTC/acBIxy\n9Qg98w7Gs4YfD2hQvxLibEITzlA/LNCZBWYofadtT4PidNysAmmKV8+/nlH/RIQH\niBYRcCa0nFmP/d2BUpvRXNaCJxTJbDjGZpyK40NiYG/BZl9EUVkCg4LdHhr3Bdbv\nzlLJERw5waKj/0VzJiMi7bST2wKBgQDQKR4Ueo7VvTYvvbOEsu+B/HIb85Dqm6dK\n8RgnoLjiFbfZvaPpiW2LCfuIBHpi20KjrVpf74SJZqbgN9Ph8Az/JIwJYyMT0bgH\nxGBTB/F8p7LtIgAB3gbLlbOv2l6htiXWHttALJwu+jS6nAYO5fglNNXEtemR/m8P\nLNPubJ0DjQKBgESNtEL34YtRumUWju2vAmRY/FeSqHxFXdApEsu/TRnBKy+wkw4X\nzEAprSkIlhELdEHr6Aj1VWsX0OdESKDKf9Tnr69+v2flTikouQXPzgkZsyxOFOwm\naYBiJlAm9DQZf0qCU712iD17RoNBHNuuVfmXnUjTt9nUhZ67JninVw+zAoGAG1tc\nBar5vKNqTKnsvuLZUUcBJCVFhV/Bg7rdxs97nNLn36jpstaJ2/0K3pxgDT/tqR8u\nQm9zBq/D/LG5mfb3bky6Tr2FraQhQHwRgLgJh61ueXW/dH9ee0EIZXMYfr42iMZz\nYCK8v/vIFEJPFYQpsZIZCgoyUSqUI/VrQOlrVT0CgYEAzOWItEJsqDkLgn4J0fIv\nSDhX/kCo9S1fVJUipnYZc9EWg0+zQY86dQdC5ari5xDdKBYFhOHWOddUKT0Ymp90\n7CSJRvoE+UKTKIoDbJtSm4qJDk7Rgm9C6o6FfdsQ6fc4kQ9AnLuKaGMD4br3h5lA\nWLSrHoOGijvkQ0R41/AaRj8=\n-----END PRIVATE KEY-----\n',
//     //     'client_email':
//     //         'firebase-adminsdk-rbj88@ls_business-1204.iam.gserviceaccount.com',
//     //     'client_id': '100812646060075834796',
//     //     'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
//     //     'token_uri': 'https://oauth2.googleapis.com/token',
//     //     'auth_provider_x509_cert_url':
//     //         'https://www.googleapis.com/oauth2/v1/certs',
//     //     'client_x509_cert_url':
//     //         'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-rbj88%40ls_business-1204.iam.gserviceaccount.com',
//     //     'universe_domain': 'googleapis.com'
//     //   };

//     //   final accountCredentials =
//     //       auth.ServiceAccountCredentials.fromJson(serviceAccount);

//     //   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

//     //   final authClient =
//     //       await auth.clientViaServiceAccount(accountCredentials, scopes);

//     //   final url =
//     //       'https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send';

//     //   final headers = {
//     //     'Content-Type': 'application/json',
//     //   };

//     //   final body = jsonEncode({
//     //     'message': {
//     //       'token': 'abc',
//     //       'notification': {
//     //         'title': 'New Product Added!',
//     //         'body': 'Check out the new product.',
//     //       },
//     //     },
//     //   });

//     //   final response = await authClient.post(
//     //     Uri.parse(url),
//     //     headers: headers,
//     //     body: body,
//     //   );

//     //   if (response.statusCode == 200) {
//     //   } else {
//     //   }

//     //   authClient.close();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bulk Add Products'),
//       ),
//       bottomSheet: Padding(
//         padding: const EdgeInsets.all(8),
//         child: SizedBox(
//           width: MediaQuery.sizeOf(context).width,
//           height: 60,
//           child: MyButton(
//             text: 'DONE',
//             onTap: () async {
//               await save();
//             },
//             isLoading: isUploading,
//             horizontalPadding: MediaQuery.sizeOf(context).width * 0.0225,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: MediaQuery.sizeOf(context).width * 0.003125,
//           ),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final width = constraints.maxWidth;

//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     // SELECT CATEGORY
//                     MyButton(
//                       text: selectedCategory ?? 'Select Category',
//                       onTap: () {
//                         Navigator.of(context)
//                             .push(
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const SelectCategoryForBulkProductsPage(),
//                           ),
//                         )
//                             .then((value) {
//                           if (value != null || value != '') {
//                             setState(() {
//                               selectedCategory = value;
//                             });
//                           }
//                         });
//                       },
//                       isLoading: false,
//                       horizontalPadding: width * 0.0125,
//                     ),
//                     const SizedBox(height: 8),

//                     // SELECT BRAND
//                     MyButton(
//                       text: selectedBrandName ?? 'Select Brand',
//                       onTap: () {
//                         Navigator.of(context)
//                             .push(
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const SelectBrandForBulkProductsPage(),
//                           ),
//                         )
//                             .then((value) {
//                           if (value != null || value.isNotEmpty) {
//                             setState(() {
//                               selectedBrandId = value[0];
//                               selectedBrandName = value[1];
//                             });
//                           }
//                         });
//                       },
//                       isLoading: false,
//                       horizontalPadding: width * 0.0125,
//                     ),
//                     const SizedBox(height: 8),

//                     BulkAdd(
//                       width: width,
//                       nameController: nameController1,
//                       priceController: priceController1,
//                       onTap: () async {
//                         await addProductImages(1);
//                       },
//                       onRemove: () {
//                         removeProductImages(1);
//                       },
//                       image: image1,
//                     ),
//                     BulkAdd(
//                       width: width,
//                       nameController: nameController2,
//                       priceController: priceController2,
//                       onTap: () async {
//                         await addProductImages(2);
//                       },
//                       onRemove: () {
//                         removeProductImages(2);
//                       },
//                       image: image2,
//                     ),
//                     BulkAdd(
//                       width: width,
//                       nameController: nameController3,
//                       priceController: priceController3,
//                       onTap: () async {
//                         await addProductImages(3);
//                       },
//                       onRemove: () {
//                         removeProductImages(3);
//                       },
//                       image: image3,
//                     ),
//                     BulkAdd(
//                       width: width,
//                       nameController: nameController4,
//                       priceController: priceController4,
//                       onTap: () async {
//                         await addProductImages(4);
//                       },
//                       onRemove: () {
//                         removeProductImages(4);
//                       },
//                       image: image4,
//                     ),
//                     const SizedBox(height: 72),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }
