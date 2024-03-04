import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/main_page.dart';
import 'package:find_easy/provider/add_product_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/check_box_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProductPage3 extends StatefulWidget {
  const AddProductPage3({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  State<AddProductPage3> createState() => _AddProductPage3State();
}

class _AddProductPage3State extends State<AddProductPage3> {
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
  int? deliveryRange;
  int? refundRange;
  int? replacementRange;
  bool isSaving = false;

  Future<void> save(AddProductProvider provider) async {
    try {
      setState(() {
        isSaving = true;
      });

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
        },
        true,
      );

      await store
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(widget.productId)
          .set(provider.productInfo);

      mySnackBar(context, "Product Added");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: ((context) => MainPage()),
        ),
        (route) => false,
      );
      setState(() {
        isSaving = false;
      });
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      mySnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<AddProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          overflow: TextOverflow.ellipsis,
          'SERVICES AVAILABLE',
        ),
        actions: [
          MyTextButton(
            onPressed: () {
              save(productProvider);
            },
            text: 'DONE',
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isSaving ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isSaving ? const LinearProgressIndicator() : Container(),
        ),
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
                              decoration: InputDecoration(
                                hintText: "Range of Delivery (in Km)",
                                hintStyle: TextStyle(
                                  color: primaryDark2.withOpacity(0.8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  deliveryRange = int.parse(value);
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
                              Text(
                                overflow: TextOverflow.ellipsis,
                                'Cash On Delivery',
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
                                    print(isCODAvailable);
                                  });
                                }),
                              ),
                            ],
                          ),
                        )
                      : Container(),

                  Divider(),

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
                              decoration: InputDecoration(
                                hintText: "Days To Return",
                                hintStyle: TextStyle(
                                  color: primaryDark2.withOpacity(0.8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  refundRange = int.parse(value);
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),

                  Divider(),

                  // REPLACEMENT
                  CheckBoxContainer(
                    text: 'Replacement Available ?',
                    value: isReplacementAvailable,
                    function: (_) {
                      setState(() {
                        isReplacementAvailable = !isReplacementAvailable;
                        print(isReplacementAvailable);
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
                              decoration: InputDecoration(
                                hintText: "Days To Replace",
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

                  Divider(),

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

                  Divider(),

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

                  Divider(),

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

                  Divider(),

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
