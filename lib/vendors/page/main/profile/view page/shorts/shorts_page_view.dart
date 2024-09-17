import 'package:Localsearch/vendors/page/main/profile/view%20page/shorts/shorts_tile.dart';
import 'package:flutter/material.dart';

class ShortsPageView extends StatefulWidget {
  const ShortsPageView({
    super.key,
    required this.shorts,
    required this.shortsId,
  });

  final Map<String, dynamic> shorts;
  final String shortsId;

  @override
  State<ShortsPageView> createState() => _ShortsPageViewState();
}

class _ShortsPageViewState extends State<ShortsPageView> {
  late int snappedPageIndex;

  // INIT STATE
  @override
  void initState() {
    setState(() {
      snappedPageIndex = widget.shorts.keys.toList().indexOf(widget.shortsId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView.builder(
        controller: PageController(
          initialPage: 0,
          viewportFraction: 1,
        ),
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        onPageChanged: (pageIndex) {
          setState(() {
            snappedPageIndex = pageIndex;
          });
        },
        itemCount: widget.shorts.length,
        itemBuilder: ((context, index) {
          final String currentKey = widget.shorts.keys.toList()[index];
          final List<dynamic> currentValue =
              widget.shorts.values.toList()[index];
          final Map<String, dynamic> currentShort = {
            currentKey: currentValue,
          };

          return ShortsTile(
            data: currentShort,
            snappedPageIndex: index,
            currentIndex: snappedPageIndex,
          );
        }),
      ),
    );
  }
}
