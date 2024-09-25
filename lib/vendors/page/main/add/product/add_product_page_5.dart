import 'dart:io';
import 'package:ls_business/widgets/show_loading_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/provider/add_product_provider.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/check_box_container.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddProductPage5 extends StatefulWidget {
  const AddProductPage5({
    super.key,
  });

  @override
  State<AddProductPage5> createState() => _AddProductPage5State();
}

class _AddProductPage5State extends State<AddProductPage5> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
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
  bool isSaving = false;

  Future<void> save(AddProductProvider provider) async {
    try {
      setState(() {
        isSaving = true;
      });
      final List<String> imageDownloadUrl = [];

      for (File img in (provider.productInfo['imageFiles'] as List<File>)) {
        try {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('Vendor/Products')
              .child(const Uuid().v4());
          await ref.putFile(img).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              setState(() {
                imageDownloadUrl.add(value);
              });
            });
          });
        } catch (e) {
          if (mounted) {
            mySnackBar(context, e.toString());
          }
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
      });
      if (mounted) {
        mySnackBar(context, 'Product Added');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: ((context) => const MainPage()),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<AddProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SERVICES AVAILABLE',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              await showLoadingDialog(
                context,
                () async {
                  await save(productProvider);
                },
              );
            },
            text: 'DONE',
            textColor: primaryDark2,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
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
                    text: 'Self Delivery Available ?',
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
    );
  }
}
