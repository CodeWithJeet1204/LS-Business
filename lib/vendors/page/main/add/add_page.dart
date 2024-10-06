import 'package:ls_business/vendors/page/main/add/brand/add_brand_page.dart';
import 'package:ls_business/vendors/page/main/add/post/add_status_page.dart';
import 'package:ls_business/vendors/provider/main_page_provider.dart';
import 'package:ls_business/vendors/page/register/membership_page.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/add/product/add_product_page_1.dart';
import 'package:ls_business/vendors/page/main/add/shorts/add_shorts_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/add_box.dart';
import 'package:provider/provider.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isRegistration!
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'You are currently using \'FREE Registration\' Membership\nThis membership allows you to register your shop details & catalogue only\nThis does not allows you to add products/brands/shorts/status\nGet a paid membership to get benefits',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    MyTextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SelectMembershipPage(
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
                    actions: [
                      IconButton(
                        onPressed: () async {
                          await showYouTubePlayerDialog(
                            context,
                            getYoutubeVideoId(
                              '',
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.question_mark_outlined,
                        ),
                        tooltip: 'Help',
                      ),
                    ],
                  ),
                  body: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // PRODUCT
                              AddBox(
                                context: context,
                                width: width,
                                icon: FeatherIcons.box,
                                label: 'PRODUCT',
                                page: const AddProductPage1(),
                              ),

                              // FAST PRODUCT
                              AddBox(
                                context: context,
                                width: width,
                                icon: FeatherIcons.fastForward,
                                label: 'FAST PRODUCT',
                                page: const AddStatusPage(),
                              ),

                              // STATUS
                              AddBox(
                                context: context,
                                width: width,
                                icon: FeatherIcons.upload,
                                label: 'STATUS',
                                page: const AddStatusPage(),
                              ),

                              // SHORTS
                              AddBox(
                                context: context,
                                width: width,
                                icon: FeatherIcons.playCircle,
                                label: 'SHORTS',
                                page: const AddShortsPage(),
                              ),

                              // BRAND
                              AddBox(
                                context: context,
                                width: width,
                                icon: FeatherIcons.award,
                                label: 'BRAND',
                                page: const AddBrandPage(),
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
