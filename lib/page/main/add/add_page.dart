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
  bool isPressed1 = false;
  bool isPressed2 = false;
  bool isPressed3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text("ADD"),
        elevation: 0,
        shadowColor: primary2,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedOverflowBox(
                  size: Size(width, height * 0.266),
                  child: GestureDetector(
                    onTapDown: (details) {
                      setState(() {
                        isPressed1 = true;
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        isPressed1 = false;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: ((context) => const AddPostPage()),
                        ),
                      );
                    },
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
                            const Text(
                              "POST",
                              style: TextStyle(
                                color: primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                            ),
                            Expanded(child: Container()),
                            const Icon(
                              Icons.arrow_circle_up_outlined,
                              size: 60,
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
                    onTapUp: (details) {
                      setState(() {
                        isPressed2 = false;
                      });
                      Navigator.of(context).pushNamed('/addCategory');
                    },
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
                            const Text(
                              "CATEGORY",
                              style: TextStyle(
                                color: primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                            ),
                            Expanded(child: Container()),
                            const Icon(
                              Icons.apps_outlined,
                              size: 60,
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
                    onTapUp: (details) {
                      setState(() {
                        isPressed3 = false;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: ((context) => const AddProductPage1()),
                        ),
                      );
                    },
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
                            const Text(
                              "PRODUCTS",
                              style: TextStyle(
                                color: primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                            ),
                            Expanded(child: Container()),
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 60,
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
            );
          },
        ),
      ),
    );
  }
}
