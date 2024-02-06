import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_category_change_page.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_image_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/info_edit_box.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
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
  });

  final String productId;
  final String productName;
  final bool fromPost;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final store = FirebaseFirestore.instance;
  final TextEditingController editController = TextEditingController();
  final GlobalKey<FormState> editKey = GlobalKey<FormState>();
  int _currentIndex = 0;
  bool isEditing = false;
  bool categoryExists = true;
  bool isImageChanging = false;

  // EDIT INFO
  void edit(
    String propertyValue,
    int noOfAnswers,
    bool isProperty,
    bool inputType,
  ) async {
    showDialog(
        context: context,
        builder: (context) {
          final propertyStream = FirebaseFirestore.instance
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
                      return Center(
                        child: Text('Something went wrong'),
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
                                          if (value != null &&
                                              value.length > 1) {
                                            return null;
                                          } else {
                                            return "Min 2 chars required";
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
                                                        Icons
                                                            .highlight_remove_outlined,
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
                                            await FirebaseFirestore.instance
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
                                            await FirebaseFirestore.instance
                                                .collection('Business')
                                                .doc('Data')
                                                .collection('Products')
                                                .doc(widget.productId)
                                                .update({
                                              propertyValue: editController.text
                                                  .toString(),
                                            });
                                            editController.clear();
                                          }
                                          editController.clear();
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          mySnackBar(context, e.toString());
                                        }
                                        setState(() {
                                          isEditing = false;
                                        });
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

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          );
        });
  }

  // ADD IMAGES
  void addProductImages(List images) async {
    final XFile? im =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
          await ref.getDownloadURL().then((value) {
            print("Jeet");
            images.add(value);
            FirebaseFirestore.instance
                .collection('Business')
                .doc('Data')
                .collection('Products')
                .doc(widget.productId)
                .update({
              'images': images,
            });
          });
        });
        setState(() {
          isImageChanging = true;
        });
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => ProductPage(
                productId: widget.productId, productName: widget.productName)),
          ),
        );
      } catch (e) {
        setState(() {
          isImageChanging = true;
        });
        mySnackBar(context, e.toString());
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // CHANGE IMAGES
  void changeProductImage(String e, int index, List images) async {
    final XFile? im =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (im != null) {
      try {
        setState(() {
          isImageChanging = true;
        });
        Reference ref =
            await FirebaseStorage.instance.refFromURL(images[index]);
        await images.removeAt(index);
        await ref.putFile(File(im.path));
        setState(() {
          isImageChanging = false;
        });
      } catch (e) {
        setState(() {
          isImageChanging = false;
        });
        mySnackBar(context, e.toString());
      }
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  // REMOVE IMAGES
  void removeProductImages(String e, List images) async {
    await FirebaseStorage.instance
        .refFromURL(images[images.indexOf(e)])
        .delete();
    images.remove(e);
    await FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .update({
      'images': images,
    });
  }

  // DELETE PRODUCT
  // When deleting product, also delete all posts related to it.
  void delete() async {
    setState(() {
      isEditing = true;
    });
    try {
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
        ;
      }
      setState(() {
        isEditing = false;
      });
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isEditing = false;
      });
      mySnackBar(context, e.toString());
    }
  }

  // CONFIRM DELETE
  confirmDelete() {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: Text("Confirm DELETE"),
          content: Text(
              "Are you sure you want to delete this product & all its posts"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                delete();
              },
              child: Text(
                'YES',
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

  @override
  Widget build(BuildContext context) {
    final productStream = FirebaseFirestore.instance
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .doc(widget.productId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: confirmDelete,
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            tooltip: "DELETE",
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: SizedBox(
                width: width,
                child: StreamBuilder(
                    stream: productStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Something Went Wrong'),
                        );
                      }

                      if (snapshot.hasData) {
                        final productData = snapshot.data!;
                        final String name = productData['productName'];
                        final String price = productData['productPrice'];
                        final String description =
                            productData['productDescription'];
                        final String brand = productData['productBrand'];
                        final List images = productData['images'];
                        final List tags = productData['Tags'];

                        final Map<String, dynamic> properties =
                            productData['Properties'];
                        final String propertyName0 =
                            properties['propertyName0'];
                        final String propertyName1 =
                            properties['propertyName1'];
                        final String propertyName2 =
                            properties['propertyName2'];
                        final String propertyName3 =
                            properties['propertyName3'];
                        final String propertyName4 =
                            properties['propertyName4'];
                        final String propertyName5 =
                            properties['propertyName5'];

                        final List propertyValue0 =
                            properties['propertyValue0'];
                        final List propertyValue1 =
                            properties['propertyValue1'];
                        final List propertyValue2 =
                            properties['propertyValue2'];
                        final List propertyValue3 =
                            properties['propertyValue3'];
                        final List propertyValue4 =
                            properties['propertyValue4'];
                        final List propertyValue5 =
                            properties['propertyValue5'];

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

                        final Stream<DocumentSnapshot<Map<String, dynamic>>>
                            categoryStream = FirebaseFirestore.instance
                                .collection('Business')
                                .doc('Data')
                                .collection('Category')
                                .doc(productData['categoryId'])
                                .snapshots();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: isImageChanging
                                              ? CircularProgressIndicator()
                                              : GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: ((context) =>
                                                            ProductImageView(
                                                              imagesUrl: images,
                                                            )),
                                                      ),
                                                    );
                                                  },
                                                  child: Image.network(e),
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 4,
                                                      top: 4,
                                                    ),
                                                    child:
                                                        IconButton.filledTonal(
                                                      onPressed: () {
                                                        changeProductImage(
                                                          e,
                                                          images.indexOf(e),
                                                          images,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .camera_alt_outlined,
                                                        size: 36,
                                                      ),
                                                      tooltip: "Change Image",
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 4,
                                                      top: 4,
                                                    ),
                                                    child:
                                                        IconButton.filledTonal(
                                                      onPressed: images.last !=
                                                              e
                                                          ? () {
                                                              removeProductImages(
                                                                  e, images);
                                                            }
                                                          : null,
                                                      icon: Icon(
                                                        Icons.highlight_remove,
                                                        size: 36,
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
                                SizedBox(),
                                images.length > 1
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: (images).map((e) {
                                            int index = images.indexOf(e);

                                            return Container(
                                              width: _currentIndex == index
                                                  ? 12
                                                  : 8,
                                              height: _currentIndex == index
                                                  ? 12
                                                  : 8,
                                              margin: EdgeInsets.all(4),
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
                                    : SizedBox(height: 40),
                                GestureDetector(
                                  onTap: () {
                                    addProductImages(images);
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Add Image"),
                                        Icon(Icons.add),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // NAME
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryDark,
                                      fontSize: name.length > 12
                                          ? 28
                                          : name.length > 10
                                              ? 30
                                              : 32,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    edit(
                                      'productName',
                                      1,
                                      false,
                                      true,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 24,
                                  ),
                                  tooltip: "Edit Name",
                                ),
                              ],
                            ),

                            // PRICE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    price == ""
                                        ? 'N/A (price)'
                                        : 'Rs. ${price}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryDark,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    edit(
                                      'productPrice',
                                      1,
                                      false,
                                      true,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 22,
                                  ),
                                  tooltip: "Edit Price",
                                ),
                              ],
                            ),

                            // DESCRIPTION
                            InfoEditBox(
                              head: "Description",
                              content: description,
                              noOfAnswers: 1,
                              propertyValue: [],
                              maxLines: 20,
                              width: width,
                              onPressed: () {
                                edit(
                                  "productDescription",
                                  1,
                                  false,
                                  true,
                                );
                              },
                            ),

                            // CATEGORY
                            StreamBuilder(
                                stream: categoryStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Something went wrong'),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    categoryExists = false;
                                  }

                                  if (snapshot.hasData) {
                                    categoryExists = true;
                                    final categoryData = snapshot.data!;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 6,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    4,
                                                  ),
                                                  child: Image.network(
                                                    categoryExists
                                                        ? productData[
                                                                    'categoryId'] !=
                                                                '0'
                                                            ? categoryData[
                                                                'imageUrl']
                                                            : 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png'
                                                        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                                    fit: BoxFit.cover,
                                                    width: categoryExists
                                                        ? productData[
                                                                    'categoryId'] !=
                                                                '0'
                                                            ? width * 0.15
                                                            : width * 0.1
                                                        : width * 0.1,
                                                    height: categoryExists
                                                        ? productData[
                                                                    'categoryId'] !=
                                                                '0'
                                                            ? width * 0.15
                                                            : width * 0.1
                                                        : width * 0.1,
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.05),
                                                SizedBox(
                                                  width: width * 0.4,
                                                  child: Text(
                                                    categoryExists
                                                        ? productData[
                                                            'categoryName']
                                                        : 'No Category',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: categoryExists
                                                          ? productData[
                                                                      'categoryName'] !=
                                                                  'No Category Selected'
                                                              ? 20
                                                              : 16
                                                          : 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        ChangeCategory(
                                                          productId:
                                                              productData[
                                                                  'productId'],
                                                        )),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.edit),
                                              tooltip: "Change Category",
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: primaryDark,
                                    ),
                                  );
                                }),

                            // BRAND
                            InfoEditBox(
                              head: "Brand",
                              content: brand,
                              noOfAnswers: 1,
                              propertyValue: [],
                              width: width,
                              onPressed: () {
                                edit(
                                  'productBrand',
                                  1,
                                  false,
                                  true,
                                );
                              },
                            ),

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
                                    onPressed: () {
                                      edit(
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
                                    onPressed: () {
                                      edit(
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
                                    onPressed: () {
                                      edit(
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
                                    onPressed: () {
                                      edit(
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
                                    onPressed: () {
                                      edit(
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
                                    onPressed: () {
                                      edit(
                                        'propertyValue5',
                                        propertyNoOfAnswers5,
                                        true,
                                        propertyInputType5,
                                      );
                                    },
                                  )
                                : Container(),

                            // TAGS
                            InfoEditBox(
                              head: "Tags",
                              content: tags,
                              propertyValue: tags,
                              noOfAnswers: 3,
                              width: width,
                              onPressed: () {
                                edit(
                                  'Tags',
                                  3,
                                  false,
                                  true,
                                );
                              },
                            ),
                          ],
                        );
                      }

                      return Center(
                        child: CircularProgressIndicator(
                          color: primaryDark,
                        ),
                      );
                    }),
              ),
            ),
          );
        }),
      ),
    );
  }
}
