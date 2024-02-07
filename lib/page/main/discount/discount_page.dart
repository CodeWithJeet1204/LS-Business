import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  bool isPressed1 = false;
  bool isPressed2 = false;
  bool isPressed3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text("DISCOUNTS"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedOverflowBox(
                    size: Size(width, height * 0.266),
                    child: GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          isPressed1 = true;
                        });
                      },
                      onTapUp: (details) {},
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: isPressed1 ? width * 0.9 : width,
                          height: isPressed1 ? height * 0.19 : height * 0.2,
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.67),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: width * 0.1),
                              SizedBox(
                                width: width * 0.5,
                                child: const AutoSizeText(
                                  "SINGLE PRODUCT",
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                              Icon(
                                Icons.arrow_circle_up_outlined,
                                size: width * 0.2,
                                color: primaryDark2,
                              ),
                              SizedBox(width: width * 0.075),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedOverflowBox(
                    size: Size(width, height * 0.275),
                    child: GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          isPressed3 = true;
                        });
                      },
                      onTapUp: (details) {},
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: isPressed3 ? width * 0.9 : width,
                          height: isPressed3 ? height * 0.19 : height * 0.2,
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.67),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: width * 0.1),
                              SizedBox(
                                width: width * 0.5,
                                child: const AutoSizeText(
                                  "MULTIPLE PRODUCTS",
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: width * 0.2,
                                color: primaryDark2,
                              ),
                              SizedBox(width: width * 0.075),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedOverflowBox(
                    size: Size(width, height * 0.275),
                    child: GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          isPressed2 = true;
                        });
                      },
                      onTapUp: (details) {},
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: isPressed2 ? width * 0.9 : width,
                          height: isPressed2 ? height * 0.19 : height * 0.2,
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(0.67),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: width * 0.1),
                              SizedBox(
                                width: width * 0.5,
                                child: const AutoSizeText(
                                  "CATEGORY",
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                              Icon(
                                Icons.apps_outlined,
                                size: width * 0.2,
                                color: primaryDark2,
                              ),
                              SizedBox(width: width * 0.075),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
