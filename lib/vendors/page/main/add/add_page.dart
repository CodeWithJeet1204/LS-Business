import 'package:Localsearch/vendors/page/main/add/post/add_status_page.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/add/product/add_product_page_1.dart';
import 'package:Localsearch/vendors/page/main/add/shorts/add_shorts_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/widgets/add_box.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          'ADD',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                  // SINGLE PRODUCT
                  AddBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.box,
                    label: 'PRODUCT',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddProductPage1(),
                        ),
                      );
                    },
                  ),

                  // STATUS
                  AddBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.upload,
                    label: 'STATUS',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddStatusPage(),
                        ),
                      );
                    },
                  ),

                  // SHORTS
                  AddBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.playCircle,
                    label: 'SHORTS',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddShortsPage(),
                        ),
                      );
                    },
                  ),

                  // BRAND
                  AddBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.award,
                    label: 'BRAND',
                    onTap: () {
                      Navigator.of(context).pushNamed('/addBrand');
                    },
                  ),

                  // BULK PRODUCTS
                  // AddBox(
                  //   context: context,
                  //   width: width,
                  //   icon: FeatherIcons.box,
                  //   label: 'BULK ADD',
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) => const AddBulkProduct(),
                  //       ),
                  //     );
                  //   },
                  // ),

                  // CATEGORY
                  // AddBox(
                  //   context: context,
                  //   width: width,
                  //   icon: FeatherIcons.award,
                  //   label: 'CATEGORY',
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //      MaterialPageRoute(
                  //        builder: (context) => const AddCategoryPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
