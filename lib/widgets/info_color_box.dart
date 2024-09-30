import 'package:auto_size_text/auto_size_text.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class InfoColorBox extends StatelessWidget {
  const InfoColorBox({
    super.key,
    required this.width,
    required this.property,
    required this.color,
    required this.text,
    required this.isHalf,
  });

  final double width;
  final String text;
  final Color color;
  final bool isHalf;
  final dynamic property;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isHalf ? width * 0.45 : width * 0.9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(width * 0.025),
      margin: EdgeInsets.all(width * 0.0125),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toString().trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primaryDark2,
              fontSize: width * 0.04,
            ),
          ),
          property.runtimeType == int
              ? Text(
                  property > 1000000
                      ? '${(property / 1000).toStringAsFixed(2)}M'
                      : property > 1000
                          ? '${(property / 1000).toStringAsFixed(2)}k'
                          : property.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryDark,
                    fontSize: width * 0.12,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : SizedBox(
                  child: Center(
                    child: AutoSizeText(
                      property.toString().toString().trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryDark,
                        fontSize: width * 0.12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
