import 'package:ls_business/vendors/provider/main_page_provider.dart';
import 'package:ls_business/vendors/page/register/membership_page.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/discount/brand/brand_discount_page.dart';
import 'package:ls_business/vendors/page/main/discount/category/category_discount_page.dart';
import 'package:ls_business/vendors/page/main/discount/products/product_discount_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/add_box.dart';
import 'package:provider/provider.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class AddDiscountPage extends StatefulWidget {
  const AddDiscountPage({super.key});

  @override
  State<AddDiscountPage> createState() => _AddDiscountPageState();
}

class _AddDiscountPageState extends State<AddDiscountPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool? isRegistration;

  // INIT STATE
  @override
  void initState() {
    getVendorData();
    super.initState();
  }

  // GET VENDOR DATA
  Future<void> getVendorData() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final membershipName = vendorData['MembershipName'];

    setState(() {
      if (membershipName == 'Registration') {
        isRegistration = true;
      } else {
        isRegistration = false;
      }
    });
  }

  // SHOW CHANGE MEMBERSHIP DIALOG
  Future<void> showChangeMembershipDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Membership'),
          content: const Text(
            'It will cancel this membership, and you have to get a new Membership by paying',
          ),
          actions: [
            MyTextButton(
              onTap: () {
                Navigator.of(context).pop();
              },
              text: 'NO',
              textColor: primaryDark2,
            ),
            MyTextButton(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SelectMembershipPage(
                        // hasAvailedLaunchOffer: true,
                        ),
                  ),
                );
              },
              text: 'YES',
              textColor: primaryDark2,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainPageProvider = Provider.of<MainPageProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        mainPageProvider.goToHomePage();
      },
      child: isRegistration == null
          ? const Center(
              child: LoadingIndicator(),
            )
          : isRegistration!
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'You are currently using \'FREE Registration\' Membership\nThis membership allows you to register your shop details & catalogue only\nThis does not allows you to add discounts\nGet a paid membership to get benefits',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    MyTextButton(
                      onTap: () async {
                        await showChangeMembershipDialog();
                      },
                      text: 'CHANGE MEMBERSHIP',
                      textColor: Colors.red,
                    ),
                  ],
                )
              : Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: primary,
                  appBar: AppBar(
                    title: const Text('DISCOUNTS'),
                    actions: [
                      IconButton(
                        onPressed: () async {
                          await showYouTubePlayerDialog(
                            context,
                            'add_discount_page',
                          );
                        },
                        icon: const Icon(
                          Icons.question_mark_outlined,
                        ),
                        tooltip: 'Help',
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // PRODUCT
                            AddBox(
                              context: context,
                              width: width,
                              icon: FeatherIcons.box,
                              label: 'PRODUCT',
                              page: const ProductDiscountPage(),
                            ),

                            // BRAND
                            AddBox(
                              context: context,
                              width: width,
                              icon: FeatherIcons.award,
                              label: 'BRAND',
                              page: const BrandDiscountPage(),
                            ),

                            // CATEGORY
                            AddBox(
                              context: context,
                              width: width,
                              icon: FeatherIcons.box,
                              label: 'CATEGORY',
                              page: const CategoryDiscountPage(),
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
