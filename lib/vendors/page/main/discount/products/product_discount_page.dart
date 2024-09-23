import 'dart:io';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/discount/products/select_products_for_discount_page.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/product/product_page.dart';
import 'package:Localsearch/vendors/provider/discount_products_provider.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class ProductDiscountPage extends StatefulWidget {
  const ProductDiscountPage({
    super.key,
    this.changeSelectedProductDiscount,
    this.changeSelectedProductDiscountName,
    this.changeSelectedProductDiscountId,
  });

  final bool? changeSelectedProductDiscount;
  final String? changeSelectedProductDiscountName;
  final String? changeSelectedProductDiscountId;

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
  bool isUploading = false;
  String? imageUrl;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    discountController.dispose();
    super.dispose();
  }

  // ADD DISCOUNT IMAGE
  Future<void> addDiscountImage() async {
    final images = await showImagePickDialog(context, true);
    if (images.isNotEmpty) {
      final im = images[0];
      setState(() {
        _image = File(im.path);
      });
    }
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
    SelectProductForDiscountProvider provider,
    List<String> productIdList,
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
      if (widget.changeSelectedProductDiscount == null) {
        if (provider.selectedProducts.isEmpty) {
          return mySnackBar(context, 'Select Product');
        }
      }

      if (isPercentSelected && int.parse(discountController.text) >= 100) {
        return mySnackBar(context, 'Max Discount is 99.99999999999999999999%');
      }

      setState(() {
        isUploading = true;
      });
      try {
        String discountId = const Uuid().v4();
        if (_image != null) {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('Vendor/Discounts/Products')
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

        for (String id in productIdList) {
          await store
              .collection('Business')
              .doc('Data')
              .collection('Products')
              .doc(id)
              .update({
            'discountId': discountId,
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
          'isBrands': false,
          'discountName': nameController.text.toString(),
          'discountAmount': double.parse(discountController.text),
          'discountStartDateTime': startDateTime,
          'discountEndDateTime': endDateTime,
          'discountId': discountId,
          'discountImageUrl': imageUrl,
          'products': widget.changeSelectedProductDiscount != null
              ? [
                  widget.changeSelectedProductDiscountId!,
                ]
              : productIdList,
          'categories': [],
          'brands': [],
          'vendorId': auth.currentUser!.uid,
          'Latitude': latitude,
          'Longitude': longitude,
        });
        provider.clear();
        if (mounted) {
          mySnackBar(context, 'Discount Added');
        }

        setState(() {
          isUploading = false;
        });
        if (widget.changeSelectedProductDiscount != null) {
          if (mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => ProductPage(
                      productId: widget.changeSelectedProductDiscountId!,
                      productName: widget.changeSelectedProductDiscountName!,
                    )),
              ),
            );
          }
        } else {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
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
    final selectedProductProvider =
        Provider.of<SelectProductForDiscountProvider>(context);
    final selectedProducts = selectedProductProvider.selectedProducts;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            selectedProductProvider.clear();
            Navigator.of(context).pop();
          },
          icon: const Icon(
            FeatherIcons.arrowLeft,
          ),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            onPressed: () {
              BetterFeedback.of(context).show((feedback) async {
                Future<String> writeImageToStorage(
                    Uint8List feedbackScreenshot) async {
                  final Directory output = await getTemporaryDirectory();
                  final String screenshotFilePath =
                      '${output.path}/feedback.png';
                  final File screenshotFile = File(screenshotFilePath);
                  await screenshotFile.writeAsBytes(feedbackScreenshot);
                  return screenshotFilePath;
                }

                final screenshotFilePath =
                    await writeImageToStorage(feedback.screenshot);

                final Email email = Email(
                  body: feedback.text,
                  subject: 'LS Business Feedback',
                  recipients: ['infinitylab1204@gmail.com'],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
              });
            },
            icon: const Icon(
              Icons.bug_report_outlined,
            ),
            tooltip: 'Report Problem',
          ),
          MyTextButton(
            onPressed: () async {
              await showLoadingDialog(
                context,
                () async {
                  await addDiscount(
                    selectedProductProvider,
                    selectedProducts,
                  );
                },
              );
            },
            text: 'DONE',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;

          return SingleChildScrollView(
            child: Form(
              key: discountKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Column(
                  children: [
                    // DISCLAIMER
                    Text(
                      'If your selected product/s has ongoing discount, then this discount will be applied, after that discount ends (if this discount ends after that)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryDark2,
                        fontSize: width * 0.0375,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

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
                            width: 3,
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
                                      borderRadius: BorderRadius.circular(6),
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
                                            size: width * 0.11,
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
                                            size: width * 0.11,
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
                        GestureDetector(
                          onTap: () async {
                            await selectStartDate();
                          },
                          child: Container(
                            height: 100,
                            width: width * 0.45,
                            decoration: BoxDecoration(
                              color: primary3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                size: width * 0.066,
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
                                          left: width * 0.036,
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
                            width: width * 0.45,
                            decoration: BoxDecoration(
                              color: primary3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                size: width * 0.066,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child: Text(
                        'If you select 1 jan as end date, discount will end at 31 dec 11:59 pm',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryDark2,
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SELECT PRODUCT
                    MyButton(
                      text: widget.changeSelectedProductDiscount != null
                          ? widget.changeSelectedProductDiscountName!
                          : selectedProducts.isEmpty
                              ? 'SELECT PRODUCTS'
                              : 'SELECTED PRODUCTS - ${selectedProducts.length}',
                      onTap: widget.changeSelectedProductDiscount != null
                          ? () {}
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SelectProductForDiscountPage(),
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
                                      : primary2.withOpacity(0.05),
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
            ),
          );
        }),
      ),
    );
  }
}
