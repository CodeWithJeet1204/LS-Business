import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/events/profile/events_details_page.dart';
import 'package:find_easy/select_mode_page.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsProfilePage extends StatefulWidget {
  const EventsProfilePage({super.key});

  @override
  State<EventsProfilePage> createState() => _EventsProfilePageState();
}

class _EventsProfilePageState extends State<EventsProfilePage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  String? name;
  String? imageUrl;
  String duration = '7 Days';
  int views = 0;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    getViews();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final serviceSnap =
        await store.collection('Events').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final myName = serviceData['Name'];
    final myImageUrl = serviceData['Image'];

    setState(() {
      name = myName;
      imageUrl = myImageUrl;
      isData = true;
    });
  }

  // GET VIEWS
  Future<void> getViews() async {
    final serviceSnap =
        await store.collection('Events').doc(auth.currentUser!.uid).get();

    final serviceData = serviceSnap.data()!;

    final List timestamp = serviceData['ViewsTimestamp'];

    DateTime currentDate = DateTime.now();

    DateTime sevenDaysAgo = currentDate.subtract(Duration(days: 7));

    List<dynamic> timestampsWithin7Days = timestamp.where((timestamp) {
      DateTime timestampDateTime = (timestamp as Timestamp).toDate();
      return timestampDateTime.isAfter(sevenDaysAgo);
    }).toList();

    setState(() {
      views = timestampsWithin7Days.length;
    });
  }

  // GET DURATION VIEWS
  Future<void> getDurationViews(String duration) async {
    final serviceSnap = await FirebaseFirestore.instance
        .collection('Services')
        .doc(auth.currentUser!.uid)
        .get();
    final serviceData = serviceSnap.data()!;

    final List<dynamic> timestampList = serviceData['ViewsTimestamp'];

    DateTime currentDate = DateTime.now();

    DateTime startDate;

    switch (duration) {
      case '7 Days':
        startDate = currentDate.subtract(Duration(days: 7));
        break;
      case '28 Days':
        startDate = currentDate.subtract(Duration(days: 28));
        break;
      case '1 Year':
        startDate = currentDate.subtract(Duration(days: 365));
        break;
      case 'Lifetime':
        startDate = DateTime(1970);
        break;
      default:
        startDate = currentDate;
    }

    List<dynamic> timestampsWithinDuration = timestampList.where((timestamp) {
      DateTime timestampDateTime = (timestamp as Timestamp).toDate();
      return timestampDateTime.isAfter(startDate);
    }).toList();

    setState(() {
      views = timestampsWithinDuration.length;
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
                            builder: ((context) => const SelectModePage()),
                          ),
                          (route) => false,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } on FirebaseAuthException catch (e) {
                  if (context.mounted) {
                    mySnackBar(context, e.toString());
                  }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : LayoutBuilder(
              builder: ((context, constraints) {
                final width = constraints.maxWidth;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: width,
                        // height: width * 0.5625,
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
                                await showImage(imageUrl!);
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

                            SizedBox(height: 8),

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

                            SizedBox(height: 8),

                            // YOUR DETAILS
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: ((context) =>
                                        const EventsDetailsPage()),
                                  ),
                                );
                              },
                              child: Container(
                                width: width,
                                height: 60,
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
                                margin: EdgeInsets.all(
                                  width * 0.006125,
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
                                    const Icon(FeatherIcons.settings),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // VIEWS
                            Container(
                              width: width,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.25),
                                border: Border.all(
                                  width: 0.25,
                                  color: primaryDark2.withOpacity(0.25),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(width * 0.025),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Views',
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                        ),
                                      ),
                                      Text(
                                        views.toString(),
                                        style: TextStyle(
                                          fontSize: width * 0.06,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.all(width * 0.0125),
                                    child: DropdownButton(
                                      dropdownColor: primary,
                                      underline: SizedBox(),
                                      hint: Text('Duration'),
                                      value: duration,
                                      items: [
                                        '7 Days',
                                        '28 Days',
                                        '1 Year',
                                        'Lifetime'
                                      ]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            duration = value;
                                          });
                                          getDurationViews(value);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }
}
