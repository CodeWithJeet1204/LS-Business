import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/vendors/page/main/add/add_page.dart';
import 'package:localy/vendors/page/main/analytics/analytics_page.dart';
import 'package:localy/vendors/page/main/discount/add_discount_page.dart';
import 'package:localy/vendors/page/main/profile/profile_page.dart';
import 'package:localy/vendors/register/business_register_details.dart';
import 'package:localy/vendors/register/membership_page.dart';
import 'package:localy/vendors/register/select_business_category_page.dart';
import 'package:localy/vendors/register/owner_register_details_page.dart';
import 'package:localy/auth/verify/email_verify.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/vendors/utils/is_payed.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Widget? detailsPage;
  int current = 3;

  List<Widget> allPages = [
    const AnalyticsPage(),
    // const AllCommentPage(),
    const AddPage(),
    const AddDiscountPage(),
    const ProfilePage(),
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
    final DocumentSnapshot<Map<String, dynamic>> getUserDetailsAdded =
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .get();

    final Map<String, dynamic>? getUserDetailsAddedData =
        getUserDetailsAdded.data();

    final DocumentSnapshot<Map<String, dynamic>> getBusinessDetailsAdded =
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .get();

    // Future<bool> getCommonCategories(String type) async {
    //   final getCommonCategoriesDetailsAdded = await store
    //       .collection('Business')
    //       .doc('Data')
    //       .collection('Category')
    //       .doc(type)
    //       .get();

    //   if (getCommonCategoriesDetailsAdded.data()!.isNotEmpty) {
    //     return false;
    //   } else {
    //     return true;
    //   }
    // }

    if (getUserDetailsAdded.exists && getBusinessDetailsAdded.exists) {
      /*if (!(await isPayed())) {
        detailsPage = const LoginPage(
          mode: 'vendor',
        );*/
      // } else {
      if (getUserDetailsAddedData!['Email'] == null ||
          getUserDetailsAddedData['Phone Number'] == null) {
        detailsPage = const UserRegisterDetailsPage();
      } else if (getUserDetailsAddedData['Phone Number'] != null &&
          getUserDetailsAddedData['numberVerified'] != true) {
        if (auth.currentUser!.email != null &&
            !auth.currentUser!.emailVerified) {
          print(123);
          detailsPage = const EmailVerifyPage(
            mode: 'vendor',
            isLogging: true,
          );
        } else {
          if (getUserDetailsAddedData['Image'] == null) {
            detailsPage = const UserRegisterDetailsPage();
          } else if (getUserDetailsAddedData['Image'] != null &&
              getBusinessDetailsAdded['GSTNumber'] == null) {
            detailsPage = const BusinessRegisterDetailsPage();
          } else if (getBusinessDetailsAdded['Name'] == null ||
              getBusinessDetailsAdded['Latitude'] == null ||
              getBusinessDetailsAdded['Description'] == null) {
            detailsPage = const BusinessRegisterDetailsPage();
          } else if (getBusinessDetailsAdded['GSTNumber'] != null &&
              getBusinessDetailsAdded['Type'] == null) {
            detailsPage = const SelectBusinessCategoryPage();
          } /* else if (getBusinessDetailsAdded['Type'] != null &&
        await getCommonCategories(getBusinessDetailsAdded['Type'])) {
      detailsPage = SelectBusinessCategoryPage();
    }*/
          else if (getUserDetailsAddedData['Image'] != null &&
              getBusinessDetailsAdded['GSTNumber'] != null &&
              (getBusinessDetailsAdded['MembershipName'] == null ||
                  getBusinessDetailsAdded['MembershipEndDateTime'] == null)) {
            detailsPage = const SelectMembershipPage();
          } else if (DateTime.now().isAfter(
              (getBusinessDetailsAdded['MembershipEndDateTime'] as Timestamp)
                  .toDate())) {
            if (mounted) {
              mySnackBar(context, 'Your Membership Has Expired');
            }
            detailsPage = const SelectMembershipPage();
          } else {
            detailsPage = null;
          }
        }
      } else if (getUserDetailsAddedData['Image'] == null) {
        detailsPage = const UserRegisterDetailsPage();
      } else if (getUserDetailsAddedData['Image'] != null &&
          getBusinessDetailsAdded['GSTNumber'] == null) {
        detailsPage = const BusinessRegisterDetailsPage();
      } else if (getBusinessDetailsAdded['Name'] == null ||
          getBusinessDetailsAdded['Latitude'] == null ||
          getBusinessDetailsAdded['Description'] == null) {
        detailsPage = const BusinessRegisterDetailsPage();
      } else if (getBusinessDetailsAdded['GSTNumber'] != null &&
          getBusinessDetailsAdded['Type'] == null) {
        detailsPage = const SelectBusinessCategoryPage();
      } /* else if (getBusinessDetailsAdded['Type'] != null &&
        await getCommonCategories(getBusinessDetailsAdded['Type'])) {
      detailsPage = SelectBusinessCategoryPage();
    }*/
      else if (getUserDetailsAddedData['Image'] != null &&
          getBusinessDetailsAdded['GSTNumber'] != null &&
          (getBusinessDetailsAdded['MembershipName'] == null ||
              getBusinessDetailsAdded['MembershipEndDateTime'] == null)) {
        detailsPage = const SelectMembershipPage();
      } else if (DateTime.now().isAfter(
          (getBusinessDetailsAdded['MembershipEndDateTime'] as Timestamp)
              .toDate())) {
        if (mounted) {
          mySnackBar(context, 'Your Membership Has Expired');
        }
        detailsPage = const SelectMembershipPage();
      } else {
        detailsPage = null;
      }
      // }
    } else {
      await auth.signOut();
      if (mounted) {
        return mySnackBar(
          context,
          'This account was created in User app, use another account to sign in here',
        );
      }
    }

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
    return detailsPage ??
        Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            backgroundColor: white,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: primaryDark,
            ),
            useLegacyColorScheme: false,
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: const IconThemeData(
              size: 24,
              color: primaryDark,
            ),
            unselectedIconTheme: IconThemeData(
              size: 24,
              color: black.withOpacity(0.5),
            ),
            currentIndex: current,
            onTap: changePage,
            items: const [
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.barChart,
                ),
                icon: Icon(
                  FeatherIcons.barChart2,
                ),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.plusSquare,
                ),
                icon: Icon(
                  FeatherIcons.plusCircle,
                ),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.percent,
                ),
                icon: Icon(
                  Icons.percent_rounded,
                ),
                label: 'Discount',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  Icons.person_outline,
                ),
                icon: Icon(
                  FeatherIcons.user,
                ),
                label: 'Profile',
              ),
            ],
          ),
          body: allPages[current],
        );
  }
}
