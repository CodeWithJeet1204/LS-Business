import 'package:auto_size_text/auto_size_text.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
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
    return Expanded(
      child: Container(
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
              text,
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
                        property.toString(),
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
      ),
    );
  }
}
