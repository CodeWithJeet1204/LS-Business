// import 'package:ls_business/vendors/page/main/profile/data/all_post_page.dart';
// import 'package:ls_business/vendors/utils/colors.dart';
// import 'package:flutter/material.dart';

// class TabBarPage extends StatefulWidget {
//   const TabBarPage({
//     super.key,
//     required this.height,
//   });
//   final double height;

//   @override
//   State<TabBarPage> createState() => _TabBarPageState();
// }

// class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     final TabController tabController = TabController(
//       initialIndex: 0,
//       length: 2,
//       vsync: this,
//       animationDuration: const Duration(milliseconds: 400),
//     );
//     return Column(
//       children: [
//         TabBar(
//           indicator: BoxDecoration(
//             color: primary2,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: primaryDark.withOpacity(0.8),
//             ),
//           ),
//           indicatorPadding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).size.width * 0.0266,
//             top: MediaQuery.of(context).size.width * 0.0225,
//             left: -MediaQuery.of(context).size.width * 0.045,
//             right: -MediaQuery.of(context).size.width * 0.045,
//           ),
//           automaticIndicatorColorAdjustment: false,
//           indicatorWeight: 2,
//           indicatorSize: TabBarIndicatorSize.label,
//           labelColor: primaryDark,
//           labelStyle: const TextStyle(
//             letterSpacing: 1,
//             fontWeight: FontWeight.w800,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             letterSpacing: 0,
//             fontWeight: FontWeight.w500,
//           ),
//           dividerColor: primary,
//           indicatorColor: primaryDark,
//           controller: tabController,
//           tabs: const [
//             Tab(
//               text: 'POSTS',
//             ),
//             Tab(
//               text: 'CATEGORIES',
//             ),
//           ],
//         ),
//         SizedBox(
//           height: widget.height * 0.93,
//           child: TabBarView(
//             controller: tabController,
//             children: const [
//               AllPostsPage(),
//               // AllCategoriesPage(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
