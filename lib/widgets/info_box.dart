import 'package:ls_business/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.text,
    required this.value,
  });

  final String text;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).width * 0.0135,
        horizontal: MediaQuery.sizeOf(context).width * 0.0025,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text.toString().trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryDark2,
                    fontSize: MediaQuery.sizeOf(context).width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value.toString().trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryDark,
                    fontSize: MediaQuery.sizeOf(context).width * 0.0666,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
