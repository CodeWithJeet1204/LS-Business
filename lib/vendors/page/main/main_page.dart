import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/vendors/page/main/add/add_page.dart';
import 'package:find_easy/vendors/page/main/analytics/analytics_page.dart';
import 'package:find_easy/vendors/page/main/comments/all_comments_screen.dart';
import 'package:find_easy/vendors/page/main/discount/add_discount_page.dart';
import 'package:find_easy/vendors/page/main/profile/details/business_details_page.dart';
import 'package:find_easy/vendors/page/main/profile/profile_page.dart';
import 'package:find_easy/vendors/page/register/login_page.dart';
import 'package:find_easy/vendors/page/register/membership_page.dart';
import 'package:find_easy/vendors/page/register/select_business_category.dart';
import 'package:find_easy/vendors/page/register/user_register_details.dart';
import 'package:find_easy/vendors/page/register/verify/email_verify.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/vendors/utils/is_payed.dart';
import 'package:find_easy/widgets/snack_bar.dart';
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
  int current = 4;

  List<Widget> allPages = [
    const AnalyticsPage(),
    const AllCommentPage(),
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
    final DocumentSnapshot<Map<String, dynamic>?>? getUserDetailsAddedDatas =
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .get();

    final Map<String, dynamic>? getUserDetailsAddedData =
        getUserDetailsAddedDatas?.data();

    final DocumentSnapshot<Map<String, dynamic>?>? getBusinessDetailsAdded =
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

    //   print(getCommonCategoriesDetailsAdded);

    //   print(getCommonCategoriesDetailsAdded.data());

    //   if (getCommonCategoriesDetailsAdded.data()!.isNotEmpty) {
    //     return false;
    //   } else {
    //     return true;
    //   }
    // }

    if (getUserDetailsAddedDatas != null) {
      if (getUserDetailsAddedDatas.exists) {
        if (!(await isPayed())) {
          detailsPage = const LoginPage(
            mode: 'vendor',
          );
        } else {
          if (getUserDetailsAddedData!['Email'] == null ||
              getUserDetailsAddedData['Phone Number'] == null) {
            detailsPage = const UserRegisterDetailsPage();
          } else if ((getUserDetailsAddedData['Phone Number'] != null &&
              getUserDetailsAddedData['numberVerified'] != true)) {
            if (!auth.currentUser!.emailVerified) {
              detailsPage = const EmailVerifyPage(
                mode: 'vendor',
              );
            } else {
              detailsPage = null;
            }
          } else if ((getUserDetailsAddedData['Image'] == null)) {
            detailsPage = const UserRegisterDetailsPage();
          } else if (getUserDetailsAddedData['Image'] != null &&
              getBusinessDetailsAdded!['GSTNumber'] == null) {
            detailsPage = const BusinessDetailsPage();
          } else if (getBusinessDetailsAdded!['GSTNumber'] != null &&
              getBusinessDetailsAdded['Type'] == null) {
            detailsPage = SelectBusinessCategoryPage();
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
            mySnackBar(context, 'Your Membership Has Expired');
            detailsPage = const SelectMembershipPage();
          } else {
            detailsPage = null;
          }
        }
      } else {
        await auth.signOut();
        return mySnackBar(
          context,
          'This account was created in User app, use another account to sign in here',
        );
      }
    } else {
      await auth.signOut();
      return mySnackBar(
        context,
        'This account was created in User app, use another account to sign in here',
      );
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
            items: [
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.barChart,
                ),
                icon: Icon(
                  FeatherIcons.barChart2,
                ),
                label: "Analytics",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.messageSquare,
                ),
                icon: Icon(
                  FeatherIcons.messageCircle,
                ),
                label: "Chats",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.plusSquare,
                ),
                icon: Icon(
                  FeatherIcons.plusCircle,
                ),
                label: "Add",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  FeatherIcons.percent,
                ),
                icon: Icon(
                  Icons.percent_rounded,
                ),
                label: "Discount",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  Icons.person_outline,
                ),
                icon: Icon(
                  FeatherIcons.user,
                ),
                label: "Profile",
              ),
            ],
          ),
          body: allPages[current],
        );
  }
}
