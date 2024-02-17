import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/add/add_page.dart';
import 'package:find_easy/page/main/analytics/shop_analytics_page.dart';
import 'package:find_easy/page/main/comments/all_comments_screen.dart';
import 'package:find_easy/page/main/discount/add_discount_page.dart';
import 'package:find_easy/page/main/profile/details/business_details_page.dart';
import 'package:find_easy/page/main/profile/profile_page.dart';
import 'package:find_easy/page/register/login_page.dart';
import 'package:find_easy/page/register/membership.dart';
import 'package:find_easy/page/register/register_cred.dart';
import 'package:find_easy/page/register/user_register_details.dart';
import 'package:find_easy/page/register/verify/email_verify.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/utils/is_payed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    this.index,
  });

  final int? index;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Widget? detailsPage;
  int current = 0;

  List<Widget> allPages = [
    const ShopAnalyticsPage(),
    const AllCommentPage(),
    const AddPage(),
    const AddDiscountPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    detailsAdded();
    super.initState();
  }

  Future<bool> isPayed() async {
    final isPayed = await getIsPayed();
    return isPayed;
  }

  void detailsAdded() async {
    final getUserDetailsAdded = await store
        .collection('Business')
        .doc('Owners')
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .get();

    final getBusinessDetailsAdded = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    if (!(await isPayed())) {
      detailsPage = const LoginPage();
    } else {
      if (getUserDetailsAdded['Email'] == null &&
          getUserDetailsAdded['Phone Number'] == null) {
        detailsPage = const RegisterCredPage();
      } else if (getUserDetailsAdded['Email'] != null &&
          !auth.currentUser!.emailVerified) {
        detailsPage = const EmailVerifyPage();
      } else if ((getUserDetailsAdded['Image'] == null)) {
        detailsPage = const UserRegisterDetailsPage();
      } else if (getUserDetailsAdded['Image'] != null &&
          getBusinessDetailsAdded['GSTNumber'] == null) {
        detailsPage = const BusinessDetailsPage();
      } else if (getUserDetailsAdded['Image'] != null &&
          getBusinessDetailsAdded['GSTNumber'] != null &&
          getBusinessDetailsAdded['MembershipName'] == null) {
        detailsPage = const SelectMembershipPage();
      } else {
        // All details added, set detailsPage to null
        detailsPage = null;
      }
    }

    setState(() {
      // Trigger rebuild after setting detailsPage
    });
  }

  void changePage(value) {
    setState(() {
      current = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return detailsPage ??
        Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: primary2,
            selectedLabelStyle: const TextStyle(
              color: primaryDark,
              fontWeight: FontWeight.w600,
            ),
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: IconThemeData(
              size: MediaQuery.of(context).size.width * 0.07785,
              color: primaryDark,
            ),
            currentIndex: current,
            onTap: (value) {
              changePage(value);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  current != 0 ? Icons.bar_chart_rounded : Icons.bar_chart,
                ),
                label: "Analytics",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  current != 1 ? Icons.comment_outlined : Icons.comment,
                ),
                label: "Comments",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  current != 2 ? Icons.add_circle_outline : Icons.add_circle,
                ),
                label: "Add",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  current != 3 ? Icons.percent_rounded : Icons.percent,
                ),
                label: "Discount",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  current != 4 ? Icons.person_outline : Icons.person,
                ),
                label: "Profile",
              ),
            ],
          ),
          body: allPages[current],
        );
  }
}
