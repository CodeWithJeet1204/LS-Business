import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

void mySnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(
          color: primaryDark,
        ),
      ),
      backgroundColor: primary,
      dismissDirection: DismissDirection.down,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
