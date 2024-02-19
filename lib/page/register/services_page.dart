import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/register/membership.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/check_box_container.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectServicesPage extends StatefulWidget {
  const SelectServicesPage({super.key});

  @override
  State<SelectServicesPage> createState() => _SelectServicesPageState();
}

class _SelectServicesPageState extends State<SelectServicesPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isDeliveryAvailable = false;
  bool isCODAvailable = false;
  bool isRefundAvailable = false;
  bool isReplacementAvailable = false;
  bool isGiftWrapAvailable = false;
  bool isBulkSellAvailable = false;
  bool isGSTInvoiceAvailable = false;
  bool isMembershipAvailable = false;
  int? deliveryRange;
  int? refundRange;
  int? replacementRange;
  bool isSaving = false;

  Future<void> save() async {
    try {
      setState(() {
        isSaving = true;
      });
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'deliveryAvailable': isDeliveryAvailable,
        'codAvailable': isCODAvailable,
        'refundAvailable': isRefundAvailable,
        'replacementAvailable': isReplacementAvailable,
        'giftWrapAvailable': isGiftWrapAvailable,
        'bulkSellAvailable': isBulkSellAvailable,
        'gstInvoiceAvailable': isGSTInvoiceAvailable,
        'membershipAvailable': isMembershipAvailable,
        'deliveryRange': deliveryRange,
        'refundRange': refundRange,
        'replacementRange': replacementRange,
      });
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
    return Scaffold(
      appBar: AppBar(
        title: Text('SERVICES Available'),
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
                  CheckBoxContainer(
                    text: 'Membership Card / Offer ?',
                    value: isMembershipAvailable,
                    function: (_) {
                      setState(() {
                        isMembershipAvailable = !isMembershipAvailable;
                      });
                    },
                    width: width,
                  ),

                  SizedBox(height: width * 0.05),

                  // NEXT BUTTON
                  MyButton(
                    text: 'NEXT',
                    onTap: () async {
                      await save();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: ((context) => SelectMembershipPage()),
                        ),
                      );
                    },
                    isLoading: isSaving,
                    horizontalPadding: 0,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
