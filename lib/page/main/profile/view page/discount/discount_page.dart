import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/discount/category_with_discount_page.dart';
import 'package:find_easy/page/main/profile/view%20page/discount/product_with_discount_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/info_edit_box.dart';
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
  final String discountImageUrl;

  @override
  State<DiscountPage> createState() => DISCOUNT();
}

class DISCOUNT extends State<DiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final discountNameKey = GlobalKey<FormState>();
  final categorySearchController = TextEditingController();
  final productSearchController = TextEditingController();
  bool isCategoryGridView = true;
  bool isImageChanging = false;
  bool isChangingName = false;
  bool isFit = true;
  bool isAddingImage = false;

  // IMAGE FIT CHANGE
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // ADD DISCOUNT IMAGE
  void addDiscountImage() async {
    final XFile? im =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
    final XFile? im =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
  void confirmDelete(String discountId, String imageUrl) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Confirm DELETE"),
          content: const Text(
              "Are you sure you want to delete this Discount\nDiscount will be removed from all the products/categories with this discount"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
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
                delete(discountId, imageUrl);
              },
              child: const Text(
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

  // DELETE DISCOUNT
  void delete(String discountId, String imageUrl) async {
    try {
      await storage.refFromURL(imageUrl).delete();

      await store
          .collection('Business')
          .doc('Data')
          .collection('Discounts')
          .doc(discountId)
          .delete();
    } catch (e) {
      mySnackBar(context, e.toString());
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
                    child: Text('Something went wrong'),
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
            onPressed: () {
              confirmDelete(
                widget.discountId,
                widget.discountImageUrl,
              );
            },
            icon: Icon(
              Icons.delete_forever_outlined,
              color: Colors.red,
              size: 24,
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
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.hasData) {
                  final discountData = snapshot.data!;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                                            child: InteractiveViewer(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  discountData[
                                                      'discountImageUrl'],
                                                  fit: isFit
                                                      ? BoxFit.cover
                                                      : null,
                                                  width: width,
                                                  height: width,
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
                                              padding: const EdgeInsets.only(
                                                  left: 4, top: 4),
                                              child: IconButton.filledTonal(
                                                onPressed: () {
                                                  changeDiscountImage(
                                                    discountData[
                                                        'discountImageUrl'],
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 36,
                                                ),
                                                tooltip: "Change Image",
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4, top: 4),
                                              child: IconButton.filledTonal(
                                                onPressed: () {
                                                  removeDiscountImage(
                                                    discountData[
                                                        'discountImageUrl'],
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons
                                                      .highlight_remove_outlined,
                                                  size: 36,
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
                          propertyValue: [],
                          width: width,
                          onPressed: () {
                            change('discountName', TextInputType.name);
                          },
                        ),

                        // AMOUNT
                        InfoEditBox(
                          head: "AMOUNT",
                          noOfAnswers: 1,
                          content: discountData['discountAmount'],
                          propertyValue: [],
                          width: width,
                          onPressed: () {
                            change('discountAmount', TextInputType.number);
                          },
                        ),

                        // START DATE
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 6,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
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
                                    Text(
                                      "Start Date",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryDark2,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      discountData['discountStartDate'],
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 21,
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
                                    Icons.edit,
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 6,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
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
                                    Text(
                                      "End Date",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryDark2,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      discountData['discountEndDate'],
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 21,
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
                                    Icons.edit,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          margin: EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton(
                            style: TextStyle(
                              color: primaryDark2,
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.05,
                            ),
                            dropdownColor: primary,
                            hint: Text(
                              discountData['isPercent']
                                  ? 'Percent %'
                                  : 'Price Rs.',
                            ),
                            underline: SizedBox(),
                            items: ['Percent', 'Price']
                                .map((e) => DropdownMenuItem(
                                      child: Text(e),
                                      value: e,
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
                        SizedBox(height: 20),

                        // CATEGORIES
                        InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          radius: width * 0.2,
                          splashColor: primary2,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => CategoryWithDiscountPage(
                                      discountId: widget.discountId,
                                    )),
                              ),
                            );
                          },
                          child: Container(
                            width: width,
                            height: 80,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Categories with this discount",
                                  style: TextStyle(
                                    color: primaryDark2,
                                    fontSize: width * 0.05,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.navigate_next_rounded,
                                  size: width * 0.1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // PRODUCTS
                        InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          radius: width * 0.2,
                          splashColor: primary2,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => ProductWithDiscountPage(
                                      discountId: widget.discountId,
                                    )),
                              ),
                            );
                          },
                          child: Container(
                            width: width,
                            height: 80,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Products with this discount",
                                  style: TextStyle(
                                    color: primaryDark2,
                                    fontSize: width * 0.05,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.navigate_next_rounded,
                                  size: width * 0.1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
