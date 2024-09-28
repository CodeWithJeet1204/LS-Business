import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/vendors/utils/size.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width = double.infinity,
    required this.horizontalPadding,
    this.verticalPadding = 0,
  });

  final String text;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: buttonColor,
        ),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width < screenSize
              ? MediaQuery.of(context).size.width * 0.033
              : MediaQuery.of(context).size.width * 0.0066,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        alignment: Alignment.center,
        child: AutoSizeText(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: white,
            fontSize: MediaQuery.of(context).size.width < screenSize
                ? MediaQuery.of(context).size.width * 0.045
                : MediaQuery.of(context).size.width * 0.015,
          ),
        ),
      ),
    );
  }
}
