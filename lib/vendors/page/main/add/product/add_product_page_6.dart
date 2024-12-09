import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/provider/add_product_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/check_box_container.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AddProductPage6 extends StatefulWidget {
  const AddProductPage6({
    super.key,
  });

  @override
  State<AddProductPage6> createState() => _AddProductPage6State();
}

class _AddProductPage6State extends State<AddProductPage6> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  bool isDeliveryAvailable = false;
  bool isCODAvailable = false;
  bool isRefundAvailable = false;
  bool isReplacementAvailable = false;
  bool isGiftWrapAvailable = false;
  bool isBulkSellAvailable = false;
  bool isGSTInvoiceAvailable = false;
  bool isCardOffersAvailable = false;
  double? deliveryRange;
  double? refundRange;
  int? replacementRange;
  int? giftWrapExtraRate;
  bool isSaving = false;
  bool isDialog = false;

  Future<void> save(AddProductProvider provider) async {
    try {
      setState(() {
        isSaving = true;
        isDialog = true;
      });
      final List<String> imageDownloadUrl = [];

      try {
        await Future.wait(
          (provider.productInfo['imageFiles'] as List<File>).map((img) async {
            Reference ref =
                storage.ref().child('Vendor/Products').child(const Uuid().v4());
            await ref.putFile(img);
            String downloadUrl = await ref.getDownloadURL();
            if (mounted) {
              setState(() {
                imageDownloadUrl.add(downloadUrl);
              });
            }
          }),
        );
      } catch (e) {
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }

      provider.add(
        {
          'deliveryAvailable': isDeliveryAvailable,
          'codAvailable': isDeliveryAvailable ? isCODAvailable : false,
          'refundAvailable': isRefundAvailable,
          'replacementAvailable': isReplacementAvailable,
          'giftWrapAvailable': isGiftWrapAvailable,
          'bulkSellAvailable': isBulkSellAvailable,
          'gstInvoiceAvailable': isGSTInvoiceAvailable,
          'cardOffersAvailable': isCardOffersAvailable,
          'deliveryRange': deliveryRange,
          'refundRange': refundRange,
          'replacementRange': replacementRange,
          'giftWrapExtraRate': giftWrapExtraRate,
          'images': imageDownloadUrl,
          'shortsThumbnail': '',
          'shortsURL': '',
        },
        true,
      );
      provider.remove('imageFiles');

      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(provider.productInfo['productId'])
          .set(provider.productInfo);

      setState(() {
        isSaving = false;
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, 'Product Added');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<AddProductProvider>(context);

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: LoadingIndicator(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Services Available'),
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
                onTap: () async {
                  await save(productProvider);
                },
                text: 'DONE',
                textColor: primaryDark2,
              ),
            ],
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.0225,
                  vertical: width * 0.0125,
                ),
                child: Column(
                  children: [
                    // DELIVERY AVAILABLE
                    CheckBoxContainer(
                      text: 'Delivery Available ?',
                      value: isDeliveryAvailable,
                      function: (_) {
                        setState(() {
                          isDeliveryAvailable = !isDeliveryAvailable;
                        });
                      },
                      width: width,
                    ),

                    // DELIVERY RANGE
                    isDeliveryAvailable
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.025,
                            ),
                            child: Container(
                              width: width,
                              height: width * 0.125,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primary2,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: 'Range of Delivery (in Km)',
                                  hintStyle: TextStyle(
                                    color: primaryDark2.withOpacity(0.8),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    deliveryRange = double.parse(value);
                                  });
                                },
                              ),
                            ),
                          )
                        : Container(),

                    // COD ON DELIVERY
                    isDeliveryAvailable
                        ? Container(
                            width: width,
                            height: width * 0.125,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0225,
                            ),
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  'Cash On Delivery',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: primaryDark2,
                                    fontWeight: FontWeight.w500,
                                    fontSize: width * 0.05,
                                  ),
                                ),
                                Checkbox(
                                  activeColor: primaryDark2,
                                  checkColor: white,
                                  value: isCODAvailable,
                                  onChanged: ((value) {
                                    setState(() {
                                      isCODAvailable = !isCODAvailable;
                                    });
                                  }),
                                ),
                              ],
                            ),
                          )
                        : Container(),

                    const Divider(),

                    // REFUND
                    CheckBoxContainer(
                      text: 'Refund Available ?',
                      value: isRefundAvailable,
                      function: (_) {
                        setState(() {
                          isRefundAvailable = !isRefundAvailable;
                        });
                      },
                      width: width,
                    ),

                    // REFUND DATE RANGE
                    isRefundAvailable
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.025,
                            ),
                            child: Container(
                              width: width,
                              height: width * 0.125,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primary2,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: 'Days To Return',
                                  hintStyle: TextStyle(
                                    color: primaryDark2.withOpacity(0.8),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    refundRange = double.parse(value);
                                  });
                                },
                              ),
                            ),
                          )
                        : Container(),

                    const Divider(),

                    // REPLACEMENT
                    CheckBoxContainer(
                      text: 'Replacement Available ?',
                      value: isReplacementAvailable,
                      function: (_) {
                        setState(() {
                          isReplacementAvailable = !isReplacementAvailable;
                        });
                      },
                      width: width,
                    ),

                    // REPLACEMENT DATE RANGE
                    isReplacementAvailable
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.025,
                            ),
                            child: Container(
                              width: width,
                              height: width * 0.125,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primary2,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: 'Days To Replace',
                                  hintStyle: TextStyle(
                                    color: primaryDark2.withOpacity(0.8),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    replacementRange = int.parse(value);
                                  });
                                },
                              ),
                            ),
                          )
                        : Container(),

                    const Divider(),

                    // GIFT WRAP
                    CheckBoxContainer(
                      text: 'Gift Wrap ?',
                      value: isGiftWrapAvailable,
                      function: (_) {
                        setState(() {
                          isGiftWrapAvailable = !isGiftWrapAvailable;
                        });
                      },
                      width: width,
                    ),

                    // REPLACEMENT DATE RANGE
                    isGiftWrapAvailable
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.025,
                            ),
                            child: Container(
                              width: width,
                              height: width * 0.125,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primary2,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: 'Extra Rate',
                                  hintStyle: TextStyle(
                                    color: primaryDark2.withOpacity(0.8),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    giftWrapExtraRate = int.parse(value);
                                  });
                                },
                              ),
                            ),
                          )
                        : Container(),

                    const Divider(),

                    // BULK SELL
                    CheckBoxContainer(
                      text: 'Bulk Selling ?',
                      value: isBulkSellAvailable,
                      function: (_) {
                        setState(() {
                          isBulkSellAvailable = !isBulkSellAvailable;
                        });
                      },
                      width: width,
                    ),

                    const Divider(),

                    // GST INVOICE
                    CheckBoxContainer(
                      text: 'GST Invoice',
                      value: isGSTInvoiceAvailable,
                      function: (_) {
                        setState(() {
                          isGSTInvoiceAvailable = !isGSTInvoiceAvailable;
                        });
                      },
                      width: width,
                    ),

                    const Divider(),

                    // MEMBERSHIP
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: CheckBoxContainer(
                        text: 'Card Offers ?',
                        value: isCardOffersAvailable,
                        function: (_) {
                          setState(() {
                            isCardOffersAvailable = !isCardOffersAvailable;
                          });
                        },
                        width: width,
                      ),
                    ),

                    SizedBox(height: width * 0.0125),
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
