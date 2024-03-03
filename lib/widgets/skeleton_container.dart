import 'package:flutter/material.dart';

class SkeletonContainer extends StatelessWidget {
  const SkeletonContainer({
    super.key,
    required this.width,
    required this.height,
    this.isLighter = false,
  });

  final double width;
  final double height;
  final bool isLighter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isLighter ? Colors.grey.shade200 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
