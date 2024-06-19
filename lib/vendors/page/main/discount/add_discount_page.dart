import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/discount/brand/brand_discount_page.dart';
import 'package:localy/vendors/page/main/discount/products/product_discount_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:localy/widgets/add_box.dart';

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
                  addBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.box,
                    label: 'PRODUCTS',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProductDiscountPage(),
                        ),
                      );
                    },
                  ),

                  // BRAND
                  addBox(
                    context: context,
                    width: width,
                    icon: FeatherIcons.box,
                    label: 'BRAND',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BrandDiscountPage(),
                        ),
                      );
                    },
                  ),

                  // CATEGORY
                  // addBox(
                  //   context: context,
                  //   width: width,
                  //   icon: FeatherIcons.box,
                  //   label: 'CATEGORY',
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) => const CategoryDiscountPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
