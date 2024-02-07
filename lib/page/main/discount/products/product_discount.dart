import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/discount/products/select_products_for_discount.dart';
import 'package:find_easy/provider/discount_products_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ProductDiscountPage extends StatefulWidget {
  const ProductDiscountPage({super.key});

  @override
  State<ProductDiscountPage> createState() => _ProductDiscountPageState();
}

class _ProductDiscountPageState extends State<ProductDiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final nameController = TextEditingController();
  final discountController = TextEditingController();
  final discountKey = GlobalKey<FormState>();
  bool isPercentSelected = true;
  String? startDate;
  String? endDate;
  DateTime? startDateTime;
  DateTime? endDateTime;
  File? _image;
  bool isFit = false;
  bool isUploading = false;
  String? imageUrl;

  void addDiscountImage() async {
    final XFile? im =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = File(im.path);
      });
    } else {
      if (context.mounted) {
        mySnackBar(context, "Select an Image");
      }
    }
  }

  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  void selectStartDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
    );

    if (selected != null) {
      setState(() {
        startDateTime = selected;
        startDate = DateFormat('d MMM yy').format(selected);
      });
    }
  }

  void selectEndDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
    );

    if (selected != null) {
      setState(() {
        endDateTime = selected;
        endDate = DateFormat('d MMM yy').format(selected);
      });
    }
  }

  void addDiscount(SelectProductForDiscountProvider provider,
      List<String> productIdList) async {
    // End date should be after start date
    if (discountKey.currentState!.validate()) {
      if (startDate == null) {
        return mySnackBar(context, "Select Start Date");
      }
      if (endDate == null) {
        return mySnackBar(context, "Select End Date");
      }
      if (startDateTime!.isAfter(
        endDateTime!,
      )) {
        return mySnackBar(context, "Start Date should be before End Date");
      }
      if (provider.selectedProducts.isEmpty) {
        return mySnackBar(context, "Select Product");
      }

      setState(() {
        isUploading = true;
      });
      try {
        String discountId = Uuid().v4();
        if (_image != null) {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('Data/Discounts/Products')
              .child(discountId);
          await ref.putFile(_image!).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              setState(() {
                imageUrl = value;
              });
            });
          });
        }

        await store
            .collection('Business')
            .doc('Data')
            .collection('Discounts')
            .doc(discountId)
            .set({
          'isPercent': isPercentSelected,
          'isProducts': true,
          'isCategories': false,
          'discountAmount': double.parse(discountController.text),
          'discountStartDate': startDate,
          'discountEndDate': endDate,
          'discountStartDateTime': startDateTime,
          'discountEndDateTime': endDateTime,
          'discountId': discountId,
          'discountImageUrl': imageUrl ?? null,
          'products': productIdList,
          'categories': [],
          'vendorId': auth.currentUser!.uid,
        });
        mySnackBar(context, "Discount Added");
        Navigator.of(context).pop();
        setState(() {
          isUploading = false;
        });
      } catch (e) {
        setState(() {
          isUploading = false;
        });
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProductProvider =
        Provider.of<SelectProductForDiscountProvider>(context);
    final selectedProducts = selectedProductProvider.selectedProducts;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            selectedProductProvider.clear();
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          tooltip: "Back",
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              addDiscount(selectedProductProvider, selectedProducts);
            },
            text: "DONE",
            textColor: primaryDark,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isUploading ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isUploading ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Form(
                key: discountKey,
                child: Column(
                  children: [
                    // IMAGE
                    GestureDetector(
                      onTap: _image == null ? addDiscountImage : changeFit,
                      child: Container(
                        width: width,
                        height: width * 9 / 16,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryDark,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _image == null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(
                                    Icons.arrow_circle_up_rounded,
                                    size: width * 0.35,
                                  ),
                                  Text(
                                    "Select IMAGE",
                                    style: TextStyle(
                                      color: primaryDark,
                                      fontSize: width * 0.08,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: InteractiveViewer(
                                        child: Image.file(
                                          _image!,
                                          width: width,
                                          fit: isFit
                                              ? BoxFit.cover
                                              : BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: IconButton.filledTonal(
                                          onPressed: addDiscountImage,
                                          icon: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 40,
                                          ),
                                          tooltip: "Change Image",
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: IconButton.filledTonal(
                                          onPressed: () {
                                            setState(() {
                                              _image = null;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.highlight_remove_rounded,
                                            size: 40,
                                          ),
                                          tooltip: "Remove Image",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // NAME
                    TextFormField(
                      autofocus: false,
                      focusNode: FocusNode(),
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.cyan.shade700,
                          ),
                        ),
                        hintText: "Discount / Sale Name",
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter Discount Amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // DATES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // START DATE
                        Container(
                          height: 100,
                          width: width * 0.475,
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Start Date',
                                      style: TextStyle(
                                        color: primaryDark2,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    startDate != null
                                        ? IconButton(
                                            onPressed: selectStartDate,
                                            icon: Icon(
                                              Icons.edit,
                                              size: width * 0.075,
                                            ),
                                            tooltip: "Change Date",
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              startDate == null
                                  ? MyTextButton(
                                      onPressed: selectStartDate,
                                      text: "Select Date",
                                      textColor: primaryDark,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        startDate!,
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.07,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),

                        // END DATE
                        Container(
                          height: 100,
                          width: width * 0.475,
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'End Date',
                                      style: TextStyle(
                                        color: primaryDark2,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    endDate != null
                                        ? IconButton(
                                            onPressed: selectEndDate,
                                            icon: Icon(
                                              Icons.edit,
                                              size: width * 0.075,
                                            ),
                                            tooltip: "Change Date",
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              endDate == null
                                  ? MyTextButton(
                                      onPressed: selectEndDate,
                                      text: "Select Date",
                                      textColor: primaryDark,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        endDate!,
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.07,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // SELECT PRODUCT
                    MyButton(
                      text: selectedProducts.isEmpty
                          ? "SELECT PRODUCTS"
                          : "SELECTED PRODUCTS - ${selectedProducts.length}",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectProductForDiscountPage(),
                          ),
                        );
                      },
                      isLoading: false,
                      horizontalPadding: 0,
                    ),
                    SizedBox(height: 20),

                    // PERCENT / RUPEES
                    Container(
                      width: width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primary2.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // PERCENT
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPercentSelected = !isPercentSelected;
                                });
                              },
                              child: Container(
                                width: width * 0.4,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isPercentSelected
                                      ? primary2.withOpacity(0.75)
                                      : primary2.withOpacity(0.005),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "PERCENT %",
                                  style: TextStyle(
                                    color: !isPercentSelected
                                        ? white
                                        : primaryDark.withOpacity(0.9),
                                    fontSize: width * 0.05,
                                    fontWeight: isPercentSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // PRICE
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPercentSelected = !isPercentSelected;
                                });
                              },
                              child: Container(
                                width: width * 0.4,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !isPercentSelected
                                      ? primary2.withOpacity(0.75)
                                      : primary2.withOpacity(0.005),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "PRICE ₹",
                                  style: TextStyle(
                                    color: isPercentSelected
                                        ? white
                                        : primaryDark.withOpacity(0.9),
                                    fontSize: width * 0.05,
                                    fontWeight: !isPercentSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // AMOUNT
                    TextFormField(
                      autofocus: false,
                      focusNode: FocusNode(),
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.cyan.shade700,
                          ),
                        ),
                        hintText:
                            isPercentSelected ? "eg. 20%" : "eg. Rs. 200 off",
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter Discount Amount';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
