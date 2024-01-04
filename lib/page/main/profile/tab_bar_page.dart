import 'package:find_easy/page/main/profile/categories_page.dart';
import 'package:find_easy/page/main/profile/post_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({
    super.key,
    required this.height,
  });
  final double height;

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
      animationDuration: Duration(milliseconds: 400),
    );
    return Column(
      children: [
        TabBar(
          indicator: BoxDecoration(
            color: primary2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primaryDark.withOpacity(0.8),
            ),
          ),
          indicatorPadding: EdgeInsets.only(
            bottom: 10,
            top: 8,
            left: -16,
            right: -16,
          ),
          automaticIndicatorColorAdjustment: false,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: primaryDark,
          labelStyle: TextStyle(
            letterSpacing: 1,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: primary,
          indicatorColor: primaryDark,
          controller: tabController,
          tabs: [
            Tab(
              text: "POSTS",
            ),
            Tab(
              text: "CATEGORIES",
            ),
          ],
        ),
        SizedBox(
          height: widget.height * 0.93,
          child: TabBarView(
            controller: tabController,
            children: [
              PostsPage(),
              CategoriesPage(),
            ],
          ),
        ),
      ],
    );
  }
}
