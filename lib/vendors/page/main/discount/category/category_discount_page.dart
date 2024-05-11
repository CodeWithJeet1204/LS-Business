import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/page/main/discount/category/select_category_for_discount.dart';
import 'package:find_easy/vendors/provider/discount_category_provider.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/image_pick_dialog.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoryDiscountPage extends StatefulWidget {
  const CategoryDiscountPage({super.key});

  @override
  State<CategoryDiscountPage> createState() => _CategoryDiscountPageState();
}

class _CategoryDiscountPageState extends State<CategoryDiscountPage> {
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

  @override
  void dispose() {
    nameController.dispose();
    discountController.dispose();
    super.dispose();
  }

  // ADD DISCOUNT IMAGE
  Future<void> addDiscountImage() async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      setState(() {
        _image = File(im.path);
      });
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // CHANGE IMAGE FIT
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // SELECT START DATE
  Future<void> selectStartDate() async {
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

  // SELECT END DATE
  Future<void> selectEndDate() async {
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

  // ADD DISCOUNT
  Future<void> addDiscount(SelectCategoryForDiscountProvider provider,
      List<String> categoryIdList) async {
    // End date should be after start date
    if (discountKey.currentState!.validate()) {
      if (startDate == null) {
        return mySnackBar(context, 'Select Start Date');
      }
      if (endDate == null) {
        return mySnackBar(context, 'Select End Date');
      }
      if (startDateTime!.isAfter(
        endDateTime!,
      )) {
        return mySnackBar(context, 'Start Date should be before End Date');
      }
      if (provider.selectedCategories.isEmpty) {
        return mySnackBar(context, 'Select Category');
      }

      setState(() {
        isUploading = true;
      });
      try {
        String discountId = const Uuid().v4();
        if (_image != null) {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('Data/Discounts/Category')
              .child(discountId);
          await ref.putFile(_image!).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              setState(() {
                imageUrl = value;
              });
            });
          });
        }

        for (String id in categoryIdList) {
          await store
              .collection('Business')
              .doc('Data')
              .collection('Category')
              .doc(id)
              .update({
            'discountId': discountId,
            'discountEndDate': endDate,
          });
        }

        await store
            .collection('Business')
            .doc('Data')
            .collection('Discounts')
            .doc(discountId)
            .set({
          'isPercent': isPercentSelected,
          'isProducts': false,
          'isCategories': true,
          'isBrands': false,
          'discountName': nameController.text.toString(),
          'discountAmount': double.parse(discountController.text),
          'discountStartDate': startDate,
          'discountEndDate': endDate,
          'discountStartDateTime': startDateTime,
          'discountEndDateTime': endDateTime,
          'discountId': discountId,
          'discountImageUrl': imageUrl,
          'products': [],
          'categories': categoryIdList,
          'brands': [],
          'vendorId': auth.currentUser!.uid,
        });
        provider.clear();
        if (mounted) {
          mySnackBar(context, 'Discount Added');
          Navigator.of(context).pop();
        }
        setState(() {
          isUploading = false;
        });
      } catch (e) {
        setState(() {
          isUploading = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryProvider =
        Provider.of<SelectCategoryForDiscountProvider>(context);
    final selectedCategories = selectedCategoryProvider.selectedCategories;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            selectedCategoryProvider.clear();
            Navigator.of(context).pop();
          },
          icon: const Icon(
            FeatherIcons.arrowLeft,
          ),
          tooltip: 'Back',
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              await addDiscount(selectedCategoryProvider, selectedCategories);
            },
            text: 'DONE',
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Form(
                key: discountKey,
                child: Column(
                  children: [
                    // DISCLAIMER
                    const Text(
                      overflow: TextOverflow.ellipsis,
                      'If your category has ongoing discount, then this discount will be applied, after that discount ends (if this discount ends after that)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryDark2,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // IMAGE
                    GestureDetector(
                      onTap: _image == null
                          ? () async {
                              await addDiscountImage();
                            }
                          : changeFit,
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
                                    FeatherIcons.upload,
                                    size: width * 0.35,
                                  ),
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    'Select IMAGE',
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
                                          onPressed: () async {
                                            await addDiscountImage();
                                          },
                                          icon: Icon(
                                            FeatherIcons.camera,
                                            size: width * 0.115,
                                          ),
                                          tooltip: 'Change Image',
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
                                          icon: Icon(
                                            FeatherIcons.x,
                                            size: width * 0.115,
                                          ),
                                          tooltip: 'Remove Image',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // NAME
                    TextFormField(
                      controller: nameController,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.cyan.shade700,
                          ),
                        ),
                        hintText: 'Discount / Sale Name',
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter Discount Amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

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
                                      overflow: TextOverflow.ellipsis,
                                      'Start Date',
                                      style: TextStyle(
                                        color: primaryDark2,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    startDate != null
                                        ? IconButton(
                                            onPressed: () async {
                                              await selectStartDate();
                                            },
                                            icon: Icon(
                                              FeatherIcons.edit,
                                              size: width * 0.075,
                                            ),
                                            tooltip: 'Change Date',
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              startDate == null
                                  ? MyTextButton(
                                      onPressed: () async {
                                        await selectStartDate();
                                      },
                                      text: 'Select Date',
                                      textColor: primaryDark,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.04,
                                        bottom: width * 0.025,
                                      ),
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
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
                                      overflow: TextOverflow.ellipsis,
                                      'End Date',
                                      style: TextStyle(
                                        color: primaryDark2,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    endDate != null
                                        ? IconButton(
                                            onPressed: () async {
                                              await selectEndDate();
                                            },
                                            icon: Icon(
                                              FeatherIcons.edit,
                                              size: width * 0.075,
                                            ),
                                            tooltip: 'Change Date',
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              endDate == null
                                  ? MyTextButton(
                                      onPressed: () async {
                                        await selectEndDate();
                                      },
                                      text: 'Select Date',
                                      textColor: primaryDark,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0366,
                                        bottom: width * 0.025,
                                      ),
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 20),

                    // DISCLAIMER
                    Text(
                      overflow: TextOverflow.ellipsis,
                      'If you select 1 jan as end date, discount will end at 31 dec 11:59 pm',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryDark2,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SELECT CATEGORY
                    MyButton(
                      text: selectedCategories.isEmpty
                          ? 'SELECT CATEGORIES'
                          : 'SELECTED CATEGORIES - ${selectedCategories.length}',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const SelectCategoryForDiscountPage(),
                          ),
                        );
                      },
                      isLoading: false,
                      horizontalPadding: 0,
                    ),
                    const SizedBox(height: 20),

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
                                  isPercentSelected = true;
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
                                  'PERCENT %',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: !isPercentSelected
                                        ? white
                                        : primaryDark.withOpacity(0.9),
                                    fontSize: width * 0.055,
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
                                  isPercentSelected = false;
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
                                  'PRICE ₹',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isPercentSelected
                                        ? primaryDark.withOpacity(0.33)
                                        : primaryDark.withOpacity(0.9),
                                    fontSize: width * 0.055,
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
                    const SizedBox(height: 20),

                    // AMOUNT
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: TextFormField(
                        controller: discountController,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.cyan.shade700,
                            ),
                          ),
                          hintText:
                              isPercentSelected ? 'eg. 20%' : 'eg. Rs. 200 off',
                        ),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Please enter Discount Amount';
                          }
                          return null;
                        },
                      ),
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
