import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_easy/page/main/discount/category/category_discount.dart';
import 'package:find_easy/page/main/discount/products/product_discount.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  // PRODUCTS
                  SizedOverflowBox(
                    size: Size(width, height * 0.266),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => ProductDiscountPage()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: height * 0.2,
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
                                "PRODUCT",
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

                  // CATEGORY
                  SizedOverflowBox(
                    size: Size(width, height * 0.275),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => CategoryDiscountPage()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: height * 0.2,
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
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
