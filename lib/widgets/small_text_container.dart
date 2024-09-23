import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class SmallTextContainer extends StatelessWidget {
  const SmallTextContainer({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
  });

  final String text;
  final double width;
  final void Function()? onPressed;

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
            color: white,
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryDark,
                fontSize: width * 0.0475,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
