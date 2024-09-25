import 'package:flutter/material.dart';
import 'package:ls_business/vendors/utils/colors.dart';

void mySnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(
          color: primaryDark,
        ),
      ),
      elevation: 2,
      backgroundColor: const Color.fromARGB(255, 240, 252, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      dismissDirection: DismissDirection.down,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
