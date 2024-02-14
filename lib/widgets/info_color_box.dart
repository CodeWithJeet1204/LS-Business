import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class InfoColorBox extends StatelessWidget {
  const InfoColorBox({
    super.key,
    required this.width,
    required this.property,
    required this.color,
  });

  final double width;
  final Color color;
  final int property;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.45,
      height: width * 0.2775,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: width * 0.033,
          top: width * 0.033,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LIKES",
              style: TextStyle(
                color: primaryDark2,
                fontSize: width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              property > 1000
                  ? "${(property / 1000).toStringAsFixed(2)}k"
                  : property.toString(),
              style: TextStyle(
                color: primaryDark,
                fontSize: width * 0.12,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
