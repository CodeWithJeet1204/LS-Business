import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'No',
              textColor: Colors.green,
            ),
            MyTextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              text: 'Yes',
              textColor: Colors.red,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          return Column(
            children: [
              Container(
                height: height * 0.28,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    shopData['Name'].length > 16
                                        ? GestureDetector(
                                            onTap: textOnTap,
                                            child: SizedBox(
                                              width: width * 0.53,
                                              child: Text(
                                                shopData['Name'].toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      primaryDark.withBlue(5),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: width * 0.6,
                                            child: Text(
                                              shopData['Name'].toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700,
                                                color: primaryDark.withBlue(5),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                    SizedBox(
                                      width: width * 0.33,
                                      child: Text(
                                        shopData['Type'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: primaryDark.withOpacity(0.85),
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
                              height: height * 0.1,
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
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
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
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: primaryDark2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon:
                                                const Icon(Icons.call_outlined),
                                            tooltip:
                                                "Call - ${userData['Phone Number']}",
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
                      width: width * 0.45,
                      height: height * 0.05,
                      decoration: BoxDecoration(
                        color: primary3,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Owner Details",
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
                      alignment: Alignment.center,
                      width: width * 0.45,
                      height: height * 0.05,
                      decoration: BoxDecoration(
                        color: primary3,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Business Details",
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
                      // onTap: () {
                      //   Navigator.of(context)
                      //       .pushNamed('/categoriesPage');
                      // },
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
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
