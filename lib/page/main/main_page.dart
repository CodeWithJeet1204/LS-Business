import 'package:find_easy/page/main/add/add_page.dart';
import 'package:find_easy/page/main/comments/all_comments_screen.dart';
import 'package:find_easy/page/main/discount/discount_page.dart';
import 'package:find_easy/page/main/profile/profile_page.dart';
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
  int current = 2;
  List<Widget> allPages = [
    const AddPage(),
    const AllCommentPage(),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primary2,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: primaryDark,
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outline,
            ),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.comment_outlined,
            ),
            label: "Comments",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.percent,
            ),
            label: "Discount",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: allPages[current],
    );
  }
}
