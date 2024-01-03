import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MembershipCard extends StatefulWidget {
  const MembershipCard({
    super.key,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBorderColor,
    required this.name,
    required this.price,
    required this.width,
    required this.textColor,
    required this.priceTextColor,
    required this.benefitBackSelectedColor,
    required this.benefit1,
    required this.benefit2,
    required this.benefit3,
    required this.storageSize,
    required this.onTap,
    this.storageUnit = "GB",
  });

  final String name;
  final String price;
  final double width;
  final int benefit1;
  final int benefit2;
  final int benefit3;
  final int storageSize;
  final String storageUnit;
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isSelected ? 8 : 12),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: widget.isSelected ? 1 : 0.6,
          child: Container(
            width: widget.width,
            height: widget.isSelected ? 210 : 200,
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
                SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.name == "PREMIUM" ? 32 : 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text("Rs. "),
                        Text(
                          widget.price.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: widget.priceTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Container(),
                  flex: 4,
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
                    borderRadius: BorderRadius.only(
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
                          "BENEFITS",
                          style: GoogleFonts.josefinSans(
                            color: white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "• ${widget.benefit1} Posts",
                              style: TextStyle(
                                color: white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "• ${widget.benefit2} Story",
                              style: TextStyle(
                                color: white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "• ${widget.benefit3} Shorts",
                              style: TextStyle(
                                color: white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: widget.selectedColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              Text(
                                widget.storageSize.toString(),
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: widget.textColor,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.storageUnit,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: widget.priceTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
