import 'package:ls_business/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    super.key,
    required this.onTap,
    required this.text,
    this.fontSize = 16,
    this.textColor,
  });

  final String text;
  final double fontSize;
  final Color? textColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text.toString().trim(),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor ?? primaryDark,
        ),
      ),
    );
  }
}
