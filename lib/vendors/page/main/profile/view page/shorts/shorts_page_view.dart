import 'package:Localsearch/vendors/page/main/profile/view%20page/shorts/shorts_tile.dart';
import 'package:flutter/material.dart';

class ShortsPageView extends StatefulWidget {
  const ShortsPageView({
    super.key,
    required this.shorts,
    required this.shortsId,
    required this.index,
  });

  final Map<String, Map<String, dynamic>> shorts;
  final String shortsId;
  final int index;

  @override
  State<ShortsPageView> createState() => _ShortsPageViewState();
}

class _ShortsPageViewState extends State<ShortsPageView> {
  late int snappedPageIndex;

  // INIT STATE
  @override
  void initState() {
    setState(() {
      snappedPageIndex = widget.index;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView.builder(
        controller: PageController(
          initialPage: snappedPageIndex,
          viewportFraction: 1,
        ),
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (pageIndex) {
          setState(() {
            snappedPageIndex = pageIndex;
          });
        },
        itemCount: widget.shorts.length,
        itemBuilder: ((context, index) {
          final Map<String, dynamic> shortsData =
              widget.shorts.values.toList()[index];

          return ShortsTile(
            data: shortsData,
          );
        }),
      ),
    );
  }
}
