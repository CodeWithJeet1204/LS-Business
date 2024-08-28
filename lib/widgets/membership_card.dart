import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MembershipCard extends StatefulWidget {
  const MembershipCard({
    super.key,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBorderColor,
    required this.name,
    required this.discountPrice,
    required this.originalPrice,
    required this.discount,
    required this.width,
    required this.textColor,
    required this.priceTextColor,
    required this.benefitBackSelectedColor,
    this.benefit1,
    this.benefit2,
    this.benefit3,
    this.benefit4,
    this.benefit5,
    required this.onTap,
    // required this.storageSize,
    // this.storageUnit = 'GB',
  });

  final String name;
  final double discountPrice;
  final int originalPrice;
  final int discount;
  final double width;
  final String? benefit1;
  final String? benefit2;
  final String? benefit3;
  final String? benefit4;
  final String? benefit5;
  // final int storageSize;
  // final String storageUnit;
  final bool isSelected;
  final void Function()? onTap;
  final Color selectedColor;
  final Color benefitBackSelectedColor;
  final Color textColor;
  final Color priceTextColor;
  final Color selectedBorderColor;

  @override
  State<MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<MembershipCard> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSelected ? width * 0.0225 : width * 0.033,
        vertical: widget.isSelected ? width * 0.0225 : width * 0.033,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: widget.isSelected ? 1 : 0.6,
          child: Container(
            width: widget.width,
            height: widget.isSelected ? width * 0.5833 : width * 0.55,
            decoration: BoxDecoration(
              color: widget.selectedColor,
              border: Border.all(
                color: widget.isSelected
                    ? widget.selectedBorderColor
                    : Colors.grey.shade900,
                width: widget.isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(width: width * 0.025),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.name == 'PREMIUM'
                            ? width * 0.088
                            : width * 0.11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: width * 0.44125,
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * 0.09,
                            child: AutoSizeText(
                              'Rs. ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: width * 0.0611,
                                fontWeight: FontWeight.w500,
                                color: widget.priceTextColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width * 0.1775,
                            child: AutoSizeText(
                              widget.discountPrice.toStringAsFixed(0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: width * 0.0611,
                                fontWeight: FontWeight.w600,
                                color: widget.priceTextColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width * 0.1675,
                            child: AutoSizeText(
                              widget.originalPrice.toStringAsFixed(0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: width * 0.0475,
                                fontWeight: FontWeight.w500,
                                color: widget.priceTextColor,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.red,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width * 0.44125,
                      child: AutoSizeText(
                        '${widget.discount.toString()}% OFF',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: width * 0.055,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 4,
                  child: Container(),
                ),
                Container(
                  height: double.infinity,
                  width: 160,
                  decoration: BoxDecoration(
                    color: widget.benefitBackSelectedColor,
                    // color: Color.fromARGB(255, 30, 29, 29),
                    border: Border.all(
                      color: widget.selectedBorderColor.withOpacity(0.2),
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 44),
                        child: Text(
                          'BENEFITS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.josefinSans(
                            color: white,
                            fontSize: width * 0.05,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.benefit1 == null
                                ? Container()
                                : Text(
                                    '• ${widget.benefit1}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: white,
                                      fontSize: width * 0.044,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            widget.benefit2 == null
                                ? Container()
                                : Text(
                                    '• ${widget.benefit2}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: white,
                                      fontSize: width * 0.044,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            widget.benefit3 == null
                                ? Container()
                                : Text(
                                    '• ${widget.benefit3}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: white,
                                      fontSize: width * 0.044,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            widget.benefit4 == null
                                ? Container()
                                : Text(
                                    '• ${widget.benefit4}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: white,
                                      fontSize: width * 0.044,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            widget.benefit5 == null
                                ? Container()
                                : Text(
                                    '• ${widget.benefit5}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: white,
                                      fontSize: width * 0.044,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 50,
                      //     decoration: BoxDecoration(
                      //       color: widget.selectedColor.withOpacity(0.8),
                      //       borderRadius: BorderRadius.circular(9),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       crossAxisAlignment: CrossAxisAlignment.baseline,
                      //       textBaseline: TextBaseline.ideographic,
                      //       children: [
                      //         Text(
                      //           widget.storageSize.toString(),
                      //           maxLines: 1,
                      //           overflow: TextOverflow.ellipsis,
                      //           style: TextStyle(
                      //             fontSize: width * 0.11,
                      //             fontWeight: FontWeight.w800,
                      //             color: widget.textColor,
                      //           ),
                      //         ),
                      //         const SizedBox(width: 4),
                      //         Text(
                      //           widget.storageUnit,
                      //           maxLines: 1,
                      //           overflow: TextOverflow.ellipsis,
                      //           style: TextStyle(
                      //             fontSize: width * 0.055,
                      //             fontWeight: FontWeight.w600,
                      //             color: widget.priceTextColor,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
