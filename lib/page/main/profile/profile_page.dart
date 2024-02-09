import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/data/all_discounts_page.dart';
import 'package:find_easy/utils/colors.dart';
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

  void textOnTap() {
    setState(() {
      hideNameOverflow = !hideNameOverflow;
    });
  }

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

    Stream<DocumentSnapshot<Map<String, dynamic>>> userStream =
        FirebaseFirestore.instance
            .collection('Business')
            .doc('Owners')
            .collection('Users')
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
          final double height = constraints.maxHeight;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.0028125),
              child: Column(
                children: [
                  Container(
                    width: width,
                    height: height * 0.3625,
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipOval(
                                      child: CircleAvatar(
                                        radius: height * 0.066,
                                        backgroundColor: primary2,
                                        backgroundImage:
                                            NetworkImage(shopData['Image']),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.05,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        shopData['Name'].length > 16
                                            ? GestureDetector(
                                                onTap: textOnTap,
                                                child: SizedBox(
                                                  width: width * 0.53,
                                                  child: Text(
                                                    shopData['Name']
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: height * 0.035,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: primaryDark
                                                          .withBlue(5),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(
                                                width: width * 0.6,
                                                child: Text(
                                                  shopData['Name']
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: height * 0.045,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        primaryDark.withBlue(5),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                        SizedBox(
                                          width: width * 0.33,
                                          child: Text(
                                            shopData['Type'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  primaryDark.withOpacity(0.85),
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.02,
                                ),
                                Container(
                                  width: width,
                                  height: height * 0.185,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary2.withOpacity(1),
                                    border: Border.all(
                                      color: primary2.withBlue(200),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: StreamBuilder(
                                      stream: userStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text("Something went wrong"),
                                          );
                                        }

                                        if (snapshot.hasData) {
                                          final userData = snapshot.data!;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // USER IMAGE
                                                  CircleAvatar(
                                                    radius: height * 0.0175,
                                                    backgroundColor: primary2,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      userData['Image'],
                                                    ),
                                                  ),
                                                  SizedBox(width: width * 0.01),
                                                  // OWNER NAME
                                                  Text(
                                                    userData['Name'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: height * 0.03,
                                                      color: primaryDark
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ],
                                              ),
                                              // ADDRESS
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: height * 0.01,
                                                ),
                                                child: Text(
                                                  shopData['Address'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontSize: height * 0.02,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                color: primaryDark2,
                                                thickness: 0,
                                                height: 8,
                                              ),
                                              // SPECIAL NOTE
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: height * 0.01,
                                                ),
                                                child: Text(
                                                  shopData['Special Note'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: height * 0.02125,
                                                    fontWeight: FontWeight.w600,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        // return const Center(
                                        //   child: CircularProgressIndicator(
                                        //     color: primaryDark,
                                        //   ),
                                        // );
                                        return Container();
                                      }),
                                ),
                              ],
                            );
                          }

                          // return const CircularProgressIndicator(
                          //   color: primaryDark,
                          // );
                          return Container();
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/ownerDetails');
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: width * 0.4,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.01,
                            horizontal: width * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Owner Details",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              color: primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/businessDetails');
                        },
                        child: Container(
                          width: width * 0.4,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.01,
                            horizontal: width * 0.005,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primary3,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Business Details",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              color: primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.025,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/postsPage');
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: width,
                            height: 75,
                            decoration: BoxDecoration(
                              color: primary2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    "POSTS",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.arrow_right_sharp,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.025),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.025,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/categoriesPage');
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: width,
                            height: 75,
                            decoration: BoxDecoration(
                              color: primary2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    "CATEGORIES",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.arrow_right_sharp,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.025),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.025,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/productsPage');
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: width,
                            height: 75,
                            decoration: BoxDecoration(
                              color: primary2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    "PRODUCTS",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.arrow_right_sharp,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.025),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.025,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => AllDiscountPage()),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: width,
                            height: 75,
                            decoration: BoxDecoration(
                              color: primary2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    "DISCOUNTS",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.arrow_right_sharp,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
