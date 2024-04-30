import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/services/main/services_page_2.dart';
import 'package:find_easy/services/main/profile/services_profile_page.dart';
import 'package:find_easy/services/register/services_choose_page_1.dart';
import 'package:find_easy/services/register/services_choose_page_2.dart';
import 'package:find_easy/services/register/services_choose_page_3.dart';
import 'package:find_easy/services/register/services_register_details_page.dart';
import 'package:find_easy/auth/login_page.dart';
import 'package:find_easy/auth/verify/email_verify.dart';
import 'package:find_easy/vendors/utils/is_payed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesMainPage extends StatefulWidget {
  const ServicesMainPage({
    super.key,
  });

  @override
  State<ServicesMainPage> createState() => _ServicesMainPageState();
}

class _ServicesMainPageState extends State<ServicesMainPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Widget? detailsPage;
  int current = 1;

  List<Widget> allPages = [
    const ServicesPage2(),
    const ServicesProfilePage(),
  ];

  // INIT STATE
  @override
  void initState() {
    detailsAdded();
    super.initState();
  }

  // IS PAYED
  Future<bool> isPayed() async {
    final isPayed = await getIsPayed();
    return isPayed;
  }

  // DETAILS ADDED
  Future<void> detailsAdded() async {
    final DocumentSnapshot<Map<String, dynamic>?> getServicesDetailsAddedSnap =
        await store.collection('Services').doc(auth.currentUser!.uid).get();

    final Map<String, dynamic>? getServicesDetailsAddedData =
        getServicesDetailsAddedSnap.data();

    if (getServicesDetailsAddedSnap.exists) {
      if (!(await isPayed())) {
        detailsPage = const LoginPage(
          mode: 'vendor',
        );
      } else {
        setState(() {
          if (getServicesDetailsAddedData!['Email'] == null ||
              getServicesDetailsAddedData['Phone Number'] == null) {
            detailsPage = const ServicesRegisterDetailsPage();
          } else if ((getServicesDetailsAddedData['Phone Number'] != null &&
              getServicesDetailsAddedData['numberVerified'] != true)) {
            if (!auth.currentUser!.emailVerified) {
              detailsPage = const EmailVerifyPage(
                mode: 'vendor',
                isLogging: true,
              );
            } else {
              if (getServicesDetailsAddedData['Image'] == null ||
                  getServicesDetailsAddedData['Name'] == null) {
                detailsPage = const ServicesRegisterDetailsPage();
              } else if (getServicesDetailsAddedData['Place'] == null) {
                detailsPage = const ServicesChoosePage1();
              } else if (getServicesDetailsAddedData['Category'] == null) {
                detailsPage = const ServicesChoosePage2();
              } else if (getServicesDetailsAddedData['SubCategory'] == null) {
                detailsPage = ServicesChoosePage3(
                  place: getServicesDetailsAddedData['Place'],
                  category: getServicesDetailsAddedData['Category'],
                );
              } else {
                detailsPage = null;
              }
            }
          } else if (getServicesDetailsAddedData['Image'] == null ||
              getServicesDetailsAddedData['Name'] == null) {
          } else if (getServicesDetailsAddedData['Place'] == null ||
              getServicesDetailsAddedData['Category'] == null ||
              getServicesDetailsAddedData['SubCategory'] == null) {
            detailsPage = const ServicesChoosePage1();
          } else {
            detailsPage = null;
          }
        });
      }
    } /*else {
        await auth.signOut();
        return mySnackBar(
          context,
          'This account was created in User app, use another account to sign in here',
        );
      }*/
    /*} else {
      await auth.signOut();
      return mySnackBar(
        context,
        'This account was created in User app, use another account to sign in here',
      );
    }*/

    setState(() {});
  }

  // CHANGE PAGE
  void changePage(int index) {
    setState(() {
      current = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return detailsPage ?? ServicesProfilePage();
    // Scaffold(
    //   resizeToAvoidBottomInset: false,
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
    //     items: const [
    //       BottomNavigationBarItem(
    //         activeIcon: Icon(
    //           FeatherIcons.barChart,
    //         ),
    //         icon: Icon(
    //           FeatherIcons.barChart2,
    //         ),
    //         label: "Analytics",
    //       ),
    //       BottomNavigationBarItem(
    //         activeIcon: Icon(
    //           Icons.person_outline,
    //         ),
    //         icon: Icon(
    //           FeatherIcons.user,
    //         ),
    //         label: "Profile",
    //       ),
    //     ],
    //   ),
    //   body: allPages[current],
    // );
  }
}
