import 'package:Localsearch/events/profile/add_event/events_add_event_page_4.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'package:flutter/material.dart';

class EventsAddEventPage3 extends StatefulWidget {
  const EventsAddEventPage3({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  State<EventsAddEventPage3> createState() => _EventsAddEventPage3State();
}

class _EventsAddEventPage3State extends State<EventsAddEventPage3> {
  final priceController = TextEditingController();
  final vipPriceController = TextEditingController();
  final earlyBirdPriceController = TextEditingController();
  final groupPriceController = TextEditingController();
  final noOfTicketsController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  final refundDaysController = TextEditingController();
  final promoCodeController = TextEditingController();
  final promoCodePriceController = TextEditingController();
  bool isVIP = false;
  bool isEarlyBird = false;
  bool isGroup = false;
  bool isOnlineTicket = false;
  bool isOfflineTicket = false;
  bool isRefund = false;
  bool isPromo = false;
  bool isNext = false;

  // NEXT
  void next() {
    Map<String, dynamic> data = {
      'ticketPrice': priceController.text,
      'ticketVIPPrice': isVIP ? vipPriceController.text : null,
      'ticketEarlyBirdPrice':
          isEarlyBird ? earlyBirdPriceController.text : null,
      'ticketGroupPrice': isGroup ? groupPriceController.text : null,
      'ticketNoOfTickets': noOfTicketsController.text,
      'ticketWebsite': isOnlineTicket ? websiteController.text : null,
      'ticketAddress': isOfflineTicket ? addressController.text : null,
      'ticketRefundDays': isRefund ? refundDaysController.text : null,
      'ticketPromoCode': isPromo ? promoCodeController.text : null,
      'ticketPromoCodePrice': isPromo ? promoCodePriceController.text : null,
    };

    data.addAll(widget.data);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => EventsAddEventPage4(
              data: data,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Pricing'),
        actions: [
          MyTextButton(
            onPressed: next,
            text: 'NEXT',
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isNext ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isNext ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.0125,
          ),
          child: LayoutBuilder(builder: ((context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BASE PRICE
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.025),
                    child: const Text(
                      'Price',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // BASE PRICE
                  MyTextFormField(
                    hintText: 'Base Price',
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    borderRadius: 8,
                    horizontalPadding: 0,
                  ),

                  const SizedBox(height: 8),

                  const Divider(),

                  const SizedBox(height: 8),

                  // TICKET TYPE
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.025),
                    child: const Text(
                      'Ticket Types',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TICKET TYPES
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: primary2.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.all(width * 0.0125),
                    child: Column(
                      children: [
                        // VIP
                        Container(
                          width: width,
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(width * 0.0225),
                          child: !isVIP
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'VIP',
                                    ),
                                    Checkbox(
                                        activeColor: primaryDark,
                                        checkColor: white,
                                        value: isVIP,
                                        onChanged: (value) {
                                          setState(() {
                                            isVIP = !isVIP;
                                          });
                                        }),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'VIP',
                                        ),
                                        Checkbox(
                                            activeColor: primaryDark,
                                            checkColor: white,
                                            value: isVIP,
                                            onChanged: (value) {
                                              setState(() {
                                                isVIP = !isVIP;
                                              });
                                            }),
                                      ],
                                    ),
                                    MyTextFormField(
                                      hintText: 'Price',
                                      controller: vipPriceController,
                                      keyboardType: TextInputType.number,
                                      borderRadius: 8,
                                      horizontalPadding: 0,
                                    ),
                                  ],
                                ),
                        ),

                        Divider(
                          color: primaryDark.withOpacity(0.05),
                        ),

                        // EARLY BIRD
                        Container(
                          width: width,
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(width * 0.0225),
                          child: !isEarlyBird
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Early Bird',
                                    ),
                                    Checkbox(
                                        activeColor: primaryDark,
                                        checkColor: white,
                                        value: isEarlyBird,
                                        onChanged: (value) {
                                          setState(() {
                                            isEarlyBird = !isEarlyBird;
                                          });
                                        }),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Early Bird',
                                        ),
                                        Checkbox(
                                            activeColor: primaryDark,
                                            checkColor: white,
                                            value: isEarlyBird,
                                            onChanged: (value) {
                                              setState(() {
                                                isEarlyBird = !isEarlyBird;
                                              });
                                            }),
                                      ],
                                    ),
                                    MyTextFormField(
                                      hintText: 'Price',
                                      controller: earlyBirdPriceController,
                                      keyboardType: TextInputType.number,
                                      borderRadius: 8,
                                      horizontalPadding: 0,
                                    ),
                                  ],
                                ),
                        ),

                        Divider(
                          color: primaryDark.withOpacity(0.05),
                        ),

                        // GROUP
                        Container(
                          width: width,
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(width * 0.0225),
                          child: !isGroup
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Group',
                                    ),
                                    Checkbox(
                                        activeColor: primaryDark,
                                        checkColor: white,
                                        value: isGroup,
                                        onChanged: (value) {
                                          setState(() {
                                            isGroup = !isGroup;
                                          });
                                        }),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Group',
                                        ),
                                        Checkbox(
                                            activeColor: primaryDark,
                                            checkColor: white,
                                            value: isGroup,
                                            onChanged: (value) {
                                              setState(() {
                                                isGroup = !isGroup;
                                              });
                                            }),
                                      ],
                                    ),
                                    MyTextFormField(
                                      hintText: 'Price (per Person)',
                                      controller: groupPriceController,
                                      keyboardType: TextInputType.number,
                                      borderRadius: 8,
                                      horizontalPadding: 0,
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Divider(),

                  const SizedBox(height: 8),

                  // NUMBER OF TICKET
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.025),
                    child: const Text(
                      'Number of Tickets for Sale',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // NUMBER OF TICKETS
                  MyTextFormField(
                    hintText: 'No. of Tickets for Sale',
                    controller: noOfTicketsController,
                    borderRadius: 8,
                    horizontalPadding: 0,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 8),

                  const Divider(),

                  const SizedBox(height: 8),

                  // TICKET BUYING OPTION
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.025),
                    child: const Text(
                      'Ticket Buying Options',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TICKET BUYING OPTIONS
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: primary2.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(width * 0.0125),
                    margin: EdgeInsets.all(width * 0.0125),
                    child: Column(
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: SizedBox(
                            width: width,
                            child: !isOnlineTicket
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Online',
                                      ),
                                      Checkbox(
                                          activeColor: primaryDark,
                                          checkColor: white,
                                          value: isOnlineTicket,
                                          onChanged: (value) {
                                            setState(() {
                                              isOnlineTicket = !isOnlineTicket;
                                            });
                                          }),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Online',
                                          ),
                                          Checkbox(
                                              activeColor: primaryDark,
                                              checkColor: white,
                                              value: isOnlineTicket,
                                              onChanged: (value) {
                                                setState(() {
                                                  isOnlineTicket =
                                                      !isOnlineTicket;
                                                });
                                              }),
                                        ],
                                      ),
                                      MyTextFormField(
                                        hintText: 'Website Link',
                                        controller: websiteController,
                                        borderRadius: 8,
                                        horizontalPadding: 0,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        Divider(
                          color: primaryDark.withOpacity(0.05),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: SizedBox(
                            width: width,
                            child: !isOfflineTicket
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Offline',
                                      ),
                                      Checkbox(
                                          activeColor: primaryDark,
                                          checkColor: white,
                                          value: isOfflineTicket,
                                          onChanged: (value) {
                                            setState(() {
                                              isOfflineTicket =
                                                  !isOfflineTicket;
                                            });
                                          }),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Offline',
                                          ),
                                          Checkbox(
                                              activeColor: primaryDark,
                                              checkColor: white,
                                              value: isOfflineTicket,
                                              onChanged: (value) {
                                                setState(() {
                                                  isOfflineTicket =
                                                      !isOfflineTicket;
                                                });
                                              }),
                                        ],
                                      ),
                                      MyTextFormField(
                                        hintText: 'Address',
                                        controller: addressController,
                                        borderRadius: 8,
                                        horizontalPadding: 0,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Divider(),

                  const SizedBox(height: 8),

                  // REFUND
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.025),
                    child: const Text(
                      'Refund',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // REFUND
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                        color: primary2.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(width * 0.0125),
                      margin: EdgeInsets.all(width * 0.0125),
                      child: !isRefund
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Refund',
                                ),
                                Checkbox(
                                    activeColor: primaryDark,
                                    checkColor: white,
                                    value: isRefund,
                                    onChanged: (value) {
                                      setState(() {
                                        isRefund = !isRefund;
                                      });
                                    }),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Refund',
                                    ),
                                    Checkbox(
                                        activeColor: primaryDark,
                                        checkColor: white,
                                        value: isRefund,
                                        onChanged: (value) {
                                          setState(() {
                                            isRefund = !isRefund;
                                          });
                                        }),
                                  ],
                                ),
                                MyTextFormField(
                                  hintText: 'Number of Days',
                                  controller: refundDaysController,
                                  borderRadius: 8,
                                  horizontalPadding: 0,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Divider(),

                  const SizedBox(height: 8),

                  // PROMO CODE
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.025),
                    child: const Text(
                      'Promotional Codes',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PROMO CODES
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                        color: primary2.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(width * 0.0125),
                      margin: EdgeInsets.all(width * 0.0125),
                      child: !isPromo
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Promo Codes',
                                ),
                                Checkbox(
                                    activeColor: primaryDark,
                                    checkColor: white,
                                    value: isPromo,
                                    onChanged: (value) {
                                      setState(() {
                                        isPromo = !isPromo;
                                      });
                                    }),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Promo Codes',
                                    ),
                                    Checkbox(
                                        activeColor: primaryDark,
                                        checkColor: white,
                                        value: isPromo,
                                        onChanged: (value) {
                                          setState(() {
                                            isPromo = !isPromo;
                                          });
                                        }),
                                  ],
                                ),
                                MyTextFormField(
                                  hintText: 'Code',
                                  controller: promoCodeController,
                                  borderRadius: 8,
                                  horizontalPadding: 0,
                                ),
                                const SizedBox(height: 4),
                                MyTextFormField(
                                  hintText: 'Discount (Rs.)',
                                  controller: promoCodePriceController,
                                  borderRadius: 8,
                                  horizontalPadding: 0,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          })),
        ),
      ),
    );
  }
}
