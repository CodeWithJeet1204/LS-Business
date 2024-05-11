import 'package:auto_size_text/auto_size_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/page/main/add/bulk_add/add_bulk_product_page.dart';
import 'package:find_easy/vendors/page/main/add/post/add_post_page.dart';
import 'package:find_easy/vendors/page/main/add/product/add_product_page_1.dart';
import 'package:find_easy/vendors/page/main/add/shorts/add_shorts_page.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'ADD',
        ),
        elevation: 0,
        shadowColor: primary2,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // POST
                  SizedOverflowBox(
                    size: Size(width, 180),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => const AddPostPage()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: 130,
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
                              child: AutoSizeText(
                                'POST',
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
                              FeatherIcons.upload,
                              size: width * 0.1,
                              color: primaryDark2,
                              weight: 1,
                              fill: 0,
                            ),
                            SizedBox(width: width * 0.075),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SHORTS
                  SizedOverflowBox(
                    size: Size(width, 180),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => const AddShortsPage()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: 130,
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
                                'SHORTS',
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
                              FeatherIcons.video,
                              size: width * 0.1,
                              color: primaryDark2,
                              weight: 1,
                              fill: 0,
                            ),
                            SizedBox(width: width * 0.075),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SINGLE PRODUCTS
                  SizedOverflowBox(
                    size: Size(width, 180),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => const AddProductPage1()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: 130,
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
                              child: AutoSizeText(
                                'PRODUCTS',
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

                  // BULK PRODUCTS
                  SizedOverflowBox(
                    size: Size(width, 180),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => const AddBulkProduct()),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: 130,
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
                              child: AutoSizeText(
                                'BULK ADD',
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
                  //   size: Size(width, 180),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.of(context).pushNamed('/addCategory');
                  //     },
                  //     child: Container(
                  //       margin: const EdgeInsets.symmetric(horizontal: 12),
                  //       width: width,
                  //       height: 130,
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
                  //               'CATEGORY',
                  //               overflow: TextOverflow.ellipsis,
                  //               style: TextStyle(
                  //                 color: primaryDark,
                  //                 fontWeight: FontWeight.w600,
                  //                 fontSize: width * 0.0775,
                  //               ),
                  //             ),
                  //           ),
                  //           Expanded(child: Container()),
                  //           Icon(
                  //             FeatherIcons.layers,
                  //             size: width * 0.1,
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
                    size: Size(width, 160),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/addBrand');
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: width,
                        height: 130,
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
          },
        ),
      ),
    );
  }
}
