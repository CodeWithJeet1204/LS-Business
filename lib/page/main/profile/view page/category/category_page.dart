import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/add/category/select_products_for_category_page.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  final categoryNameKey = GlobalKey<FormState>();
  bool isImageChanging = false;
  bool isFit = false;
  bool isChangingName = false;
  bool isGridView = true;
  bool isDiscount = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    ifDiscount();
    super.initState();
  }

  // CHANGE CATEGORY IMAGE
  void changeCategoryImage(String imageUrl) async {
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
        // Navigator.of(context).pop();
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

  // CATEGORY NAME CHANGE BACKEND
  void changeCategoryName(String newName) async {
    if (categoryNameKey.currentState!.validate()) {
      try {
        setState(() {
          isChangingName = true;
        });
        await store
            .collection('Business')
            .doc('Data')
            .collection('Category')
            .doc(widget.categoryId)
            .update({
          'categoryName': newName,
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

  // CATEGORY NAME CHANGE
  void changeName() {
    showDialog(
      context: context,
      builder: (context) {
        final propertyStream = FirebaseFirestore.instance
            .collection('Business')
            .doc('Data')
            .collection('Category')
            .doc(widget.categoryId)
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
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.hasData) {
                  final categoryData = snapshot.data!;
                  String categoryName = categoryData['categoryName'];

                  return Form(
                    key: categoryNameKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            initialValue: categoryName,
                            decoration: const InputDecoration(
                              hintText: "Category Name",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              categoryName = value;
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return "Enter Category Name";
                              }
                            },
                          ),
                          MyButton(
                            text: "SAVE",
                            onTap: () {
                              changeCategoryName(categoryName);
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

  // IMAGE FIT CHANGE
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // REMOVE PRODUCT
  void remove(String productId, String productName, String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remove $productName"),
          content: Text(
              'Are you sure you want to remove $productName from $categoryName'),
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

// IF DISCOUNT
  Future<void> ifDiscount() async {
    final discount = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in discount.docs) {
      final data = doc.data();
      if ((data['categories'] as List).contains(widget.categoryId)) {
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // CATEGORY STREAM
    final Stream<DocumentSnapshot<Map<String, dynamic>>> categoryStream = store
        .collection('Business')
        .doc('Data')
        .collection('Category')
        .doc(widget.categoryId)
        .snapshots();

    // PRODUCT STREAM
    final allProductStream = store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('categoryId', isEqualTo: widget.categoryId)
        .orderBy('productName')
        .where('productName',
            isGreaterThanOrEqualTo: searchController.text.toString())
        .where('productName', isLessThan: '${searchController.text}\uf8ff')
        .orderBy('datetime', descending: true)
        .snapshots();

    // DISCOUNT STREAM
    final discountPriceStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: LayoutBuilder(builder: ((context, constraints) {
        double width = constraints.maxWidth;

        return SingleChildScrollView(
          child: StreamBuilder(
            stream: categoryStream,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }

              if (snapshot.hasData) {
                final categoryData = snapshot.data!;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IMAGE
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: width,
                            height: width,
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
                                    child: Image.network(
                                      categoryData['imageUrl'],
                                      fit: isFit ? BoxFit.cover : null,
                                      width: width,
                                      height: width,
                                    ),
                                  ),
                          ),
                          // IMAGE CHANGING INDICATOR
                          isImageChanging
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(
                                    right: width * 0.0125,
                                    top: width * 0.0125,
                                  ),
                                  child: IconButton.filledTonal(
                                    onPressed: () {
                                      changeCategoryImage(
                                        categoryData['imageUrl'],
                                      );
                                    },
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      size: width * 0.1,
                                    ),
                                    tooltip: "Change Image",
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // NAME
                      Container(
                        width: width,
                        padding: EdgeInsets.symmetric(
                          vertical: width * 0.025,
                          horizontal: width * 0.0,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              categoryData['categoryName'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryDark,
                                fontSize: width * 0.0725,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                changeName();
                              },
                              icon: Icon(
                                Icons.edit,
                                size: width * 0.0725,
                                color: primaryDark,
                              ),
                              tooltip: "Change Name",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // DISCOUNT
                      isDiscount
                          ? StreamBuilder(
                              stream: discountPriceStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text('Something Went Wrong'),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: width * 0.01),
                                        child: data['isPercent']
                                            ? Text(
                                                "${data['discountAmount']}% off",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : Text(
                                                "Save Rs. ${data['discountAmount']}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical: width * 0.00625,
                                        ),
                                        child: Text(
                                          (data['discountEndDateTime']
                                                          as Timestamp)
                                                      .toDate()
                                                      .difference(
                                                          DateTime.now())
                                                      .inHours <
                                                  24
                                              ? '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours Left'''
                                              : '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days Left''',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.01,
                                          top: width * 0.025,
                                        ),
                                        child: const Text(
                                          "This discount is available to all the products within this category",
                                          style: TextStyle(
                                            color: primaryDark,
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
                          : Container(),
                      const SizedBox(height: 28),

                      // ADD PRODUCTS
                      MyButton(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) =>
                                  SelectProductsForCategoryPage(
                                    categoryId: widget.categoryId,
                                    categoryName: widget.categoryName,
                                    fromAddCategoryPage: false,
                                  )),
                            ),
                          );
                        },
                        text: "ADD PRODUCT",
                        isLoading: false,
                        horizontalPadding: 0,
                      ),
                      const SizedBox(height: 28),

                      // PRODUCTS IN CATEGORY
                      ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: primary2.withOpacity(0.25),
                        collapsedBackgroundColor: primary2.withOpacity(0.33),
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
                                // HEADER
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // TEXTFIELD
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        autocorrect: false,
                                        decoration: const InputDecoration(
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
                                            ? Icons.list
                                            : Icons.grid_view_rounded,
                                      ),
                                      tooltip: isGridView
                                          ? "List View"
                                          : "Grid View",
                                    ),
                                  ],
                                ),

                                // PRODUCTS
                                StreamBuilder(
                                  stream: allProductStream,
                                  builder: ((context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text("Something went wrong"),
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
                                                      width * 0.5 / width * 1.5,
                                                ),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  final productData = snapshot
                                                      .data!.docs[index];
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: width * 0.025,
                                                      horizontal:
                                                          width * 0.0125,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                ((context) =>
                                                                    ProductPage(
                                                                      productId:
                                                                          productData[
                                                                              'productId'],
                                                                      productName:
                                                                          productData[
                                                                              'productName'],
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
                                                              EdgeInsets.all(
                                                            width * 0.0015,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                height: 2,
                                                              ),
                                                              Center(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    12,
                                                                  ),
                                                                  child: Image
                                                                      .network(
                                                                    productData[
                                                                        'images'][0],
                                                                    width:
                                                                        width *
                                                                            0.35,
                                                                    height:
                                                                        width *
                                                                            0.35,
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
                                                                              0.025,
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          productData[
                                                                              'productName'],
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.058,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            width *
                                                                                0.025,
                                                                            0,
                                                                            width *
                                                                                0.0125,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          productData['productPrice'] != "" && productData['productPrice'] != null
                                                                              ? productData['productPrice']
                                                                              : "N/A",
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
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
                                                                      remove(
                                                                        productData[
                                                                            'productId'],
                                                                        productData[
                                                                            'productName'],
                                                                        widget
                                                                            .categoryName,
                                                                      );
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .delete_forever,
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
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: ((context, index) {
                                                  final productData = snapshot
                                                      .data!.docs[index];
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          width * 0.000625,
                                                      vertical: width * 0.02,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                ((context) =>
                                                                    ProductPage(
                                                                      productId:
                                                                          productData[
                                                                              'productId'],
                                                                      productName:
                                                                          productData[
                                                                              'productName'],
                                                                    )),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primary2
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: ListTile(
                                                          leading: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              4,
                                                            ),
                                                            child:
                                                                Image.network(
                                                              productData[
                                                                  'images'][0],
                                                              width:
                                                                  width * 0.15,
                                                              height:
                                                                  width * 0.15,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          title: Text(
                                                            productData[
                                                                'productName'],
                                                            style: TextStyle(
                                                              fontSize: width *
                                                                  0.0525,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            productData['productPrice'] !=
                                                                        "" &&
                                                                    productData[
                                                                            'productPrice'] !=
                                                                        null
                                                                ? productData[
                                                                    'productPrice']
                                                                : "N/A",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width * 0.035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              remove(
                                                                productData[
                                                                    'productId'],
                                                                productData[
                                                                    'productName'],
                                                                widget
                                                                    .categoryName,
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .delete_forever,
                                                              color: const Color
                                                                  .fromRGBO(215,
                                                                  14, 0, 1),
                                                              size:
                                                                  width * 0.09,
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

                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: primaryDark,
                                      ),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
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
      })),
    );
  }
}
