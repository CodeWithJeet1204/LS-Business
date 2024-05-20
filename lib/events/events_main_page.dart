import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/events/profile/events_profile_page.dart';
import 'package:localy/events/register/events_register_details_page_1.dart';
import 'package:localy/events/register/events_register_details_page_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsMainPage extends StatefulWidget {
  const EventsMainPage({super.key});

  @override
  State<EventsMainPage> createState() => _EventsMainPageState();
}

class _EventsMainPageState extends State<EventsMainPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Widget? detailsPage;
  // int current = 1;

  // List<Widget> pages = [
  //   EventsAddPage(),
  //   EventsProfilePage(),
  // ];

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final eventSnap =
        await store.collection('Organizers').doc(auth.currentUser!.uid).get();

    final eventData = eventSnap.data()!;

    setState(() {
      if (!eventSnap.exists ||
          eventData['Name'] == null ||
          eventData['Type'] == null ||
          eventData['Image'] == null) {
        detailsPage = EventsRegisterDetailsPage1();
      } else if (eventData['Description'] == null) {
        detailsPage = EventsRegisterDetailsPage2();
      } else {
        detailsPage = null;
      }
    });
  }

  // CHANGE PAGE
  // void changePage(int index) {
  //   setState(() {
  //     current = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return detailsPage ?? EventsProfilePage();
    // Scaffold(
    //   body: pages[current],
    //   bottomNavigationBar: BottomNavigationBar(
    //     elevation: 0,
    //     backgroundColor: white,
    //     selectedLabelStyle: const TextStyle(
    //       fontWeight: FontWeight.w500,
    //       color: primaryDark,
    //     ),
    //     useLegacyColorScheme: false,
    //     type: BottomNavigationBarType.fixed,
    //     selectedIconTheme: const IconThemeData(
    //       size: 24,
    //       color: primaryDark,
    //     ),
    //     unselectedIconTheme: IconThemeData(
    //       size: 24,
    //       color: black.withOpacity(0.5),
    //     ),
    //     currentIndex: current,
    //     onTap: changePage,
    //     items: [
    //       BottomNavigationBarItem(
    //         icon: Icon(
    //           FeatherIcons.plusCircle,
    //         ),
    //         label: 'Add',
    //         tooltip: 'ADD',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(
    //           FeatherIcons.user,
    //         ),
    //         label: 'Profile',
    //         tooltip: 'PROFILE',
    //       ),
    //     ],
    //   ),
    // );
  }
}
