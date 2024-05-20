import 'package:localy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class SmallTextContainer extends StatelessWidget {
  const SmallTextContainer({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
  });

  final String text;
  final void Function()? onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        splashColor: primary2,
        child: Container(
          width: width,
          height: width * 0.125,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: primary2.withOpacity(0.125),
            border: Border.all(
              width: 0.125,
              color: primaryDark,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryDark,
                fontWeight: FontWeight.w500,
                fontSize: width * 0.05,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
