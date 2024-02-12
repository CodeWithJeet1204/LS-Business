import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_easy/page/main/add/post/add_post_page.dart';
import 'package:find_easy/page/main/add/product/add_product_page_1.dart';
import 'package:find_easy/utils/colors.dart';
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
        title: const Text("ADD"),
        elevation: 0,
        shadowColor: primary2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                                child: const AutoSizeText(
                                  "POST",
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
                                child: const AutoSizeText(
                                  "PRODUCTS",
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
                    SizedOverflowBox(
                      size: Size(width, 180),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/addCategory');
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
            },
          ),
        ),
      ),
    );
  }
}
