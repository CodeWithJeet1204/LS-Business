// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/page/main/analytics/analytics_page.dart';
import 'package:find_easy/vendors/page/main/discount/products/product_discount_page.dart';
import 'package:find_easy/vendors/page/main/profile/view%20page/category/category_page.dart';
import 'package:find_easy/vendors/page/main/profile/view%20page/product/select_category_for_product_page.dart.dart';
import 'package:find_easy/vendors/page/main/profile/view%20page/product/image_view.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/info_box.dart';
import 'package:find_easy/widgets/info_color_box.dart';
import 'package:find_easy/widgets/info_edit_box.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key,
    required this.productId,
    required this.productName,
    this.fromPost = false,
    this.categoryName,
    this.brandId,
  });

  final String productId;
  final String productName;
  final String? categoryName;
  final String? brandId;
  final bool fromPost;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final GlobalKey<FormState> editKey = GlobalKey<FormState>();
  final TextEditingController editController = TextEditingController();
  bool isDiscount = false;
  int _currentIndex = 0;
  bool isEditing = false;
  bool categoryExists = true;
  bool isImageChanging = false;
  List category = [];

  // INIT STATE
  @override
  void initState() {
    ifDiscount();
    getCategoryInfo();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  // EDIT INFO
  Future<void> edit(
    String propertyValue,
    int noOfAnswers,
    bool isProperty,
    bool inputType,
  ) async {
    showDialog(
        context: context,
        builder: (context) {
          final propertyStream = store
              .collection('Business')
              .doc('Data')
              .collection('Products')
              .doc(widget.productId)
              .snapshots();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              height: noOfAnswers == 1 ? 180 : 200,
              child: StreamBuilder(
                  stream: propertyStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Something went wrong',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final propertyData = snapshot.data!;
                      final property = isProperty
                          ? propertyData['Properties'][propertyValue]
                          : propertyData[propertyValue];

                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Form(
                          key: editKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 80,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: editController,
                                        keyboardType: inputType
                                            ? TextInputType.text
                                            : TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: "Enter $propertyValue",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (propertyValue != 'productPrice') {
                                            if (value != null &&
                                                value.length >= 2) {
                                              return null;
                                            } else {
                                              return "Min 2 chars required";
                                            }
                                          } else {
                                            if (value == null ||
                                                value == '0' ||
                                                value == '') {
                                              editController.text = '';
                                              return null;
                                            } else {
                                              if (double.parse(value) > 0) {
                                                return null;
                                              } else {
                                                return 'Min price is Rs. 1';
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    noOfAnswers != 1
                                        ? MyTextButton(
                                            onPressed: () async {
                                              if (editKey.currentState!
                                                  .validate()) {
                                                // MULTI WORD PROPERTY
                                                if (isProperty) {
                                                  (property as List).add(
                                                      editController.text
                                                          .toString()
                                                          .toUpperCase());
                                                  Map<String, dynamic>
                                                      newPropertyMap =
                                                      propertyData[
                                                          'Properties'];
                                                  newPropertyMap[
                                                      propertyValue] = property;

                                                  newPropertyMap[
                                                      propertyValue] = property;

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Business')
                                                      .doc('Data')
                                                      .collection('Products')
                                                      .doc(widget.productId)
                                                      .update({
                                                    'Properties':
                                                        newPropertyMap,
                                                  });
                                                  editController.clear();
                                                } else {
                                                  // MULTI WORD NOT PROPERTY
                                                  (property as List).add(
                                                      editController.text
                                                          .toString()
                                                          .toUpperCase());

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Business')
                                                      .doc('Data')
                                                      .collection('Products')
                                                      .doc(widget.productId)
                                                      .update({
                                                    propertyValue: property,
                                                  });
                                                  editController.clear();
                                                }
                                              }
                                            },
                                            text: "ADD",
                                            textColor: primaryDark2,
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              noOfAnswers != 1 &&
                                      (property as List).isNotEmpty &&
                                      property[0] != ""
                                  ? SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: property.length,
                                        itemBuilder: ((context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: primaryDark2
                                                    .withOpacity(0.75),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 12,
                                                    ),
                                                    child: Text(
                                                      property[index],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2,
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () async {
                                                        // MULTI WORD PORPERTY
                                                        if (isProperty) {
                                                          property
                                                              .removeAt(index);
                                                          Map<String, dynamic>
                                                              newPropertyMap =
                                                              propertyData[
                                                                  'Properties'];
                                                          newPropertyMap[
                                                                  propertyValue] =
                                                              property;
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Business')
                                                              .doc('Data')
                                                              .collection(
                                                                  'Products')
                                                              .doc(widget
                                                                  .productId)
                                                              .update({
                                                            'Properties':
                                                                newPropertyMap,
                                                          });
                                                          editController
                                                              .clear();
                                                          // TAGS
                                                        } else {
                                                          property
                                                              .removeAt(index);

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Business')
                                                              .doc('Data')
                                                              .collection(
                                                                  'Products')
                                                              .doc(widget
                                                                  .productId)
                                                              .update({
                                                            propertyValue:
                                                                property,
                                                          });
                                                          editController
                                                              .clear();
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        FeatherIcons.x,
                                                        color: white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    )
                                  : Container(),
                              noOfAnswers == 1
                                  ? MyButton(
                                      text: "SAVE",
                                      onTap: () async {
                                        if (editKey.currentState!.validate()) {
                                          setState(() {
                                            isEditing = true;
                                          });
                                          try {
                                            // 1 WORD PROPERTY
                                            if (isProperty) {
                                              Map<String, dynamic>
                                                  newPropertyMap =
                                                  propertyData['Properties'];

                                              newPropertyMap[propertyValue] = [
                                                editController.text
                                                    .toString()
                                                    .toUpperCase()
                                              ];
                                              await store
                                                  .collection('Business')
                                                  .doc('Data')
                                                  .collection('Products')
                                                  .doc(widget.productId)
                                                  .update({
                                                'Properties': newPropertyMap,
                                              });
                                              editController.clear();

                                              // 1 WORD NOT PROPERTY
                                            } else {
                                              await store
                                                  .collection('Business')
                                                  .doc('Data')
                                                  .collection('Products')
                                                  .doc(widget.productId)
                                                  .update({
                                                propertyValue: editController
                                                    .text
                                                    .toString(),
                                              });
                                              editController.clear();
                                            }
                                            editController.clear();
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              mySnackBar(context, e.toString());
                                            }
                                          }
                                          setState(() {
                                            isEditing = false;
                                          });
                                        }
                                      },
                                      isLoading: isEditing,
                                      horizontalPadding: 0,
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          );
        });
  }

  // ADD IMAGES
  Future<void> addProductImages(List images) async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      try {
        setState(() {
          isImageChanging = true;
        });
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('Data/Products')
            .child(const Uuid().v4());
        await ref.putFile(File(im.path)).whenComplete(() async {
          await ref.getDownloadURL().then((value) async {
            images.add(value);
            await store
                .collection('Business')
                .doc('Data')
                .collection('Products')
                .doc(widget.productId)
                .update({
              'images': images,
            });

            final postSnap = await store
                .collection('Business')
                .doc('Data')
                .collection('Posts')
                .where('postProductId', isEqualTo: widget.productId)
                .get();

            postSnap.docs.forEach((doc) async {
              final postData = await store
                  .collection('Business')
                  .doc('Data')
                  .collection('Posts')
                  .doc(doc.id)
                  .get();

              final imageUrls = postData['postProductImages'] as List;
              imageUrls.add(value);

              await store
                  .collection('Business')
                  .doc('Data')
                  .collection('Posts')
                  .doc(doc.id)
                  .update({
                'postProductImages': imageUrls,
              });
            });
          });
        });

        setState(() {
          isImageChanging = false;
        });

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => ProductPage(
                  productId: widget.productId,
                  productName: widget.productName)),
            ),
          );
        }
      } catch (e) {
        setState(() {
          isImageChanging = true;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // CHANGE IMAGE
  Future<void> changeProductImage(String e, int index, List images) async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      try {
        setState(() {
          isImageChanging = true;
        });
        Reference ref = FirebaseStorage.instance.refFromURL(images[index]);
        await images.removeAt(index);
        await ref.putFile(File(im.path));
        setState(() {
          isImageChanging = false;
        });
      } catch (e) {
        setState(() {
          isImageChanging = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // REMOVE IMAGES
  Future<void> removeProductImages(String e, List images) async {
    await FirebaseStorage.instance
        .refFromURL(images[images.indexOf(e)])
        .delete();
    images.remove(e);
    await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .update({
      'images': images,
    });

    final postSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .where('postProductId', isEqualTo: widget.productId)
        .get();

    postSnap.docs.forEach((doc) async {
      final postData = await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .doc(doc.id)
          .get();

      final imageUrls = postData['postProductImages'] as List;
      imageUrls.remove(e);

      await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .doc(doc.id)
          .update({
        'postProductImages': imageUrls,
      });
    });
  }

  // CONFIRM DELETE
  Future<void> confirmDelete() async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            "Confirm DELETE",
            overflow: TextOverflow.ellipsis,
          ),
          content: const Text(
            "Are you sure you want to delete this product & all its posts",
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await delete();
              },
              child: const Text(
                'YES',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // GET CATEGORY
  Future<void> getCategoryInfo() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final shopType = vendorData['Type'];

    final productSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .get();

    final productData = productSnap.data()!;

    final categoryName = productData['categoryName'];

    if (categoryName == '0') {
      return;
    } else {
      final categorySnap = await store
          .collection('Business')
          .doc('Special Categories')
          .collection(shopType)
          .doc(categoryName)
          .get();

      final categoryData = categorySnap.data()!;

      final name = categoryData['specialCategoryName'];
      final imageUrl = categoryData['specialCategoryImageUrl'];

      setState(() {
        category.add(name);
        category.add(imageUrl);
        category.add(shopType);
      });
    }
  }

  // DELETE PRODUCT
  Future<void> delete() async {
    setState(() {
      isEditing = true;
    });
    try {
      if (mounted) {
        Navigator.of(context).pop();
      }
      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(widget.productId)
          .delete();

      final postSnap = await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .where('postProductId', isEqualTo: widget.productId)
          .get();

      for (QueryDocumentSnapshot doc in postSnap.docs) {
        await doc.reference.delete();
      }
      if (mounted) {
        mySnackBar(context, 'Product Deleted');
      }
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      setState(() {
        isEditing = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // IF DISCOUNT
  Future<void> ifDiscount() async {
    final discountSnapshot = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc
        in discountSnapshot.docs) {
      final data = doc.data();

      // products
      if (data['isProducts'] &&
          (data['products'] as List).contains(widget.productId)) {
        // Check if the discount is active
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
          return;
        }
      }

      // brands
      if (data['isBrands'] &&
          (data['brands'] as List).contains(widget.brandId)) {
        // Check if the discount is active
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
          return;
        }
      }

      // categories
      // if (data['isCategories'] &&
      //     (data['categories'] as List).contains(widget.categoryName)) {
      //   // Check if the discount is active
      //   if ((data['discountEndDateTime'] as Timestamp)
      //           .toDate()
      //           .isAfter(DateTime.now()) &&
      //       !(data['discountStartDateTime'] as Timestamp)
      //           .toDate()
      //           .isAfter(DateTime.now())) {
      //     setState(() {
      //       isDiscount = true;
      //     });
      //     return;
      //   }
      // }
    }
  }

  // BLUR HASH IMAGE
  // Future<String> blurHashImage(String imageUrl) async {
  //   var response = await http.get(Uri.parse(imageUrl));
  //   Uint8List imageData = response.bodyBytes;
  // Generate Blurhash string
  //   String blurhash = await BlurHash.encode(imageData, 10, 10);
  //   return blurhash;
  // }

  @override
  Widget build(BuildContext context) {
    final productStream = store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .snapshots();

    final discountPriceStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await confirmDelete();
            },
            icon: const Icon(
              FeatherIcons.trash,
              color: Colors.red,
            ),
            tooltip: "DELETE",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: StreamBuilder(
                  stream: productStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Something went wrong',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final productData = snapshot.data!;
                      final String name = productData['productName'];
                      final String price = productData['productPrice'];
                      // final String description =
                      //     productData['productDescription'];
                      final String brand = productData['productBrand'];
                      final List images = productData['images'];
                      final List tags = productData['Tags'];

                      final int likes = productData['productLikes'];
                      final int shares = productData['productShares'];
                      final int views = productData['productViews'];
                      final int wishList = productData['productWishlist'];

                      bool isAvailable = productData['isAvailable'];

                      final Map<String, dynamic> properties =
                          productData['Properties'];
                      final String propertyName0 = properties['propertyName0'];
                      final String propertyName1 = properties['propertyName1'];
                      final String propertyName2 = properties['propertyName2'];
                      final String propertyName3 = properties['propertyName3'];
                      final String propertyName4 = properties['propertyName4'];
                      final String propertyName5 = properties['propertyName5'];

                      final List propertyValue0 = properties['propertyValue0'];
                      final List propertyValue1 = properties['propertyValue1'];
                      final List propertyValue2 = properties['propertyValue2'];
                      final List propertyValue3 = properties['propertyValue3'];
                      final List propertyValue4 = properties['propertyValue4'];
                      final List propertyValue5 = properties['propertyValue5'];

                      final int propertyNoOfAnswers0 =
                          properties['propertyNoOfAnswers0'];
                      final int propertyNoOfAnswers1 =
                          properties['propertyNoOfAnswers1'];
                      final int propertyNoOfAnswers2 =
                          properties['propertyNoOfAnswers2'];
                      final int propertyNoOfAnswers3 =
                          properties['propertyNoOfAnswers3'];
                      final int propertyNoOfAnswers4 =
                          properties['propertyNoOfAnswers4'];
                      final int propertyNoOfAnswers5 =
                          properties['propertyNoOfAnswers5'];

                      final bool propertyInputType0 =
                          properties['propertyInputType0'];
                      final bool propertyInputType1 =
                          properties['propertyInputType1'];
                      final bool propertyInputType2 =
                          properties['propertyInputType2'];
                      final bool propertyInputType3 =
                          properties['propertyInputType3'];
                      final bool propertyInputType4 =
                          properties['propertyInputType4'];
                      final bool propertyInputType5 =
                          properties['propertyInputType5'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGES
                          CarouselSlider(
                            items: images
                                .map(
                                  (e) => Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: primaryDark2,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: isImageChanging
                                            ? const CircularProgressIndicator()
                                            : GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: ((context) =>
                                                          ImageView(
                                                            imagesUrl: images,
                                                          )),
                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(e),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                      isImageChanging
                                          ? Container()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * 0.0125,
                                                    top: width * 0.0125,
                                                  ),
                                                  child: IconButton.filledTonal(
                                                    onPressed: () async {
                                                      await changeProductImage(
                                                        e,
                                                        images.indexOf(e),
                                                        images,
                                                      );
                                                    },
                                                    icon: Icon(
                                                      FeatherIcons.camera,
                                                      size: width * 0.1,
                                                    ),
                                                    tooltip: "Change Image",
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: width * 0.0125,
                                                    top: width * 0.0125,
                                                  ),
                                                  child: IconButton.filledTonal(
                                                    onPressed: images.last != e
                                                        ? () async {
                                                            await removeProductImages(
                                                              e,
                                                              images,
                                                            );
                                                          }
                                                        : null,
                                                    icon: Icon(
                                                      FeatherIcons.x,
                                                      size: width * 0.1,
                                                    ),
                                                    tooltip: "Remove Image",
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                )
                                .toList(),
                            options: CarouselOptions(
                              enableInfiniteScroll:
                                  images.length > 1 ? true : false,
                              aspectRatio: 1.2,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          ),

                          // DOTS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              images.length > 1
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: width * 0.033,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: (images).map((e) {
                                          int index = images.indexOf(e);

                                          return Container(
                                            width:
                                                _currentIndex == index ? 12 : 8,
                                            height:
                                                _currentIndex == index ? 12 : 8,
                                            margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentIndex == index
                                                  ? primaryDark
                                                  : primary2,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : const SizedBox(height: 40),
                              GestureDetector(
                                onTap: () async {
                                  await addProductImages(images);
                                },
                                child: Container(
                                  width: width * 0.275,
                                  height: width * 0.1,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add Image",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Icon(FeatherIcons.plus),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(),

                          // NAME
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0225,
                                ),
                                child: SizedBox(
                                  width: width * 0.785,
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 20,
                                    style: TextStyle(
                                      color: primaryDark,
                                      fontSize: width * 0.06,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await edit(
                                    'productName',
                                    1,
                                    false,
                                    true,
                                  );
                                },
                                icon: Icon(
                                  FeatherIcons.edit,
                                  size: width * 0.066,
                                ),
                                tooltip: "Edit Name",
                              ),
                            ],
                          ),

                          const Divider(),

                          // PRICE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // PRICE
                              isDiscount
                                  ? StreamBuilder(
                                      stream: discountPriceStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                              'Something went wrong',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }

                                        if (snapshot.hasData) {
                                          final priceSnap = snapshot.data!;
                                          Map<String, dynamic> data = {};
                                          for (QueryDocumentSnapshot<
                                                  Map<String, dynamic>> doc
                                              in priceSnap.docs) {
                                            data = doc.data();
                                          }

                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0225,
                                                ),
                                                child: price == "" ||
                                                        price == 'N/A'
                                                    ? const Text(
                                                        'N/A',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    : RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        text: TextSpan(
                                                          text: 'Rs. ',
                                                          style:
                                                              const TextStyle(
                                                            color: primaryDark,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: data[
                                                                      'isPercent']
                                                                  ? '${double.parse(price) * (100 - (data['discountAmount'])) / 100}  '
                                                                  : '${double.parse(price) - (data['discountAmount'])}  ',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: price,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                color: Color
                                                                    .fromRGBO(
                                                                  255,
                                                                  134,
                                                                  125,
                                                                  1,
                                                                ),
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.0266,
                                                ),
                                                child: data['isPercent']
                                                    ? Text(
                                                        "${data['discountAmount']}% off",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      )
                                                    : Text(
                                                        "Save Rs. ${data['discountAmount']}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.0275,
                                                  vertical: width * 0.0055,
                                                ),
                                                child: Text(
                                                  (data['discountEndDateTime']
                                                                  as Timestamp)
                                                              .toDate()
                                                              .difference(
                                                                  DateTime
                                                                      .now())
                                                              .inHours <
                                                          24
                                                      ? '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours Left'''
                                                      : '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days Left''',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      })
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.02775,
                                          ),
                                          child: Text(
                                            productData['productPrice'] == ""
                                                ? "N/A"
                                                : "Rs. ${productData['productPrice']}",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.06125,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        MyTextButton(
                                          onPressed:
                                              productData['productPrice'] ==
                                                      "N/A"
                                                  ? () {}
                                                  : () async {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: ((context) =>
                                                              ProductDiscountPage(
                                                                changeSelectedProductDiscount:
                                                                    true,
                                                                changeSelectedProductDiscountId:
                                                                    productData[
                                                                        'productId'],
                                                                changeSelectedProductDiscountName:
                                                                    productData[
                                                                        'productName'],
                                                              )),
                                                        ),
                                                      );
                                                    },
                                          text: "Add Discount",
                                          textColor: primaryDark2,
                                        ),
                                      ],
                                    ),

                              // EDIT PRICE
                              IconButton(
                                onPressed: () async {
                                  await edit(
                                    'productPrice',
                                    1,
                                    false,
                                    false,
                                  );
                                },
                                icon: const Icon(
                                  FeatherIcons.edit,
                                  color: primaryDark,
                                ),
                                tooltip: "Edit Price",
                              ),
                            ],
                          ),

                          const Divider(),

                          // AVAILABLE / OUT OF STOCK
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.0225,
                            ),
                            child: Container(
                              width: width,
                              height: width * 0.36,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // AVAILABLE
                                  SizedBox(
                                    width: width,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.0225,
                                        vertical: width * 0.00125,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Available",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.06,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Checkbox(
                                            activeColor: primaryDark,
                                            checkColor: white,
                                            value: isAvailable,
                                            onChanged: (value) async {
                                              await store
                                                  .collection('Business')
                                                  .doc('Data')
                                                  .collection('Products')
                                                  .doc(widget.productId)
                                                  .update({
                                                'isAvailable': value,
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: primaryDark.withOpacity(0.2),
                                    indent: width * 0.0225,
                                    endIndent: width * 0.0225,
                                  ),
                                  // OUT OF STOCK
                                  SizedBox(
                                    width: width,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.0225,
                                        vertical: width * 0.0125,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Out Of Stock",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.06,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Checkbox(
                                            activeColor: primaryDark,
                                            checkColor: white,
                                            value: !isAvailable,
                                            onChanged: (value) async {
                                              await store
                                                  .collection('Business')
                                                  .doc('Data')
                                                  .collection('Products')
                                                  .doc(widget.productId)
                                                  .update({
                                                'isAvailable': !value!,
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(),

                          // DESCRIPTION
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.0166,
                              horizontal: width * 0.0166,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: width * 0.0225,
                                horizontal: width * 0.0225,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: width * 0.75,
                                    child: Text(
                                      productData['productDescription'] !=
                                                  null &&
                                              productData[
                                                      'productDescription'] !=
                                                  '' &&
                                              productData[
                                                      'productDescription'] !=
                                                  '0'
                                          ? productData['productDescription']
                                          : 'No Description',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 20,
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.0575,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // CHANGE DESCRIPTION
                                  IconButton(
                                    onPressed: () async {
                                      await edit(
                                        'productDescription',
                                        1,
                                        false,
                                        true,
                                      );
                                    },
                                    icon: const Icon(FeatherIcons.edit),
                                    tooltip: "Change Category",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(),

                          // CATEGORY
                          category.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: width * 0.0166,
                                    horizontal: width * 0.0166,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: width * 0.0225,
                                      horizontal: width * 0.0225,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) =>
                                                    CategoryPage(
                                                      categoryName: productData[
                                                          'categoryName'],
                                                    )),
                                              ),
                                            );
                                          },
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          splashColor: primary2,
                                          child: Row(
                                            children: [
                                              // CATEGORY IMAGE
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  4,
                                                ),
                                                child: Image.network(
                                                  categoryExists
                                                      ? productData[
                                                                  'categoryName'] !=
                                                              '0'
                                                          ? category[1]
                                                          : 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png'
                                                      : 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                                  fit: BoxFit.cover,
                                                  width: categoryExists
                                                      ? productData[
                                                                  'categoryName'] !=
                                                              '0'
                                                          ? width * 0.14
                                                          : width * 0.1
                                                      : width * 0.1,
                                                  height: categoryExists
                                                      ? productData[
                                                                  'categoryName'] !=
                                                              '0'
                                                          ? width * 0.14
                                                          : width * 0.1
                                                      : width * 0.1,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.05),
                                              // CATEGORY NAME
                                              SizedBox(
                                                width: width * 0.4,
                                                child: AutoSizeText(
                                                  categoryExists
                                                      ? productData[
                                                          'categoryName']
                                                      : 'No Category',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.0575,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // CHANGE CATEGORY
                                        IconButton(
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) =>
                                                    ChangeCategory(
                                                      productId: productData[
                                                          'productId'],
                                                      shopType: category[2],
                                                      productName: productData[
                                                          'productName'],
                                                    )),
                                              ),
                                            );
                                            await getCategoryInfo();
                                            setState(() {});
                                          },
                                          icon: const Icon(FeatherIcons.edit),
                                          tooltip: "Change Category",
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  // width: width,
                                  // height: width * 0.2,
                                  // alignment: Alignment.center,
                                  // padding: EdgeInsets.all(width * 0.0225),
                                  // decoration: BoxDecoration(
                                  //   color: Colors.grey.shade200,
                                  //   borderRadius: BorderRadius.circular(12),
                                  // ),
                                  // child: Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Row(
                                  //       children: [
                                  //         SkeletonContainer(
                                  //           width: width * 0.15,
                                  //           height: width * 0.15,
                                  //         ),
                                  //         SizedBox(width: width * 0.0225),
                                  //         SkeletonContainer(
                                  //           width: width * 0.3,
                                  //           height: width * 0.05,
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     SkeletonContainer(
                                  //       width: width * 0.1,
                                  //       height: width * 0.1,
                                  //     ),
                                  //   ],
                                  // ),
                                  ),

                          const Divider(),

                          // BRAND
                          InfoBox(
                            text: "Brand",
                            value: brand,
                          ),

                          const Divider(),

                          // PROPERTY 0
                          propertyName0 != ''
                              ? InfoEditBox(
                                  head: propertyName0,
                                  content: propertyValue0.isNotEmpty
                                      ? propertyValue0[0]
                                      : 'N/A',
                                  noOfAnswers: propertyNoOfAnswers0,
                                  propertyValue: propertyValue0,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue0',
                                      propertyNoOfAnswers0,
                                      true,
                                      propertyInputType0,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 1
                          propertyName1 != ''
                              ? InfoEditBox(
                                  head: propertyName1,
                                  content: propertyValue1.isNotEmpty
                                      ? propertyValue1[0]
                                      : 'N/A',
                                  noOfAnswers: propertyNoOfAnswers1,
                                  propertyValue: propertyValue1,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue1',
                                      propertyNoOfAnswers1,
                                      true,
                                      propertyInputType1,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 2
                          propertyName2 != ''
                              ? InfoEditBox(
                                  head: propertyName2,
                                  content: propertyValue2.isNotEmpty
                                      ? propertyValue2[0]
                                      : 'N/A',
                                  noOfAnswers: propertyNoOfAnswers2,
                                  propertyValue: propertyValue2,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue2',
                                      propertyNoOfAnswers2,
                                      true,
                                      propertyInputType2,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 3
                          propertyName3 != ''
                              ? InfoEditBox(
                                  head: propertyName3,
                                  content: propertyValue3.isNotEmpty
                                      ? propertyValue3[0]
                                      : 'N/A',
                                  propertyValue: propertyValue3,
                                  noOfAnswers: propertyNoOfAnswers3,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue3',
                                      propertyNoOfAnswers3,
                                      true,
                                      propertyInputType3,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 4
                          propertyName4 != ''
                              ? InfoEditBox(
                                  head: propertyName4,
                                  content: propertyValue4.isNotEmpty
                                      ? propertyValue4[0]
                                      : 'N/A',
                                  propertyValue: propertyValue4,
                                  noOfAnswers: propertyNoOfAnswers4,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue4',
                                      propertyNoOfAnswers4,
                                      true,
                                      propertyInputType4,
                                    );
                                  },
                                )
                              : Container(),

                          // PROPERTY 5
                          propertyName5 != ''
                              ? InfoEditBox(
                                  head: propertyName5,
                                  content: propertyValue5.isNotEmpty
                                      ? propertyValue5[0]
                                      : 'N/A',
                                  propertyValue: propertyValue5,
                                  noOfAnswers: propertyNoOfAnswers5,
                                  width: width,
                                  onPressed: () async {
                                    await edit(
                                      'propertyValue5',
                                      propertyNoOfAnswers5,
                                      true,
                                      propertyInputType5,
                                    );
                                  },
                                )
                              : Container(),

                          const Divider(),

                          // TAGS
                          InfoEditBox(
                            head: "Tags",
                            content: tags,
                            propertyValue: tags,
                            noOfAnswers: 3,
                            width: width,
                            onPressed: () async {
                              await edit(
                                'Tags',
                                3,
                                false,
                                true,
                              );
                            },
                          ),

                          const Divider(),

                          // LIKES & VIEWS
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // LIKES
                                InfoColorBox(
                                  text: 'LIKES',
                                  width: width,
                                  property: likes,
                                  color: const Color.fromRGBO(189, 225, 255, 1),
                                ), // VIEWS
                                InfoColorBox(
                                  text: 'VIEWS',
                                  width: width,
                                  property: views,
                                  color: const Color.fromRGBO(255, 248, 184, 1),
                                ),
                              ],
                            ),
                          ),

                          // SHARES & SHARES
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // SHARES
                                InfoColorBox(
                                  text: 'SHARES',
                                  width: width,
                                  property: shares,
                                  color: const Color.fromRGBO(193, 255, 195, 1),
                                ), // WISHLIST
                                InfoColorBox(
                                  text: 'WISHLIST',
                                  width: width,
                                  property: wishList,
                                  color: const Color.fromRGBO(255, 176, 170, 1),
                                ),
                              ],
                            ),
                          ),

                          // VIEW ALL INSIGHTS
                          Padding(
                            padding: EdgeInsets.only(
                              top: width * 0.0125,
                              bottom: width * 0.0125,
                              left: width * 0.025,
                            ),
                            child: InkWell(
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              radius: width * 0.2,
                              splashColor: primary2,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: ((context) =>
                                        const AnalyticsPage()),
                                  ),
                                );
                              },
                              child: Container(
                                width: width * 0.95,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.033,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.5,
                                        child: Text(
                                          "View All Products Insights",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: primaryDark2,
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        FeatherIcons.chevronRight,
                                        size: width * 0.095,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryDark,
                      ),
                    );
                  }),
            );
          }),
        ),
      ),
    );
  }
}
