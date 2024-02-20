import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/small_text_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;
  final ScrollController scrollController = ScrollController();
  bool hideNameOverflow = true;
  bool showbtn = true;
  bool isDataLoaded = false;

  // TEXT ON TAP SIZE CHANGE
  void textOnTap() {
    setState(() {
      hideNameOverflow = !hideNameOverflow;
    });
  }

  // SIGN OUT
  void signOut() async {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text('Sign Out?'),
          content: const Text('Are you sure\nYou want to Sign Out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                auth.currentUser!.reload();
              },
              child: const Text(
                'YES',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> shopStream =
        FirebaseFirestore.instance
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text("PROFILE"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.logout,
              color: primaryDark,
            ),
            tooltip: "Log Out",
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: width * 0.00225),
              child: Column(
                children: [
                  // INFO
                  Container(
                    width: width,
                    height: width * 0.5625,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: width * 0.01),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.045,
                      vertical: width * 0.01125,
                    ),
                    color: primary,
                    child: StreamBuilder(
                        stream: shopStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("Something went wrong"),
                            );
                          }

                          if (snapshot.hasData) {
                            final shopData = snapshot.data!;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // IMAGE, NAME & INFO
                                CircleAvatar(
                                  radius: width * 0.1195,
                                  backgroundColor: primary2,
                                  backgroundImage: NetworkImage(
                                    shopData['Image'] ??
                                        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.06,
                                ),
                                SizedBox(
                                  width: width * 0.8,
                                  child: Text(
                                    shopData['Name']?.toUpperCase() ?? 'N/A',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: width * 0.07,
                                      fontWeight: FontWeight.w700,
                                      color: primaryDark.withBlue(5),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.8,
                                  child: Text(
                                    shopData['Type'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: width * 0.0425,
                                      fontWeight: FontWeight.w600,
                                      color: primaryDark.withOpacity(0.85),
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: width * 0.0275),
                              ],
                            );
                          }

                          return Container();
                        }),
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Owner Details",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.05,
                              color: primaryDark,
                              fontWeight: FontWeight.w500,
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Business Details",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.05,
                              color: primaryDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: width * 0.138875,
                  ),

                  // VIEW
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // POSTS
                      SmallTextContainer(
                        text: 'POSTS',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/postsPage');
                        },
                        width: width,
                      ),
                      const SizedBox(height: 16),

                      // CATEGORY
                      SmallTextContainer(
                        text: 'CATEGORIES',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/categoriesPage');
                        },
                        width: width,
                      ),
                      const SizedBox(height: 16),

                      // PRODUCTS
                      SmallTextContainer(
                        text: 'PRODUCTS',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/productsPage');
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

                      // BRAND
                      SmallTextContainer(
                        text: 'BRANDS',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/brandsPage');
                        },
                        width: width,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
