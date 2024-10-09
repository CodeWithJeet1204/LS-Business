import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

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
    required this.textColor,
    required this.priceTextColor,
    required this.benefitBackSelectedColor,
    required this.onTap,
    this.benefit1,
    this.benefit2,
    this.benefit3,
    this.benefit4,
    this.benefit5,
    // required this.storageSize,
    // this.storageUnit = 'GB',
  });

  final String name;
  final double? discountPrice;
  final int? originalPrice;
  final int? discount;
  final String? benefit1;
  final String? benefit2;
  final String? benefit3;
  final String? benefit4;
  final String? benefit5;
  // final int storageSize;
  // final String storageUnit;
  final bool isSelected;
  final void Function() onTap;
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
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(
        width * (widget.isSelected ? 0.0125 : 0.025),
      ),
      child: Opacity(
        opacity: widget.isSelected ? 1 : 0.66,
        child: ExpansionTile(
          title: AutoSizeText(
            widget.name.toString().trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width * 0.06,
              fontWeight: FontWeight.w600,
            ),
          ),
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor:
              widget.selectedColor.withOpacity(widget.isSelected ? 1 : 0.66),
          collapsedBackgroundColor:
              widget.selectedColor.withOpacity(widget.isSelected ? 1 : 0.66),
          textColor: widget.textColor,
          collapsedTextColor: widget.textColor,
          iconColor: widget.textColor,
          collapsedIconColor: widget.textColor,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: primaryDark.withOpacity(0.1),
            ),
          ),
          collapsedShape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: primaryDark.withOpacity(0.33),
            ),
          ),
          trailing: widget.isSelected
              ? Icon(
                  FeatherIcons.check,
                  size: width * 0.09,
                )
              : null,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.0125,
                vertical: height * 0.006125,
              ),
              child: SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: width * 0.0125),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
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
                                    widget.discountPrice == null
                                        ? Container()
                                        : AutoSizeText(
                                            widget.discountPrice!
                                                .toStringAsFixed(0),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: width * 0.0611,
                                              fontWeight: FontWeight.w600,
                                              color: widget.priceTextColor,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              widget.name == 'FREE Registration' ||
                                      widget.originalPrice == null
                                  ? Container()
                                  : AutoSizeText(
                                      widget.originalPrice!.toStringAsFixed(0),
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
                            ],
                          ),
                        ),
                        widget.discount == null
                            ? Container()
                            : AutoSizeText(
                                '${widget.discount.toString()}% OFF',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: width * 0.055,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: height * 0.006125),
                    Container(
                      width: width,
                      decoration: BoxDecoration(
                        color: widget.benefitBackSelectedColor,
                        border: Border.all(
                          color: widget.selectedBorderColor.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(
                          widget.isSelected ? 9 : 11,
                        ),
                      ),
                      padding: EdgeInsets.all(width * 0.0125),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BENEFITS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: white,
                              fontSize: width * 0.05,
                            ),
                          ),
                          SizedBox(height: height * 0.0125),
                          Column(
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
                    SizedBox(height: height * 0.003125),
                    MyTextButton(
                      onPressed: widget.onTap,
                      text: widget.isSelected ? 'SELECTED' : 'Select',
                      textColor: widget.textColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
