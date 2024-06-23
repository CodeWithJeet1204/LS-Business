import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/add/bulk_add/add_bulk_product_page.dart';
import 'package:localy/vendors/page/main/add/post/add_post_page.dart';
import 'package:localy/vendors/page/main/add/product/add_product_page_1.dart';
import 'package:localy/vendors/page/main/add/shorts/add_shorts_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:localy/widgets/add_box.dart';

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
                  // POST
                  addBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.upload,
                    label: 'POST',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddPostPage(),
                        ),
                      );
                    },
                  ),

                  // SHORTS
                  addBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.video,
                    label: 'SHORTS',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddShortsPage(),
                        ),
                      );
                    },
                  ),

                  // SINGLE PRODUCTS
                  addBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.box,
                    label: 'PRODUCTS',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddProductPage1(),
                        ),
                      );
                    },
                  ),

                  // BULK PRODUCTS
                  addBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.box,
                    label: 'BULK ADD',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddBulkProduct(),
                        ),
                      );
                    },
                  ),

                  // BRAND
                  addBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.award,
                    label: 'BRAND',
                    onTap: () {
                      Navigator.of(context).pushNamed('/addBrand');
                    },
                  ),

                  // CATEGORY
                  // addBox(
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
