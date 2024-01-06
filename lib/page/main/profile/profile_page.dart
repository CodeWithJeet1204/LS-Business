import 'package:find_easy/page/main/profile/tab_bar_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController scrollController = ScrollController();
  final String name = "Swastik Spares";
  final String type = "Automobiles";
  final String owner = "Mahavir Marlecha";
  bool hideNameOverflow = true;
  bool showbtn = true;

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
    super.initState();
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
      body: SafeArea(
        child: NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            ClipOval(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: primary2,
                                child: Image.network(
                                  'https://yt3.googleusercontent.com/oSx8mAQ3_f9cvlml2wntk2_39M1DYXMDpSzLQOiK4sJOvypCMFjZ1gbiGQs62ZvRNClUN_14Ow=s900-c-k-c0x00ffffff-no-rj',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.05,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                name.length < 16
                                    ? hideNameOverflow
                                        ? GestureDetector(
                                            onTap: textOnTap,
                                            child: Container(
                                              width: width * 0.53,
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
                                          )
                                        : GestureDetector(
                                            onTap: textOnTap,
                                            child: Text(
                                              name.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700,
                                                color: primaryDark.withBlue(5),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                    : Container(
                                        width: width * 0.6,
                                        child: Text(
                                          name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: primaryDark.withBlue(5),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: primary2.withOpacity(1),
                            border: Border.all(
                              color: primary2.withBlue(200),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Owner",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: primaryDark2,
                                    ),
                                  ),
                                  Text(
                                    owner,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: primaryDark.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.call_outlined),
                                tooltip: "Call",
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
                        onTap: () {},
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
                        onTap: () {},
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
