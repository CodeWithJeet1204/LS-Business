import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/select_mode_page.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesProfilePage extends StatefulWidget {
  const ServicesProfilePage({super.key});

  @override
  State<ServicesProfilePage> createState() => _ServicesProfilePageState();
}

class _ServicesProfilePageState extends State<ServicesProfilePage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  String? name;
  String? imageUrl;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final serviceSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final myName = serviceData['Name'];
    final myImageUrl = serviceData['Image'];

    setState(() {
      name = myName;
      imageUrl = myImageUrl;
      isData = true;
    });
  }

  // SIGN OUT
  Future<void> signOut() async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            overflow: TextOverflow.ellipsis,
            'Sign Out?',
          ),
          content: const Text(
            overflow: TextOverflow.ellipsis,
            'Are you sure\nYou want to Sign Out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await auth.signOut().then(
                        (value) => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: ((context) => SelectModePage()),
                          ),
                          (route) => false,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } on FirebaseAuthException catch (e) {
                  mySnackBar(context, e.toString());
                }
                await auth.signOut();
                auth.currentUser!.reload();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
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

  // SHOW IMAGE
  Future<void> showImage() async {
    final imageStream = await FirebaseFirestore.instance
        .collection('Services')
        .doc(auth.currentUser!.uid)
        .snapshots();

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) {
        return StreamBuilder(
            stream: imageStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    'Something went wrong',
                  ),
                );
              }

              if (snapshot.hasData) {
                final userData = snapshot.data!;
                return Dialog(
                  elevation: 20,
                  child: InteractiveViewer(
                    child: Image.network(
                      userData['Image'] ??
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                    ),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryDark,
                ),
              );
            });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              await signOut();
            },
            icon: const Icon(
              FeatherIcons.logOut,
              color: primaryDark,
            ),
            tooltip: "Log Out",
          ),
        ],
      ),
      body: !isData
          ? Center(
              child: CircularProgressIndicator(),
            )
          : LayoutBuilder(builder: ((context, constraints) {
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: width,
                        height: width * 0.5625,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: width * 0.01),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.0225,
                          vertical: width * 0.01125,
                        ),
                        color: primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // IMAGE
                            GestureDetector(
                              onTap: () async {
                                await showImage();
                              },
                              child: CircleAvatar(
                                radius: width * 0.1195,
                                backgroundColor: primary2,
                                backgroundImage: NetworkImage(
                                  imageUrl ??
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpFN1Tvo80rYwu-eXsDNNzsuPITOdtyRPlYIsIqKaIbw&s',
                                ),
                              ),
                            ),

                            // NAME
                            SizedBox(
                              width: width * 0.8,
                              child: Text(
                                name ?? 'N/A',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: width * 0.07,
                                  fontWeight: FontWeight.w700,
                                  color: primaryDark.withBlue(5),
                                ),
                              ),
                            ),

                            SizedBox(height: width * 0.0275),

                            // YOUR DETAILS
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: width,
                                height: 50,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.25),
                                  border: Border.all(
                                    width: 0.25,
                                    color: primaryDark2.withOpacity(0.25),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.025,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Your Details',
                                      style: TextStyle(
                                        fontSize: width * 0.05,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(FeatherIcons.settings),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              );
            })),
    );
  }
}
