import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/tab_bar_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController scrollController = ScrollController();
  Map<String, dynamic> userData = {};
  Map<String, dynamic> businessData = {};
  String name = "";
  String address = "";
  String type = "";
  String owner = "";
  String photoUrl = "";
  String phoneNo = "";
  bool hideNameOverflow = true;
  bool showbtn = true;
  bool isDataLoaded = false;

  void textOnTap() {
    setState(() {
      hideNameOverflow = !hideNameOverflow;
    });
  }

  @override
  void initState() {
    scrollController.addListener(() {
      //scroll listener
      double showoffset = 40;

      if (scrollController.offset > showoffset) {
        setState(() {
          showbtn = true;
          //update state
        });
      } else {
        setState(() {
          showbtn = false;
          //update state
        });
      }
    });
    getData();
    super.initState();
    setState(() {
      isDataLoaded = true;
    });
  }

  getData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnap = await FirebaseFirestore
          .instance
          .collection('Business')
          .doc('Owners')
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      userData = userSnap.data()!;
      DocumentSnapshot<Map<String, dynamic>> businessSnap =
          await FirebaseFirestore.instance
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      businessData = businessSnap.data()!;
      setState(() {
        owner = userData["Name"];
        phoneNo = userData["Phone Number"];
        name = businessData['Name'];
        type = businessData['Type'];
        photoUrl = businessData["Image"];
        address = businessData["Address"];
      });
    } catch (e) {
      mySnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      // floatingActionButton: AnimatedOpacity(
      //   duration: Duration(milliseconds: 500),
      //   opacity: showbtn ? 1.0 : 0.0,
      //   child: FloatingActionButton.small(
      //     onPressed: () {
      //       scrollController.animateTo(
      //         0,
      //         duration: Duration(milliseconds: 500),
      //         curve: Curves.fastOutSlowIn,
      //       );
      //     },
      //     child: Icon(
      //       Icons.arrow_upward,
      //       color: white,
      //     ),
      //     backgroundColor: primaryDark,
      //   ),
      // ),
      // appBar: AppBar(
      //   title: Text("PROFILE"),
      // ),
      body: !isDataLoaded
          ? Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            )
          : SafeArea(
              child: NestedScrollView(
                controller: scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      title: Text("PROFILE"),
                      actions: [
                        IconButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          icon: Icon(Icons.logout),
                        ),
                      ],
                    ),
                  ];
                },
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final double height = constraints.maxHeight;
                    return ListView(
                      children: [
                        Container(
                          height: height * 0.28,
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: const BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  photoUrl != ""
                                      ? ClipOval(
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundColor: primary2,
                                            backgroundImage:
                                                NetworkImage(photoUrl),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    width: width * 0.05,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      name.length > 16
                                          ? hideNameOverflow
                                              ? GestureDetector(
                                                  onTap: textOnTap,
                                                  child: Container(
                                                    width: width * 0.53,
                                                    child: Text(
                                                      name.toUpperCase(),
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
                                              : GestureDetector(
                                                  onTap: textOnTap,
                                                  child: Text(
                                                    name.toUpperCase(),
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
                                                )
                                          : Container(
                                              width: width * 0.6,
                                              child: Text(
                                                name.toUpperCase(),
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
                                      Container(
                                        width: width * 0.33,
                                        child: Text(
                                          type,
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(1),
                                  border: Border.all(
                                    color: primary2.withBlue(200),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          owner,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: primaryDark.withOpacity(0.9),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          address,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: primaryDark2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.call_outlined),
                                      tooltip: "Call - ${phoneNo}",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () async {
                                await Navigator.of(context)
                                    .pushNamed('/ownerDetails');
                                getData();
                                setState(() {});
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: width * 0.4,
                                height: height * 0.05,
                                decoration: BoxDecoration(
                                  color: primary3,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Owner Details",
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                await Navigator.of(context)
                                    .pushNamed('/businessDetails');
                                getData();
                                setState(() {});
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: width * 0.4,
                                height: height * 0.05,
                                decoration: BoxDecoration(
                                  color: primary3,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Business Details",
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TabBarPage(height: height),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
