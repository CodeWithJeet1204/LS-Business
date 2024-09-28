import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/discount/category/select_category_for_discount.dart';
import 'package:ls_business/vendors/provider/discount_category_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/image_pick_dialog.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

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
  String? startDate;
  String? endDate;
  DateTime? startDateTime;
  DateTime? endDateTime;
  File? _image;
  String? imageUrl;
  bool isAddingImage = false;
  bool isPercentSelected = true;
  bool isUploading = false;
  bool isDialog = false;

  @override
  void dispose() {
    nameController.dispose();
    discountController.dispose();
    super.dispose();
  }

  // ADD DISCOUNT IMAGE
  Future<void> addDiscountImage() async {
    setState(() {
      isAddingImage = true;
      isDialog = true;
    });
    final images = await showImagePickDialog(context, true);
    if (images.isNotEmpty) {
      final im = images[0];
      setState(() {
        _image = File(im.path);
      });
    }
    setState(() {
      isAddingImage = false;
      isDialog = false;
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
  Future<void> addDiscount(
    SelectCategoryForDiscountProvider provider,
    List<String> categoryNameList,
  ) async {
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
        isDialog = true;
      });
      try {
        String discountId = const Uuid().v4();
        if (_image != null) {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('Vendor/Discounts/Category')
              .child(discountId);
          await ref.putFile(_image!).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              setState(() {
                imageUrl = value;
              });
            });
          });
        }

        final vendorSnap = await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .get();

        final vendorData = vendorSnap.data()!;
        final latitude = vendorData['Latitude'];
        final longitude = vendorData['Longitude'];
        // final List shopTypes = vendorData['Type'];

        // for (String categoryName in categoryNameList) {
        //   for (var type in shopTypes) {
        //     final categorySnap = await store
        //         .collection('Business')
        //         .doc('Special Categories')
        //         .collection(type)
        //         .doc(categoryName)
        //         .get();

        //     if (categorySnap.exists) {
        //       await store
        //           .collection('Business')
        //           .doc('Special Categories')
        //           .collection(type)
        //           .doc(categoryName)
        //           .update({
        //         'discountId': discountId,
        //       });
        //     }
        //   }
        // }

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
          'discountStartDateTime': startDateTime,
          'discountEndDateTime': endDateTime,
          'discountId': discountId,
          'discountImageUrl': imageUrl,
          'products': [],
          'categories': categoryNameList,
          'brands': [],
          'vendorId': auth.currentUser!.uid,
          'Latitude': latitude,
          'Longitude': longitude,
        });
        provider.clear();

        setState(() {
          isUploading = false;
          isDialog = false;
        });
        if (mounted) {
          mySnackBar(context, 'Discount Added');
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          isUploading = false;
          isDialog = false;
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

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
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
              IconButton(
                onPressed: () async {
                  await showYouTubePlayerDialog(
                    context,
                    getYoutubeVideoId(
                      '',
                    ),
                  );
                },
                icon: const Icon(
                  Icons.question_mark_outlined,
                ),
                tooltip: 'Help',
              ),
              MyTextButton(
                onPressed: () async {
                  await addDiscount(
                    selectedCategoryProvider,
                    selectedCategories,
                  );
                },
                text: 'DONE',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                child: Form(
                  key: discountKey,
                  child: Column(
                    children: [
                      // DISCLAIMER
                      Text(
                        'If your selected category has ongoing discount, then this discount will be shown instead of that discount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryDark2,
                          fontSize: width * 0.03,
                        ),
                      ),

                      const Divider(),

                      // IMAGE
                      InkWell(
                        onTap: _image == null
                            ? () async {
                                await addDiscountImage();
                              }
                            : null,
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
                          child: isAddingImage
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : _image == null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          FeatherIcons.upload,
                                          size: width * 0.25,
                                        ),
                                        Text(
                                          'SELECT IMAGE',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: primaryDark,
                                            fontSize: width * 0.06,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Image.file(
                                              _image!,
                                              width: width,
                                              fit: BoxFit.cover,
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
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
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
                          if (value == null || value.isEmpty) {
                            return 'Please enter Discount Name';
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
                          GestureDetector(
                            onTap: () async {
                              await selectStartDate();
                            },
                            child: Container(
                              height: 100,
                              width: width * 0.475,
                              decoration: BoxDecoration(
                                color: primary3,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Start Date',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.04,
                                            bottom: width * 0.025,
                                          ),
                                          child: Text(
                                            startDate!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.0575,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),

                          // END DATE
                          GestureDetector(
                            onTap: () async {
                              await selectEndDate();
                            },
                            child: Container(
                              height: 100,
                              width: width * 0.475,
                              decoration: BoxDecoration(
                                color: primary3,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'End Date',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.0366,
                                            bottom: width * 0.025,
                                          ),
                                          child: Text(
                                            endDate!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.0575,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // DISCLAIMER
                      Text(
                        'If you select 1 jan as end date, discount will end at 31 dec 11:59 pm',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryDark2,
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: !isPercentSelected
                                          ? primaryDark.withOpacity(0.33)
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isPercentSelected
                                          ? primaryDark.withOpacity(0.33)
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
                            hintText: isPercentSelected
                                ? 'eg. 20%'
                                : 'eg. Rs. 200 off',
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
      ),
    );
  }
}
