import 'package:find_easy/page/main/analytics/products_analytics_page.dart';
import 'package:find_easy/page/main/analytics/shop_analytics_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(
      initialIndex: 1,
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text(overflow: TextOverflow.ellipsis, "ANALYTICS"),
        forceMaterialTransparency: true,
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.width * 0.1),
          child: TabBar(
            indicator: BoxDecoration(
              color: primary2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryDark.withOpacity(0.8),
              ),
            ),
            isScrollable: false,
            indicatorPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.width * 0.0266,
              top: MediaQuery.of(context).size.width * 0.0225,
              left: -MediaQuery.of(context).size.width * 0.045,
              right: -MediaQuery.of(context).size.width * 0.045,
            ),
            automaticIndicatorColorAdjustment: false,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: primaryDark,
            labelStyle: const TextStyle(
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: const TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: primary,
            indicatorColor: primaryDark,
            controller: tabController,
            tabs: const [
              Tab(
                text: "SHOP",
              ),
              Tab(
                text: "PRODUCTS",
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          ShopAnalyticsPage(),
          ProductAnalyticsPage(),
        ],
      ),
    );
  }
}
