import 'package:Localsearch/vendors/page/main/add/brand/add_brand_page.dart';
import 'package:Localsearch/vendors/page/main/add/post/add_status_page.dart';
import 'package:Localsearch/vendors/provider/main_page_provider.dart';
import 'package:Localsearch/vendors/page/register/membership_page.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/add/product/add_product_page_1.dart';
import 'package:Localsearch/vendors/page/main/add/shorts/add_shorts_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/widgets/add_box.dart';
import 'package:provider/provider.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
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

  @override
  Widget build(BuildContext context) {
    final mainPageProvider = Provider.of<MainPageProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        mainPageProvider.goToHomePage();
      },
      child: isRegistration == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isRegistration!
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'You are currently using \'FREE Registration\' Membership\nThis membership allows you to register your shop details & catalogue only\nThis does not allows you to add products/brands/shorts/status\nGet a paid membership to get benefits',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    MyTextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SelectMembershipPage(
                              hasAvailedLaunchOffer: true,
                            ),
                          ),
                        );
                      },
                      text: 'CHANGE',
                    ),
                  ],
                )
              : Scaffold(
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
                                      builder: (context) =>
                                          const AddProductPage1(),
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
                                      builder: (context) =>
                                          const AddStatusPage(),
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
                                      builder: (context) =>
                                          const AddShortsPage(),
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddBrandPage(),
                                    ),
                                  );
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
                ),
    );
  }
}
