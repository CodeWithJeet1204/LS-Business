import 'package:auto_size_text/auto_size_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/discount/brand/brand_discount_page.dart';
import 'package:localy/vendors/page/main/discount/products/product_discount_page.dart';
import 'package:localy/vendors/utils/colors.dart';
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
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'DISCOUNTS',
        ),
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
                              child: AutoSizeText(
                                'PRODUCT',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.0775,
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                            Icon(
                              FeatherIcons.box,
                              size: width * 0.1,
                              color: primaryDark2,
                            ),
                            SizedBox(width: width * 0.075),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CATEGORY
                  // SizedOverflowBox(
                  //   size: Size(width, width * 0.5),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.of(context).push(
                  //         MaterialPageRoute(
                  //           builder: ((context) =>
                  //               const CategoryDiscountPage()),
                  //         ),
                  //       );
                  //     },
                  //     child: Container(
                  //       margin: const EdgeInsets.symmetric(horizontal: 12),
                  //       width: width,
                  //       height: width * 0.375,
                  //       decoration: BoxDecoration(
                  //         color: primary2.withOpacity(0.67),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Row(
                  //         children: [
                  //           SizedBox(width: width * 0.1),
                  //           SizedBox(
                  //             width: width * 0.5,
                  //             child: const AutoSizeText(
                  //               overflow: TextOverflow.ellipsis,
                  //               'CATEGORY',
                  //               style: TextStyle(
                  //                 color: primaryDark,
                  //                 fontWeight: FontWeight.w600,
                  //                 fontSize: 28,
                  //               ),
                  //             ),
                  //           ),
                  //           Expanded(child: Container()),
                  //           Icon(
                  //             FeatherIcons.layers,
                  //             size: width * 0.2,
                  //             color: primaryDark2,
                  //           ),
                  //           SizedBox(width: width * 0.075),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),

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
                              child: AutoSizeText(
                                'BRAND',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.0775,
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                            Icon(
                              FeatherIcons.award,
                              size: width * 0.1,
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
