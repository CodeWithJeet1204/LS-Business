import 'package:find_easy/page/main/add/add_page.dart';
import 'package:find_easy/page/main/comments/all_comments_screen.dart';
import 'package:find_easy/page/main/discount/discount_page.dart';
import 'package:find_easy/page/main/profile/profile_page.dart';
import 'package:find_easy/page/main/profile/view%20page/analytics/analaytics_page.dart';
import 'package:find_easy/utils/colors.dart';
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
  int current = 4;

  List<Widget> allPages = [
    const AnalyticsPage(),
    const AllCommentPage(),
    const AddPage(),
    const DiscountPage(),
    const ProfilePage(),
  ];

  void changePage(value) {
    setState(() {
      current = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primary2,
        selectedLabelStyle: const TextStyle(
          color: primaryDark,
          fontWeight: FontWeight.w600,
        ),
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(
          size: 28,
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
