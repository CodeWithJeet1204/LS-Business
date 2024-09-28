import 'package:ls_business/vendors/page/main/profile/data/all_brand_page.dart';
import 'package:ls_business/vendors/page/main/profile/data/all_discounts_page.dart';
import 'package:ls_business/vendors/page/main/profile/data/all_product_page.dart';
import 'package:ls_business/vendors/page/main/profile/details/business_details_page.dart';
import 'package:ls_business/vendors/page/main/profile/details/owner_details_page.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/shorts/all_shorts_page.dart';
import 'package:ls_business/widgets/skeleton_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/profile/data/all_categories_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/small_text_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/video_tutorial.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool hideNameOverflow = true;
  bool showbtn = true;
  Map shopData = {};
  // bool hasReviewed = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getShopType();
    super.initState();
  }

  // GET SHOP TYPE
  Future<void> getShopType() async {
    final ownersDoc = store.collection('Business').doc('Owners');

    final vendorSnap =
        await ownersDoc.collection('Shops').doc(auth.currentUser!.uid).get();

    // final userSnap =
    //     await ownersDoc.collection('Users').doc(auth.currentUser!.uid).get();

    final vendorData = vendorSnap.data()!;
    final shopName = vendorData['Name'];
    final imageUrl = vendorData['Image'];
    final shopType = vendorData['Type'];

    // final userData = userSnap.data()!;
    // final myHasReviewed = userData['hasReviewed'];

    setState(() {
      shopData = {
        'Name': shopName,
        'Image': imageUrl,
        'Type': shopType,
      };
      // hasReviewed = myHasReviewed;
      isData = true;
    });
  }

  // GET SHOP TYPES
  String getShopTypes(List shopList) {
    String type = '';
    int i = 0;
    int length = shopList.length;
    for (var shopType in shopList) {
      if (i == length - 1) {
        type = type + shopType;
      } else {
        type = '$type$shopType, ';
      }

      i++;
    }

    return type;
  }

  // SHOW IMAGE
  Future<void> showImage(String imageUrl) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 20,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('PROFILE'),
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
          IconButton(
            onPressed: () async {},
            // onPressed: () async {
            //   await store
            //       .collection('Shop Types And Category Data')
            //       .doc('Category Properties')
            //       .set({
            //     'categoryPropertiesData': householdCategoryProperties,
            //   });
            // },
            icon: const Icon(
              FeatherIcons.share2,
            ),
            tooltip: 'Share Your Shop',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width * 0.00225,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: height * 0.0125,
                  ),
                  // IMAGE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await showImage(
                            shopData['Image'] ??
                                'https://img.freepik.com/premium-vector/shop-clipart-cartoon-style-vector-illustration_761413-4813.jpg?semt=ais_hybrid',
                          );
                        },
                        child: !isData
                            ? CircleAvatar(
                                radius: width * 0.1195,
                                backgroundColor: primary2,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : CircleAvatar(
                                radius: width * 0.1195,
                                backgroundColor: primary2,
                                backgroundImage: NetworkImage(
                                  shopData['Image'] ??
                                      'https://img.freepik.com/premium-vector/shop-clipart-cartoon-style-vector-illustration_761413-4813.jpg?semt=ais_hybrid',
                                ),
                              ),
                      ),
                      SizedBox(
                        height: height * 0.0125,
                      ),
                      // NAME
                      SizedBox(
                        width: width * (!isData ? 0.33 : 0.8),
                        child: !isData
                            ? SkeletonContainer(
                                width: width * 0.33,
                                height: height * 0.05,
                              )
                            : Text(
                                shopData['Name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.w500,
                                  color: primaryDark.withBlue(5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      SizedBox(
                        height: height * 0.0125,
                      ),

                      // TYPES
                      SizedBox(
                        width: width * (!isData ? 0.75 : 0.8),
                        child: !isData
                            ? SkeletonContainer(
                                width: width * 0.75,
                                height: height * 0.025,
                              )
                            : Text(
                                getShopTypes(shopData['Type']),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  color: primaryDark.withOpacity(0.85),
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.025,
                  ),

                  // DETAILS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // OWNER DETAILS
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const OwnerDetailsPage(),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary3,
                              border: Border.all(
                                width: 0.125,
                                color: primaryDark,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.02,
                              horizontal: width * 0.005,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.0125,
                            ),
                            child: Text(
                              'Owner Details',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: width * 0.045,
                                color: primaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BusinessDetailsPage(),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary3,
                              border: Border.all(
                                width: 0.125,
                                color: primaryDark,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.02,
                              horizontal: width * 0.005,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.0125,
                            ),
                            child: Text(
                              'Business Details',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: width * 0.045,
                                color: primaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Divider(
                    height: height * 0.05,
                  ),

                  // PRODUCTS
                  SmallTextContainer(
                    text: 'PRODUCTS',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AllProductsPage(),
                        ),
                      );
                    },
                    width: width,
                  ),
                  const SizedBox(height: 16),

                  // SHORTS
                  SmallTextContainer(
                    text: 'SHORTS',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AllShortsPage(),
                        ),
                      );
                    },
                    width: width,
                  ),
                  const SizedBox(height: 16),

                  // BRAND
                  SmallTextContainer(
                    text: 'BRANDS',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AllBrandPage(),
                        ),
                      );
                    },
                    width: width,
                  ),
                  const SizedBox(height: 16),

                  // DISCOUNTS
                  SmallTextContainer(
                    text: 'DISCOUNTS',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AllDiscountPage(),
                        ),
                      );
                    },
                    width: width,
                  ),
                  const SizedBox(height: 16),

                  // CATEGORIES
                  SmallTextContainer(
                    text: 'CATEGORIES',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllCategoriesPage(
                            shopType: shopData['Type'],
                          ),
                        ),
                      );
                    },
                    width: width,
                  ),

                  // hasReviewed ? Container() : const SizedBox(height: 6),

                  // hasReviewed ? Container() : const Divider(),

                  // RATE THIS APP
                  // hasReviewed
                  //     ? Container()
                  //    :
                  Padding(
                    padding: EdgeInsets.all(width * 0.0225),
                    child: InkWell(
                      onTap: () async {
                        // await store
                        //     .collection('Business')
                        //     .doc('Owners')
                        //     .collection('Users')
                        //     .doc(auth.currentUser!.uid)
                        //     .update({
                        //   'hasReviewed': true,
                        // });

                        const url =
                            'https://play.google.com/store/apps/details?id=com.ls_business.package';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          if (context.mounted) {
                            return mySnackBar(
                              context,
                              'Some error occured, Try Again Later',
                            );
                          }
                        }
                      },
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.025),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rate This App',
                              style: TextStyle(
                                fontSize: width * 0.0425,
                                color: primaryDark,
                              ),
                            ),
                            Icon(
                              Icons.star,
                              size: width * 0.075,
                              color: Colors.yellow,
                            ),
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
