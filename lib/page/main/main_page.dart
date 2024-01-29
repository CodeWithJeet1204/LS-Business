import 'package:find_easy/page/main/add/add_page.dart';
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
  int current = 1;
  List<Widget> currentPage = [
    const AddPage(),
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
        selectedIconTheme: const IconThemeData(
          size: 28,
          color: primaryDark2,
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
              Icons.person_outline,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: currentPage[current],
    );
  }
}
