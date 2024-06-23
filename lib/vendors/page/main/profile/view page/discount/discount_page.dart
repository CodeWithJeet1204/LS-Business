import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/profile/view%20page/brand/brand_page.dart';
import 'package:localy/vendors/page/main/profile/view%20page/category/category_page.dart';
import 'package:localy/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/info_edit_box.dart';
import 'package:localy/widgets/shimmer_skeleton_container.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({
    super.key,
    required this.discountId,
    required this.discountImageUrl,
  });

  final String discountId;
  final String? discountImageUrl;

  @override
  State<DiscountPage> createState() => DISCOUNT();
}

class DISCOUNT extends State<DiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final discountNameKey = GlobalKey<FormState>();
  final searchController = TextEditingController();
  bool isCategoryGridView = true;
  bool isImageChanging = false;
  bool isChangingName = false;
  bool isFit = false;
  bool isAddingImage = false;
  bool isGridView = true;

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // IMAGE FIT CHANGE
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // ADD DISCOUNT IMAGE
  Future<void> addDiscountImage() async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      String? imageUrl;
      try {
        setState(() {
          isAddingImage = true;
        });
        Reference ref =
            storage.ref().child('Data/Products').child(const Uuid().v4());
        await ref.putFile(File(im.path)).whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            setState(() {
              imageUrl = value;
            });
          });
        });
        await store
            .collection('Business')
            .doc('Data')
            .collection('Discounts')
            .doc(widget.discountId)
            .update({
          'discountImageUrl': imageUrl,
        });
        setState(() {
          isAddingImage = false;
        });
      } catch (e) {
        setState(() {
          isAddingImage = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // CHANGE DISCOUNT IMAGE
  Future<void> changeDiscountImage(String imageUrl) async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      try {
        setState(() {
          isImageChanging = true;
        });
        Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
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
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // REMOVE DISCOUNT IMAGE
  Future<void> removeDiscountImage(String imageUrl) async {
    try {
      setState(() {
        isImageChanging = true;
      });
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await store
          .collection('Business')
          .doc('Data')
          .collection('Discounts')
          .doc(widget.discountId)
          .update({
        'discountImageUrl': null,
      });
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
  }

  // CONFIRMING TO DELETE
  Future<void> confirmDelete(String discountId, String? imageUrl) async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Confirm DELETE',
          ),
          content: const Text(
            'Are you sure you want to delete this Discount\nDiscount will be removed from all the products/categories with this discount',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await delete(discountId, imageUrl);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'YES',
                maxLines: 1,
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

  // DELETE DISCOUNT
  Future<void> delete(String discountId, String? imageUrl) async {
    try {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (imageUrl != null) {
        await storage.refFromURL(imageUrl).delete();
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Discounts')
          .doc(discountId)
          .delete();
      if (mounted) {
        mySnackBar(context, 'Discount Deleted');
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // DISCOUNT NAME CHANGE BACKEND
  Future<void> changeDiscount(
      String newName, String propertyName, TextInputType keyboardType) async {
    if (discountNameKey.currentState!.validate()) {
      try {
        setState(() {
          isChangingName = true;
        });
        await store
            .collection('Business')
            .doc('Data')
            .collection('Discounts')
            .doc(widget.discountId)
            .update({
          propertyName: newName,
        });
        setState(() {
          isChangingName = false;
        });
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // GET PRODUCT DATA
  Future<List<Map<String, dynamic>>> getProductData() async {
    List<Map<String, dynamic>> myProducts = [];

    final productsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .get();

    productsSnap.docs.forEach((product) {
      final productData = product.data();

      if (productData['discountId'] == widget.discountId) {
        myProducts.add(productData);
      }
    });

    return myProducts;
  }

  // GET BRAND DATA
  Future<List<Map<String, dynamic>>> getBrandData() async {
    List<Map<String, dynamic>> myBrands = [];

    final brandsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .get();

    brandsSnap.docs.forEach((brand) {
      final brandData = brand.data();

      if (brandData['discountId'] == widget.discountId) {
        myBrands.add(brandData);
      }
    });

    return myBrands;
  }

  // GET CATEGORY DATA
  Future<List<Map<String, dynamic>>> getCategoryData() async {
    List<Map<String, dynamic>> myCategories = [];
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final type = vendorData['Type'];

    final categorySnap = await store
        .collection('Business')
        .doc('Special Categories')
        .collection(type)
        .get();

    categorySnap.docs.forEach((category) {
      final categoryData = category.data();

      if (categoryData['discountId'] != null &&
          categoryData['discountId'] == widget.discountId) {
        myCategories.add(categoryData);
      }
    });

    return myCategories;
  }

  // DISCOUNT NAME CHANGE
  Future<void> change(String propertyName, TextInputType keyboardType) async {
    await showDialog(
      context: context,
      builder: (context) {
        final propertyStream = FirebaseFirestore.instance
            .collection('Business')
            .doc('Data')
            .collection('Discounts')
            .doc(widget.discountId)
            .snapshots();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            height: 180,
            child: StreamBuilder(
              stream: propertyStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Something went wrong',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }

                if (snapshot.hasData) {
                  final discountData = snapshot.data!;
                  String discountProperty =
                      discountData[propertyName].toString();

                  return Form(
                    key: discountNameKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            initialValue: discountProperty,
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            decoration: const InputDecoration(
                              hintText: 'Discount Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              discountProperty = value;
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return 'Enter Discount Name';
                              }
                            },
                          ),
                          MyButton(
                            text: 'SAVE',
                            onTap: () async {
                              await changeDiscount(
                                discountProperty,
                                propertyName,
                                keyboardType,
                              );
                            },
                            isLoading: isChangingName,
                            horizontalPadding: 0,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // CHANGE START DATE
  Future<void> changeStartDate(DateTime initalDate) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: initalDate,
      lastDate: DateTime(2026, 12, 31),
    );

    if (newDate != null) {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Discounts')
          .doc(widget.discountId)
          .update({
        'discountStartDateTime': newDate,
      });
    }
  }

  // CHANGE END DATE
  Future<void> changeEndDate(DateTime initalDate) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: initalDate,
      lastDate: DateTime(2026, 12, 31),
    );

    if (newDate != null) {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Discounts')
          .doc(widget.discountId)
          .update({
        'discountEndDateTime': newDate,
      });
    }
  }

  // REMOVE CATEGORY FROM DISCOUNT
  // Future<void> remove(String productId, String productName, String categoryName) async {
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(
  //           'Remove $productName',
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         content: Text(
  //           'Are you sure you want to remove $productName from $categoryName',
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         actions: [
  //           MyTextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             text: 'NO',
  //             textColor: Colors.green,
  //           ),
  //           MyTextButton(
  //             onPressed: () async {
  //               try {
  //                 await store
  //                     .collection('Business')
  //                     .doc('Data')
  //                     .collection('Products')
  //                     .doc(productId)
  //                     .update({
  //                   'specialCategoryName': '0',
  //                   'specialCategoryName': 'No Category Selected',
  //                 });
  //                 if (mounted) {
  //                   Navigator.of(context).pop();
  //                 }
  //               } catch (e) {
  //                 if (mounted) {
  //                   mySnackBar(context, e.toString());
  //                 }
  //               }
  //             },
  //             text: 'YES',
  //             textColor: Colors.red,
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final discountStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await confirmDelete(
                widget.discountId,
                widget.discountImageUrl,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(
              FeatherIcons.trash,
              color: Colors.red,
            ),
            color: Colors.red,
            tooltip: 'End Discount',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            isAddingImage ? 10 : 0,
          ),
          child: isAddingImage ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;

          return SingleChildScrollView(
            child: StreamBuilder(
              stream: discountStream,
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Something went wrong',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }

                if (snapshot.hasData) {
                  final discountData = snapshot.data!;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.0225,
                      vertical: width * 0.0125,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        discountData['discountImageUrl'] != null
                            ? Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    width: width,
                                    height: width * 9 / 16,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: primaryDark2,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: isImageChanging
                                        ? const CircularProgressIndicator()
                                        : GestureDetector(
                                            onTap: changeFit,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                              child: InteractiveViewer(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          discountData[
                                                              'discountImageUrl'],
                                                        ),
                                                        fit: isFit
                                                            ? null
                                                            : BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),

                                  // IMAGE CHANGING INDICATOR
                                  isImageChanging
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: width * 0.0125,
                                                top: width * 0.0125,
                                              ),
                                              child: IconButton.filledTonal(
                                                onPressed: () async {
                                                  await changeDiscountImage(
                                                    discountData[
                                                        'discountImageUrl'],
                                                  );
                                                },
                                                icon: Icon(
                                                  FeatherIcons.camera,
                                                  size: width * 0.1,
                                                ),
                                                tooltip: 'Change Image',
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: width * 0.0125,
                                                top: width * 0.0125,
                                              ),
                                              child: IconButton.filledTonal(
                                                onPressed: () async {
                                                  await removeDiscountImage(
                                                    discountData[
                                                        'discountImageUrl'],
                                                  );
                                                },
                                                icon: Icon(
                                                  FeatherIcons.x,
                                                  size: width * 0.1,
                                                ),
                                                tooltip: 'Remove Image',
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              )
                            : Center(
                                child: MyTextButton(
                                  onPressed: () async {
                                    await addDiscountImage();
                                  },
                                  text: 'Add Image',
                                  textColor: primaryDark,
                                ),
                              ),
                        const SizedBox(height: 28),

                        // NAME
                        InfoEditBox(
                          head: 'NAME',
                          noOfAnswers: 1,
                          content: discountData['discountName'],
                          propertyValue: const [],
                          width: width,
                          onPressed: () {
                            change('discountName', TextInputType.name);
                          },
                        ),

                        // AMOUNT
                        InfoEditBox(
                          head: 'AMOUNT',
                          noOfAnswers: 1,
                          content: discountData['discountAmount'].toString(),
                          propertyValue: const [],
                          width: width,
                          onPressed: () async {
                            await change(
                              'discountAmount',
                              TextInputType.number,
                            );
                          },
                        ),

                        // START DATE
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: width * 0.0133,
                            horizontal: width * 0.01,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.025,
                              horizontal: width * 0.025,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start Date',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryDark2,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      DateFormat('d MMM yy').format(
                                        discountData['discountStartDateTime']
                                            .toDate(),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: width * 0.05833,
                                        fontWeight: FontWeight.w600,
                                        color: primaryDark,
                                      ),
                                    )
                                  ],
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await changeStartDate(
                                      (discountData['discountStartDateTime']
                                              as Timestamp)
                                          .toDate(),
                                    );
                                  },
                                  icon: const Icon(
                                    FeatherIcons.edit,
                                    color: primaryDark,
                                  ),
                                  tooltip: 'Change Start Date',
                                ),
                              ],
                            ),
                          ),
                        ),

                        // END DATE
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: width * 0.0133,
                            horizontal: width * 0.01,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.025,
                              horizontal: width * 0.025,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'End Date',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryDark2,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      DateFormat('d MMM yy').format(
                                        discountData['discountEndDateTime']
                                            .toDate(),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: width * 0.05833,
                                        fontWeight: FontWeight.w600,
                                        color: primaryDark,
                                      ),
                                    )
                                  ],
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await changeEndDate(
                                      (discountData['discountEndDateTime']
                                              as Timestamp)
                                          .toDate(),
                                    );
                                  },
                                  icon: const Icon(
                                    FeatherIcons.edit,
                                    color: primaryDark,
                                  ),
                                  tooltip: 'Change End Date',
                                ),
                              ],
                            ),
                          ),
                        ),

                        // PERCENT VS PRICE
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.025,
                            vertical: width * 0.0125,
                          ),
                          margin: EdgeInsets.only(left: width * 0.03125),
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton(
                            style: TextStyle(
                              color: primaryDark2,
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.055,
                            ),
                            dropdownColor: primary2,
                            hint: Text(
                              discountData['isPercent']
                                  ? 'Percent %'
                                  : 'Price Rs.',
                              style: const TextStyle(
                                color: primaryDark,
                              ),
                            ),
                            iconEnabledColor: primaryDark,
                            iconDisabledColor: primaryDark,
                            underline: const SizedBox(),
                            items: ['Percent', 'Price']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) async {
                              await store
                                  .collection('Business')
                                  .doc('Data')
                                  .collection('Discounts')
                                  .doc(widget.discountId)
                                  .update({
                                'isPercent': value == 'Percent' ? true : false,
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // PRODUCTS
                        discountData['isProducts']
                            ? ExpansionTile(
                                initiallyExpanded: true,
                                tilePadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0225,
                                ),
                                backgroundColor: primary2.withOpacity(0.25),
                                collapsedBackgroundColor:
                                    primary2.withOpacity(0.33),
                                textColor: primaryDark.withOpacity(0.9),
                                collapsedTextColor: primaryDark,
                                iconColor: primaryDark2.withOpacity(0.9),
                                collapsedIconColor: primaryDark2,
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryDark.withOpacity(0.1),
                                  ),
                                ),
                                collapsedShape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryDark.withOpacity(0.33),
                                  ),
                                ),
                                title: Text(
                                  'Products',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isGridView = !isGridView;
                                    });
                                  },
                                  icon: Icon(isGridView
                                      ? FeatherIcons.list
                                      : FeatherIcons.grid),
                                  tooltip: isGridView ? "List" : "Grid",
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.0125,
                                      vertical: width * 0.0125,
                                    ),
                                    child: FutureBuilder(
                                      future: getProductData(),
                                      builder: ((context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                              'Something went wrong',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }

                                        if (snapshot.hasData) {
                                          return SafeArea(
                                            child: isGridView
                                                ? GridView.builder(
                                                    shrinkWrap: true,
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      childAspectRatio: 0.675,
                                                    ),
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final productData =
                                                          snapshot.data![index];

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  ((context) =>
                                                                      ProductPage(
                                                                        productId:
                                                                            productData['productId'],
                                                                        productName:
                                                                            productData['productName'],
                                                                      )),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primary2
                                                                .withOpacity(
                                                              0.125,
                                                            ),
                                                            border: Border.all(
                                                              width: 0.25,
                                                              color:
                                                                  primaryDark,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              2,
                                                            ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.00625,
                                                          ),
                                                          margin:
                                                              EdgeInsets.all(
                                                            width * 0.00625,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Center(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    2,
                                                                  ),
                                                                  child: Image
                                                                      .network(
                                                                    productData[
                                                                        'images'][0],
                                                                    width:
                                                                        width *
                                                                            0.5,
                                                                    height:
                                                                        width *
                                                                            0.5,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              width * 0.275,
                                                                          child:
                                                                              Text(
                                                                            productData['productName'],
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: width * 0.05,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          productData['productPrice'] != '' && productData['productPrice'] != null
                                                                              ? 'Rs. ${productData['productPrice']}'
                                                                              : 'N/A',
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.04,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      // remove(
                                                                      //   productData[
                                                                      //       'productId'],
                                                                      //   productData[
                                                                      //       'productName'],
                                                                      //   widget
                                                                      //       .categoryName,
                                                                      // );
                                                                    },
                                                                    icon: Icon(
                                                                      FeatherIcons
                                                                          .x,
                                                                      color: const Color
                                                                          .fromARGB(
                                                                        255,
                                                                        215,
                                                                        14,
                                                                        0,
                                                                      ),
                                                                      size: width *
                                                                          0.075,
                                                                    ),
                                                                    tooltip:
                                                                        'Remove Product',
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    })
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      final productData =
                                                          snapshot.data![index];

                                                      return Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              width * 0.000625,
                                                          vertical:
                                                              width * 0.02,
                                                        ),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    ((context) =>
                                                                        ProductPage(
                                                                          productId:
                                                                              productData['productId'],
                                                                          productName:
                                                                              productData['productName'],
                                                                        )),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: white,
                                                              border:
                                                                  Border.all(
                                                                width: 0.5,
                                                                color:
                                                                    primaryDark,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                2,
                                                              ),
                                                            ),
                                                            child: ListTile(
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .standard,
                                                              leading:
                                                                  ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  4,
                                                                ),
                                                                child: Image
                                                                    .network(
                                                                  productData[
                                                                      'images'][0],
                                                                  width: width *
                                                                      0.15,
                                                                  height:
                                                                      width *
                                                                          0.15,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              title: Text(
                                                                productData[
                                                                    'productName'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      width *
                                                                          0.0525,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                productData['productPrice'] !=
                                                                            '' &&
                                                                        productData['productPrice'] !=
                                                                            null
                                                                    ? productData[
                                                                        'productPrice']
                                                                    : 'N/A',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      width *
                                                                          0.035,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  // remove(
                                                                  //   productData[
                                                                  //       'productId'],
                                                                  //   productData[
                                                                  //       'productName'],
                                                                  //   widget.categoryName,
                                                                  // );
                                                                },
                                                                icon: Icon(
                                                                  FeatherIcons
                                                                      .x,
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                    215,
                                                                    14,
                                                                    0,
                                                                    1,
                                                                  ),
                                                                  size: width *
                                                                      0.08,
                                                                ),
                                                                tooltip:
                                                                    'Remove Product',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                          );
                                        }

                                        return SafeArea(
                                          child: isGridView
                                              ? GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 0,
                                                    mainAxisSpacing: 0,
                                                    childAspectRatio: width *
                                                        0.5 /
                                                        width *
                                                        1.45,
                                                  ),
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: width * 0.02,
                                                        horizontal:
                                                            width * 0.00575,
                                                      ),
                                                      child: GridViewSkeleton(
                                                        width: width,
                                                        isPrice: true,
                                                        isDelete: true,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding: EdgeInsets.all(
                                                        width * 0.02,
                                                      ),
                                                      child: ListViewSkeleton(
                                                        width: width,
                                                        isPrice: true,
                                                        height: 30,
                                                        isDelete: true,
                                                      ),
                                                    );
                                                  },
                                                ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),

                        // BRANDS
                        discountData['isBrands']
                            ? ExpansionTile(
                                initiallyExpanded: true,
                                tilePadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0225,
                                ),
                                backgroundColor: primary2.withOpacity(0.25),
                                collapsedBackgroundColor:
                                    primary2.withOpacity(0.33),
                                textColor: primaryDark.withOpacity(0.9),
                                collapsedTextColor: primaryDark,
                                iconColor: primaryDark2.withOpacity(0.9),
                                collapsedIconColor: primaryDark2,
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryDark.withOpacity(0.1),
                                  ),
                                ),
                                collapsedShape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryDark.withOpacity(0.33),
                                  ),
                                ),
                                title: Text(
                                  'Brands',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isGridView = !isGridView;
                                    });
                                  },
                                  icon: Icon(isGridView
                                      ? FeatherIcons.list
                                      : FeatherIcons.grid),
                                  tooltip: isGridView ? "List" : "Grid",
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                      width * 0.0125,
                                    ),
                                    child: FutureBuilder(
                                      future: getBrandData(),
                                      builder: ((context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                              'Something went wrong',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }

                                        if (snapshot.hasData) {
                                          return SafeArea(
                                            child: isGridView
                                                ? GridView.builder(
                                                    shrinkWrap: true,
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      childAspectRatio: 0.695,
                                                    ),
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final brandData =
                                                          snapshot.data![index];

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  ((context) =>
                                                                      BrandPage(
                                                                        brandId:
                                                                            brandData['brandId'],
                                                                        brandName:
                                                                            brandData['brandName'],
                                                                        imageUrl:
                                                                            brandData['imageUrl'],
                                                                      )),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primary2
                                                                .withOpacity(
                                                              0.125,
                                                            ),
                                                            border: Border.all(
                                                              width: 0.25,
                                                              color:
                                                                  primaryDark,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              2,
                                                            ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.00625,
                                                          ),
                                                          margin:
                                                              EdgeInsets.all(
                                                            width * 0.00625,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Center(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    2,
                                                                  ),
                                                                  child: Image
                                                                      .network(
                                                                    brandData[
                                                                        'imageUrl'],
                                                                    width:
                                                                        width *
                                                                            0.5,
                                                                    height:
                                                                        width *
                                                                            0.5,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          brandData[
                                                                              'brandName'],
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.055,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      // remove(
                                                                      //   productData[
                                                                      //       'productId'],
                                                                      //   productData[
                                                                      //       'productName'],
                                                                      //   widget
                                                                      //       .categoryName,
                                                                      // );
                                                                    },
                                                                    icon: Icon(
                                                                      FeatherIcons
                                                                          .x,
                                                                      color: const Color
                                                                          .fromARGB(
                                                                        255,
                                                                        215,
                                                                        14,
                                                                        0,
                                                                      ),
                                                                      size: width *
                                                                          0.09,
                                                                    ),
                                                                    tooltip:
                                                                        'Remove Brand',
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    })
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      final brandData =
                                                          snapshot.data![index];
                                                      return Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              width * 0.000625,
                                                          vertical:
                                                              width * 0.02,
                                                        ),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    ((context) =>
                                                                        BrandPage(
                                                                          brandId:
                                                                              brandData['brandId'],
                                                                          brandName:
                                                                              brandData['brandName'],
                                                                          imageUrl:
                                                                              brandData['imageUrl'],
                                                                        )),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: white,
                                                              border:
                                                                  Border.all(
                                                                width: 0.5,
                                                                color:
                                                                    primaryDark,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                2,
                                                              ),
                                                            ),
                                                            child: ListTile(
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .standard,
                                                              leading:
                                                                  ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  4,
                                                                ),
                                                                child: Image
                                                                    .network(
                                                                  brandData[
                                                                      'imageUrl'],
                                                                  width: width *
                                                                      0.15,
                                                                  height:
                                                                      width *
                                                                          0.15,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              title: Text(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                brandData[
                                                                    'brandName'],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      width *
                                                                          0.0525,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  // remove(
                                                                  //   productData[
                                                                  //       'productId'],
                                                                  //   productData[
                                                                  //       'productName'],
                                                                  //   widget.categoryName,
                                                                  // );
                                                                },
                                                                icon: Icon(
                                                                  FeatherIcons
                                                                      .x,
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                    215,
                                                                    14,
                                                                    0,
                                                                    1,
                                                                  ),
                                                                  size: width *
                                                                      0.09,
                                                                ),
                                                                tooltip:
                                                                    'Remove Brand',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                          );
                                        }

                                        return SafeArea(
                                          child: isGridView
                                              ? GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 0,
                                                    mainAxisSpacing: 0,
                                                    childAspectRatio: width *
                                                        0.5 /
                                                        width *
                                                        1.545,
                                                  ),
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: width * 0.02,
                                                        horizontal:
                                                            width * 0.00575,
                                                      ),
                                                      child: GridViewSkeleton(
                                                        width: width,
                                                        isPrice: false,
                                                        isDelete: true,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding: EdgeInsets.all(
                                                        width * 0.02,
                                                      ),
                                                      child: ListViewSkeleton(
                                                        width: width,
                                                        isPrice: false,
                                                        height: 30,
                                                        isDelete: true,
                                                      ),
                                                    );
                                                  },
                                                ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),

                        // CATEGORY
                        discountData['isCategories']
                            ? ExpansionTile(
                                initiallyExpanded: true,
                                tilePadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0225,
                                ),
                                backgroundColor: primary2.withOpacity(0.25),
                                collapsedBackgroundColor:
                                    primary2.withOpacity(0.33),
                                textColor: primaryDark.withOpacity(0.9),
                                collapsedTextColor: primaryDark,
                                iconColor: primaryDark2.withOpacity(0.9),
                                collapsedIconColor: primaryDark2,
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryDark.withOpacity(0.1),
                                  ),
                                ),
                                collapsedShape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryDark.withOpacity(0.33),
                                  ),
                                ),
                                title: Text(
                                  'Categories',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isGridView = !isGridView;
                                    });
                                  },
                                  icon: Icon(isGridView
                                      ? FeatherIcons.list
                                      : FeatherIcons.grid),
                                  tooltip: isGridView ? "List" : "Grid",
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                      width * 0.0125,
                                    ),
                                    child: FutureBuilder(
                                      future: getCategoryData(),
                                      builder: ((context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                              'Something went wrong',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }

                                        if (snapshot.hasData) {
                                          return SafeArea(
                                            child: isGridView
                                                ? GridView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        ClampingScrollPhysics(),
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      childAspectRatio: 0.695,
                                                    ),
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final categoryData =
                                                          snapshot.data![index];

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  ((context) =>
                                                                      CategoryPage(
                                                                        categoryName:
                                                                            categoryData['specialCategoryName'],
                                                                      )),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primary2
                                                                .withOpacity(
                                                              0.125,
                                                            ),
                                                            border: Border.all(
                                                              width: 0.25,
                                                              color:
                                                                  primaryDark,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              2,
                                                            ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.00625,
                                                          ),
                                                          margin:
                                                              EdgeInsets.all(
                                                            width * 0.00625,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Center(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    2,
                                                                  ),
                                                                  child: Image
                                                                      .network(
                                                                    categoryData[
                                                                        'specialCategoryImageUrl'],
                                                                    width:
                                                                        width *
                                                                            0.5,
                                                                    height:
                                                                        width *
                                                                            0.5,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          categoryData[
                                                                              'specialCategoryName'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.055,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      // remove(
                                                                      //   productData[
                                                                      //       'productId'],
                                                                      //   productData[
                                                                      //       'productName'],
                                                                      //   widget
                                                                      //       .categoryName,
                                                                      // );
                                                                    },
                                                                    icon: Icon(
                                                                      FeatherIcons
                                                                          .x,
                                                                      color: const Color
                                                                          .fromARGB(
                                                                        255,
                                                                        215,
                                                                        14,
                                                                        0,
                                                                      ),
                                                                      size: width *
                                                                          0.075,
                                                                    ),
                                                                    tooltip:
                                                                        'Remove Category',
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    })
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      final categoryData =
                                                          snapshot.data![index];

                                                      return Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              width * 0.000625,
                                                          vertical:
                                                              width * 0.02,
                                                        ),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    ((context) =>
                                                                        CategoryPage(
                                                                          categoryName:
                                                                              categoryData['specialCategoryName'],
                                                                        )),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: white,
                                                              border:
                                                                  Border.all(
                                                                width: 0.5,
                                                                color:
                                                                    primaryDark,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                2,
                                                              ),
                                                            ),
                                                            child: ListTile(
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .standard,
                                                              leading:
                                                                  ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  4,
                                                                ),
                                                                child: Image
                                                                    .network(
                                                                  categoryData[
                                                                      'specialCategoryImageUrl'],
                                                                  width: width *
                                                                      0.1125,
                                                                  height: width *
                                                                      0.1125,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              title: Text(
                                                                categoryData[
                                                                    'specialCategoryName'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      width *
                                                                          0.0525,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  // remove(
                                                                  //   productData[
                                                                  //       'productId'],
                                                                  //   productData[
                                                                  //       'productName'],
                                                                  //   widget.categoryName,
                                                                  // );
                                                                },
                                                                icon: Icon(
                                                                  FeatherIcons
                                                                      .x,
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                    215,
                                                                    14,
                                                                    0,
                                                                    1,
                                                                  ),
                                                                  size: width *
                                                                      0.09,
                                                                ),
                                                                tooltip:
                                                                    'Remove Category',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                          );
                                        }

                                        return SafeArea(
                                          child: isGridView
                                              ? GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 0,
                                                    mainAxisSpacing: 0,
                                                    childAspectRatio: width *
                                                        0.5 /
                                                        width *
                                                        1.545,
                                                  ),
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: width * 0.02,
                                                      ),
                                                      child: GridViewSkeleton(
                                                        width: width,
                                                        isPrice: false,
                                                        isDelete: true,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding: EdgeInsets.all(
                                                        width * 0.02,
                                                      ),
                                                      child: ListViewSkeleton(
                                                        width: width,
                                                        isPrice: false,
                                                        height: 30,
                                                        isDelete: true,
                                                      ),
                                                    );
                                                  },
                                                ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
