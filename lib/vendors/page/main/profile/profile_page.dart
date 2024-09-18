import 'package:Localsearch/vendors/page/main/profile/view%20page/shorts/all_shorts_page.dart';
import 'package:Localsearch/widgets/skeleton_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/profile/data/all_categories_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/small_text_container.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool hasReviewed = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getShopType();
    super.initState();
  }

  // GET SHOP TYPE
  Future<void> getShopType() async {
    final ownersDoc = await store.collection('Business').doc('Owners');

    final vendorSnap =
        await ownersDoc.collection('Shops').doc(auth.currentUser!.uid).get();

    final userSnap =
        await ownersDoc.collection('Users').doc(auth.currentUser!.uid).get();

    final vendorData = vendorSnap.data()!;
    final shopName = vendorData['Name'];
    final imageUrl = vendorData['Image'];
    final shopType = vendorData['Type'];

    final userData = userSnap.data()!;
    final myHasReviewed = userData['hasReviewed'];

    setState(() {
      shopData = {
        'Name': shopName,
        'Image': imageUrl,
        'Type': shopType,
      };
      hasReviewed = myHasReviewed;
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
      builder: ((context) {
        return Dialog(
          elevation: 20,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          'PROFILE',
        ),
        actions: [
          // SIGN OUT
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
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpFN1Tvo80rYwu-eXsDNNzsuPITOdtyRPlYIsIqKaIbw&s',
                          );
                        },
                        child: !isData
                            ? CircleAvatar(
                                radius: width * 0.1195,
                                backgroundColor: primary2,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : CircleAvatar(
                                radius: width * 0.1195,
                                backgroundColor: primary2,
                                backgroundImage: NetworkImage(
                                  shopData['Image'] ??
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpFN1Tvo80rYwu-eXsDNNzsuPITOdtyRPlYIsIqKaIbw&s',
                                ),
                              ),
                      ),
                      SizedBox(
                        height: height * 0.0125,
                      ),
                      // NAME
                      SizedBox(
                        width: width * (!isData ? 0.5 : 0.8),
                        height: width * 0.0875,
                        child: !isData
                            ? SkeletonContainer(
                                width: width * 0.5,
                                height: height * 0.025,
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
                        width: width * (!isData ? 0.25 : 0.8),
                        height: width * 0.0875,
                        child: !isData
                            ? SkeletonContainer(
                                width: width * 0.5,
                                height: height * 0.0175,
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
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/ownerDetails');
                        },
                        splashColor: primary3,
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          width: width * 0.45,
                          padding: EdgeInsets.symmetric(
                            vertical: width * 0.02,
                            horizontal: width * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: primary3,
                            border: Border.all(
                              width: 0.125,
                              color: primaryDark,
                            ),
                            borderRadius: BorderRadius.circular(8),
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
                      // BUSINESS DETAILS
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/businessDetails');
                        },
                        splashColor: primary3,
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          width: width * 0.45,
                          padding: EdgeInsets.symmetric(
                            vertical: width * 0.02,
                            horizontal: width * 0.005,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primary3,
                            border: Border.all(
                              width: 0.125,
                              color: primaryDark,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Business Details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.0425,
                              color: primaryDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.0125,
                  ),

                  Divider(
                    height: height * 0.025,
                  ),

                  SizedBox(
                    height: height * 0.0125,
                  ),

                  // PRODUCTS
                  SmallTextContainer(
                    text: 'PRODUCTS',
                    onPressed: () {
                      Navigator.of(context).pushNamed('/productsPage');
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
                          builder: (context) => AllShortsPage(),
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
                      Navigator.of(context).pushNamed('/brandsPage');
                    },
                    width: width,
                  ),
                  const SizedBox(height: 16),

                  // DISCOUNTS
                  SmallTextContainer(
                    text: 'DISCOUNTS',
                    onPressed: () {
                      Navigator.of(context).pushNamed('/discountsPage');
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
                          builder: ((context) => AllCategoriesPage(
                                shopType: shopData['Type'],
                              )),
                        ),
                      );
                    },
                    width: width,
                  ),

                  hasReviewed ? Container() : SizedBox(height: 6),

                  hasReviewed ? Container() : Divider(),

                  // RATE THIS APP
                  hasReviewed
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(width * 0.0225),
                          child: InkWell(
                            onTap: () async {
                              await store
                                  .collection('Business')
                                  .doc('Owners')
                                  .collection('Users')
                                  .doc(auth.currentUser!.uid)
                                  .update({
                                'hasReviewed': true,
                              });

                              const url =
                                  'https://play.google.com/store/apps/details?id=com.localsearch.package';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              } else {
                                return mySnackBar(
                                  context,
                                  'Some error occured, Try Again Later',
                                );
                              }
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.0225),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
