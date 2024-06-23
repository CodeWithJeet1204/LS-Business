import 'package:auto_size_text/auto_size_text.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class InfoColorBox extends StatelessWidget {
  const InfoColorBox({
    super.key,
    required this.width,
    required this.property,
    required this.color,
    required this.text,
  });

  final String text;
  final double width;
  final Color color;
  final dynamic property;

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
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryDark2,
                fontSize: width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
            property.runtimeType == int
                ? Text(
                    property > 1000
                        ? '${(property / 1000).toStringAsFixed(2)}k'
                        : property.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryDark,
                      fontSize: width * 0.12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : SizedBox(
                    width: width * 0.4,
                    height: width * 0.155,
                    child: Align(
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        property.toString(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 12,
                        maxFontSize: 80,
                        style: TextStyle(
                          color: primaryDark,
                          fontSize: width * 0.12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
