import 'package:cloud_firestore/cloud_firestore.dart';
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
          title: Text('Sign Out?'),
          content: Text('Are you sure\nYou want to Sign Out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
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
                Navigator.of(context).pop();
              },
              child: Text(
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
      backgroundColor: primary,
      resizeToAvoidBottomInset: false,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipOval(
                                      child: CircleAvatar(
                                        radius: 40,
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
                                                      fontSize: 24,
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
                                                    fontSize: 24,
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
                                                  ClipOval(
                                                    child: CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor: primary2,
                                                      backgroundImage:
                                                          NetworkImage(
                                                        userData['Image'],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: width * 0.01),
                                                  Text(
                                                    userData['Name'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: primaryDark
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                shopData['Address'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: primaryDark2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Divider(
                                                color: primaryDark2,
                                                thickness: 0,
                                                height: 8,
                                              ),
                                              Text(
                                                shopData['Special Note'],
                                                style: TextStyle(
                                                  color: primaryDark,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: primaryDark,
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            );
                          }

                          return const CircularProgressIndicator(
                            color: primaryDark,
                          );
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
                          horizontal: width * 0.03,
                          vertical: height * 0.01,
                        ),
                        child: const Text(
                          "VIEW",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: const Text(
                                    "POSTS",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: const Icon(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: const Text(
                                    "CATEGORIES",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: const Icon(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: const Text(
                                    "PRODUCTS",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: const Icon(
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
                            Navigator.of(context).pushNamed('/analyticsPage');
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: width,
                            height: 75,
                            decoration: BoxDecoration(
                              color: primary2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: const Text(
                                    "ANALYTICS",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: primaryDark2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: const Icon(
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
            );
          },
        ),
      ),
    );
  }
}
