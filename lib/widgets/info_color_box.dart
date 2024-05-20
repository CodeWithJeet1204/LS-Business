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
              overflow: TextOverflow.ellipsis,
              text,
              style: TextStyle(
                color: primaryDark2,
                fontSize: width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
            property.runtimeType == int
                ? Text(
                    overflow: TextOverflow.ellipsis,
                    property > 1000
                        ? '${(property / 1000).toStringAsFixed(2)}k'
                        : property.toString(),
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
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 12,
                        maxFontSize: 80,
                        style: TextStyle(
                          color: primaryDark,
                          fontSize: width * 0.12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
