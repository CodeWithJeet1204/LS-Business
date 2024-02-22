import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_easy/page/main/discount/brand/brand_discount.dart';
import 'package:find_easy/page/main/discount/category/category_discount.dart';
import 'package:find_easy/page/main/discount/products/product_discount.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class AddDiscountPage extends StatefulWidget {
  const AddDiscountPage({super.key});

  @override
  State<AddDiscountPage> createState() => _AddDiscountPageState();
}

class _AddDiscountPageState extends State<AddDiscountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(overflow: TextOverflow.ellipsis, "DISCOUNTS"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // PRODUCTS
                  SizedOverflowBox(
                    size: Size(width, width * 0.5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => const ProductDiscountPage()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: width * 0.375,
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
                                overflow: TextOverflow.ellipsis,
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
                    size: Size(width, width * 0.5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) =>
                                const CategoryDiscountPage()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: width * 0.375,
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
                                overflow: TextOverflow.ellipsis,
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

                  // BRAND
                  SizedOverflowBox(
                    size: Size(width, width * 0.5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => const BrandDiscountPage()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: width * 0.375,
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
                                overflow: TextOverflow.ellipsis,
                                "BRAND",
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
