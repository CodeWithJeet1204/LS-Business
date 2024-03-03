import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/page/main/profile/view%20page/brand/brand_page.dart';
import 'package:find_easy/page/main/profile/view%20page/category/category_page.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/info_edit_box.dart';
import 'package:find_easy/widgets/product_grid_view_skeleton.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
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
  void addDiscountImage() async {
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
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // CHANGE DISCOUNT IMAGE
  void changeDiscountImage(String imageUrl) async {
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
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // REMOVE DISCOUNT IMAGE
  void removeDiscountImage(String imageUrl) async {
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
      if (context.mounted) {
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
            "Confirm DELETE",
            overflow: TextOverflow.ellipsis,
          ),
          content: const Text(
            "Are you sure you want to delete this Discount\nDiscount will be removed from all the products/categories with this discount",
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
                await delete(discountId, imageUrl);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
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

  // DELETE DISCOUNT
  Future<void> delete(String discountId, String? imageUrl) async {
    try {
      if (imageUrl != null) {
        await storage.refFromURL(imageUrl).delete();
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Discounts')
          .doc(discountId)
          .delete();
    } catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // DISCOUNT NAME CHANGE BACKEND
  void changeDiscount(
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
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // DISCOUNT NAME CHANGE
  void change(String propertyName, TextInputType keyboardType) {
    showDialog(
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
                            decoration: const InputDecoration(
                              hintText: "Discount Name",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              discountProperty = value;
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return "Enter Discount Name";
                              }
                            },
                          ),
                          MyButton(
                            text: "SAVE",
                            onTap: () {
                              changeDiscount(
                                  discountProperty, propertyName, keyboardType);
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
  void changeStartDate(DateTime initalDate) async {
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
        'discountStartDate': DateFormat('d MMM yy').format(newDate),
        'discountStartDateTime': newDate,
      });
    }
  }

  // CHANGE END DATE
  void changeEndDate(DateTime initalDate) async {
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
        'discountEndDate': DateFormat('d MMM yy').format(newDate),
        'discountEndDateTime': newDate,
      });
    }
  }

  // REMOVE CATEGORY FROM DISCOUNT
  void remove(String productId, String productName, String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Remove $productName",
            overflow: TextOverflow.ellipsis,
          ),
          content: Text(
            'Are you sure you want to remove $productName from $categoryName',
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: "NO",
              textColor: Colors.green,
            ),
            MyTextButton(
              onPressed: () async {
                try {
                  await store
                      .collection('Business')
                      .doc('Data')
                      .collection('Products')
                      .doc(productId)
                      .update({
                    'categoryId': '0',
                    'categoryName': 'No Category Selected',
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    mySnackBar(context, e.toString());
                  }
                }
              },
              text: "YES",
              textColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final discountStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .doc(widget.discountId)
        .snapshots();

    // PRODUCTS STREAM
    final productDiscountStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .where('discountId', isEqualTo: widget.discountId)
        .where('productName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('productName', isLessThan: '${searchController.text}\uf8ff')
        .snapshots();

    // BRANDS STREAM
    final brandDiscountStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Brands')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .where('discountId', isEqualTo: widget.discountId)
        .where('brandName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('brandName', isLessThan: '${searchController.text}\uf8ff')
        .snapshots();

    // CATEGORY STREAM
    final categoryDiscountStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .where('discountId', isEqualTo: widget.discountId)
        .where('categoryName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('categoryName', isLessThan: '${searchController.text}\uf8ff')
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
            tooltip: "End Discount",
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
                                                child: CachedNetworkImage(
                                                  imageUrl: discountData[
                                                      'discountImageUrl'],
                                                  imageBuilder:
                                                      (context, imageProvider) {
                                                    return ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10,
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: isFit
                                                                ? BoxFit.cover
                                                                : null,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
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
                                                onPressed: () {
                                                  changeDiscountImage(
                                                    discountData[
                                                        'discountImageUrl'],
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
                                                onPressed: () {
                                                  removeDiscountImage(
                                                    discountData[
                                                        'discountImageUrl'],
                                                  );
                                                },
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
                              )
                            : Center(
                                child: MyTextButton(
                                  onPressed: addDiscountImage,
                                  text: "Add Image",
                                  textColor: primaryDark,
                                ),
                              ),
                        const SizedBox(height: 28),

                        // NAME
                        InfoEditBox(
                          head: "NAME",
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
                          head: "AMOUNT",
                          noOfAnswers: 1,
                          content: discountData['discountAmount'].toString(),
                          propertyValue: const [],
                          width: width,
                          onPressed: () {
                            change('discountAmount', TextInputType.number);
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
                                      "Start Date",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryDark2,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      discountData['discountStartDate'],
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
                                  onPressed: () {
                                    changeStartDate(
                                      (discountData['discountStartDateTime']
                                              as Timestamp)
                                          .toDate(),
                                    );
                                  },
                                  icon: const Icon(
                                    FeatherIcons.edit,
                                    color: primaryDark,
                                  ),
                                  tooltip: "Change Start Date",
                                )
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
                                      "End Date",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryDark2,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      discountData['discountEndDate'],
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
                                  onPressed: () {
                                    changeStartDate(
                                      (discountData['discountEndDateTime']
                                              as Timestamp)
                                          .toDate(),
                                    );
                                  },
                                  icon: const Icon(
                                    FeatherIcons.edit,
                                    color: primaryDark,
                                  ),
                                  tooltip: "Change End Date",
                                )
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
                            dropdownColor: primary,
                            hint: Text(
                              discountData['isPercent']
                                  ? 'Percent %'
                                  : 'Price Rs.',
                              overflow: TextOverflow.ellipsis,
                            ),
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
                                'isPercent': value == "Percent" ? true : false,
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
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.06,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.0225,
                                      vertical: width * 0.02125,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // TEXTFIELD
                                            Expanded(
                                              child: TextField(
                                                controller: searchController,
                                                autocorrect: false,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "Case - Sensitive",
                                                  hintText: "Search ...",
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isGridView = !isGridView;
                                                });
                                              },
                                              icon: Icon(
                                                isGridView
                                                    ? FeatherIcons.list
                                                    : FeatherIcons.grid,
                                              ),
                                              tooltip: isGridView
                                                  ? "List View"
                                                  : "Grid View",
                                            ),
                                          ],
                                        ),
                                        StreamBuilder(
                                          stream: productDiscountStream,
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Center(
                                                child: Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  "Something went wrong",
                                                ),
                                              );
                                            }

                                            if (snapshot.hasData) {
                                              return SafeArea(
                                                child: isGridView
                                                    // PRODUCTS IN GRIDVIEW
                                                    ? GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          crossAxisSpacing: 0,
                                                          mainAxisSpacing: 0,
                                                          childAspectRatio:
                                                              width *
                                                                  0.5 /
                                                                  width *
                                                                  1.5,
                                                        ),
                                                        itemCount: snapshot
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final productData =
                                                              snapshot.data!
                                                                  .docs[index];
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical:
                                                                  width * 0.025,
                                                              horizontal:
                                                                  width *
                                                                      0.0125,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        ((context) =>
                                                                            ProductPage(
                                                                              productId: productData['productId'],
                                                                              productName: productData['productName'],
                                                                            )),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: primary2
                                                                      .withOpacity(
                                                                    0.5,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    12,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                    width *
                                                                        0.0015,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            2,
                                                                      ),
                                                                      Center(
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                          child:
                                                                              Image.network(
                                                                            productData['images'][0],
                                                                            width:
                                                                                width * 0.35,
                                                                            height:
                                                                                width * 0.35,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(
                                                                                  width * 0.025,
                                                                                  width * 0.0125,
                                                                                  width * 0.0125,
                                                                                  0,
                                                                                ),
                                                                                child: Text(
                                                                                  productData['productName'],
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                    fontSize: width * 0.058,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(
                                                                                  width * 0.025,
                                                                                  0,
                                                                                  width * 0.0125,
                                                                                  0,
                                                                                ),
                                                                                child: Text(
                                                                                  productData['productPrice'] != "" && productData['productPrice'] != null ? productData['productPrice'] : "N/A",
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                    fontSize: width * 0.04,
                                                                                    fontWeight: FontWeight.w600,
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
                                                                            icon:
                                                                                Icon(
                                                                              FeatherIcons.trash,
                                                                              color: const Color.fromARGB(
                                                                                255,
                                                                                215,
                                                                                14,
                                                                                0,
                                                                              ),
                                                                              size: width * 0.09,
                                                                            ),
                                                                            tooltip:
                                                                                "Remove Product",
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                    // PRODUCTS IN LISTVIEW
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: snapshot
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            ((context, index) {
                                                          final productData =
                                                              snapshot.data!
                                                                  .docs[index];
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal:
                                                                  width *
                                                                      0.000625,
                                                              vertical:
                                                                  width * 0.02,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        ((context) =>
                                                                            ProductPage(
                                                                              productId: productData['productId'],
                                                                              productName: productData['productName'],
                                                                            )),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: primary2
                                                                      .withOpacity(
                                                                    0.5,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    8,
                                                                  ),
                                                                ),
                                                                child: ListTile(
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
                                                                  subtitle:
                                                                      Text(
                                                                    productData['productPrice'] !=
                                                                                "" &&
                                                                            productData['productPrice'] !=
                                                                                null
                                                                        ? productData[
                                                                            'productPrice']
                                                                        : "N/A",
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
                                                                    onPressed:
                                                                        () {
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
                                                                          .trash,
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
                                                                        "Remove Product",
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
                                                        childAspectRatio:
                                                            width *
                                                                0.5 /
                                                                width *
                                                                1.45,
                                                      ),
                                                      itemCount: 4,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical:
                                                                width * 0.02,
                                                            horizontal:
                                                                width * 0.00575,
                                                          ),
                                                          child:
                                                              GridViewSkeleton(
                                                            width: width,
                                                            isPrice: true,
                                                            height: 30,
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
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.02,
                                                          ),
                                                          child:
                                                              ListViewSkeleton(
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
                                      ],
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
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.0225,
                                      vertical: width * 0.02125,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // TEXTFIELD
                                            Expanded(
                                              child: TextField(
                                                controller: searchController,
                                                autocorrect: false,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "Case - Sensitive",
                                                  hintText: "Search ...",
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isGridView = !isGridView;
                                                });
                                              },
                                              icon: Icon(
                                                isGridView
                                                    ? FeatherIcons.list
                                                    : FeatherIcons.grid,
                                              ),
                                              tooltip: isGridView
                                                  ? "List View"
                                                  : "Grid View",
                                            ),
                                          ],
                                        ),
                                        StreamBuilder(
                                          stream: brandDiscountStream,
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Center(
                                                child: Text(
                                                  "Something went wrong",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            }

                                            if (snapshot.hasData) {
                                              return SafeArea(
                                                child: isGridView
                                                    // PRODUCTS IN GRIDVIEW
                                                    ? GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          crossAxisSpacing: 0,
                                                          mainAxisSpacing: 0,
                                                          childAspectRatio:
                                                              width *
                                                                  0.5 /
                                                                  width *
                                                                  1.66,
                                                        ),
                                                        itemCount: snapshot
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final brandData =
                                                              snapshot.data!
                                                                  .docs[index];

                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical:
                                                                  width * 0.025,
                                                              horizontal:
                                                                  width *
                                                                      0.0125,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        ((context) =>
                                                                            BrandPage(
                                                                              brandId: brandData['brandId'],
                                                                              brandName: brandData['brandName'],
                                                                            )),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: primary2
                                                                      .withOpacity(
                                                                    0.5,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    12,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                    width *
                                                                        0.0015,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            2,
                                                                      ),
                                                                      Center(
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                          child:
                                                                              Image.network(
                                                                            brandData['imageUrl'],
                                                                            width:
                                                                                width * 0.35,
                                                                            height:
                                                                                width * 0.35,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(
                                                                                  width * 0.025,
                                                                                  width * 0.0125,
                                                                                  width * 0.0125,
                                                                                  0,
                                                                                ),
                                                                                child: Text(
                                                                                  brandData['brandName'],
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                    fontSize: width * 0.058,
                                                                                    fontWeight: FontWeight.bold,
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
                                                                            icon:
                                                                                Icon(
                                                                              FeatherIcons.trash,
                                                                              color: const Color.fromARGB(
                                                                                255,
                                                                                215,
                                                                                14,
                                                                                0,
                                                                              ),
                                                                              size: width * 0.09,
                                                                            ),
                                                                            tooltip:
                                                                                "Remove Product",
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                    // PRODUCTS IN LISTVIEW
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: snapshot
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            ((context, index) {
                                                          final productData =
                                                              snapshot.data!
                                                                  .docs[index];
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal:
                                                                  width *
                                                                      0.000625,
                                                              vertical:
                                                                  width * 0.02,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        ((context) =>
                                                                            ProductPage(
                                                                              productId: productData['productId'],
                                                                              productName: productData['productName'],
                                                                            )),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: primary2
                                                                      .withOpacity(
                                                                          0.5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: ListTile(
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
                                                                    productData[
                                                                        'productName'],
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
                                                                  subtitle:
                                                                      Text(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    productData['productPrice'] !=
                                                                                "" &&
                                                                            productData['productPrice'] !=
                                                                                null
                                                                        ? productData[
                                                                            'productPrice']
                                                                        : "N/A",
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
                                                                    onPressed:
                                                                        () {
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
                                                                          .trash,
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
                                                                        "Remove Product",
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
                                                        childAspectRatio:
                                                            width *
                                                                0.5 /
                                                                width *
                                                                1.545,
                                                      ),
                                                      itemCount: 4,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical:
                                                                width * 0.02,
                                                            horizontal:
                                                                width * 0.00575,
                                                          ),
                                                          child:
                                                              GridViewSkeleton(
                                                            width: width,
                                                            isPrice: false,
                                                            height: 30,
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
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.02,
                                                          ),
                                                          child:
                                                              ListViewSkeleton(
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
                                      ],
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
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.0225,
                                      vertical: width * 0.02125,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // TEXTFIELD
                                            Expanded(
                                              child: TextField(
                                                controller: searchController,
                                                autocorrect: false,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "Case - Sensitive",
                                                  hintText: "Search ...",
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isGridView = !isGridView;
                                                });
                                              },
                                              icon: Icon(
                                                isGridView
                                                    ? FeatherIcons.list
                                                    : FeatherIcons.grid,
                                              ),
                                              tooltip: isGridView
                                                  ? "List View"
                                                  : "Grid View",
                                            ),
                                          ],
                                        ),
                                        StreamBuilder(
                                          stream: categoryDiscountStream,
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Center(
                                                child: Text(
                                                  "Something went wrong",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            }

                                            if (snapshot.hasData) {
                                              return SafeArea(
                                                child: isGridView
                                                    // PRODUCTS IN GRIDVIEW
                                                    ? GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          crossAxisSpacing: 0,
                                                          mainAxisSpacing: 0,
                                                          childAspectRatio:
                                                              width *
                                                                  0.5 /
                                                                  width *
                                                                  1.66,
                                                        ),
                                                        itemCount: snapshot
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final categoryData =
                                                              snapshot.data!
                                                                  .docs[index];

                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal:
                                                                  width *
                                                                      0.000125,
                                                              vertical:
                                                                  width * 0.025,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        ((context) =>
                                                                            CategoryPage(
                                                                              categoryId: categoryData['categoryId'],
                                                                              categoryName: categoryData['categoryName'],
                                                                            )),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: primary2
                                                                      .withOpacity(
                                                                    0.5,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    12,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                    width *
                                                                        0.0015,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            2,
                                                                      ),
                                                                      Center(
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                          child:
                                                                              Image.network(
                                                                            categoryData['imageUrl'],
                                                                            width:
                                                                                width * 0.35,
                                                                            height:
                                                                                width * 0.35,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(
                                                                                  width * 0.025,
                                                                                  width * 0.0125,
                                                                                  width * 0.0125,
                                                                                  0,
                                                                                ),
                                                                                child: Text(
                                                                                  categoryData['categoryName'],
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                    fontSize: width * 0.058,
                                                                                    fontWeight: FontWeight.bold,
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
                                                                            icon:
                                                                                Icon(
                                                                              FeatherIcons.trash,
                                                                              color: const Color.fromARGB(
                                                                                255,
                                                                                215,
                                                                                14,
                                                                                0,
                                                                              ),
                                                                              size: width * 0.09,
                                                                            ),
                                                                            tooltip:
                                                                                "Remove Category",
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                    // PRODUCTS IN LISTVIEW
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: snapshot
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            ((context, index) {
                                                          final categoryData =
                                                              snapshot.data!
                                                                  .docs[index];
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal:
                                                                  width *
                                                                      0.000625,
                                                              vertical:
                                                                  width * 0.02,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        ((context) =>
                                                                            CategoryPage(
                                                                              categoryId: categoryData['categoryId'],
                                                                              categoryName: categoryData['categoryName'],
                                                                            )),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: primary2
                                                                      .withOpacity(
                                                                    0.5,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    8,
                                                                  ),
                                                                ),
                                                                child: ListTile(
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
                                                                          'imageUrl'],
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
                                                                        'categoryName'],
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
                                                                    onPressed:
                                                                        () {
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
                                                                          .trash,
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
                                                                        "Remove Category",
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
                                                        childAspectRatio:
                                                            width *
                                                                0.5 /
                                                                width *
                                                                1.545,
                                                      ),
                                                      itemCount: 4,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical:
                                                                width * 0.02,
                                                          ),
                                                          child:
                                                              GridViewSkeleton(
                                                            width: width,
                                                            isPrice: false,
                                                            height: 30,
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
                                                          padding:
                                                              EdgeInsets.all(
                                                            width * 0.02,
                                                          ),
                                                          child:
                                                              ListViewSkeleton(
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
                                      ],
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
