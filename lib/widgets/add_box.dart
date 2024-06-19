import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:localy/vendors/utils/colors.dart';

Widget addBox({
  required BuildContext context,
  required double width,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromRGBO(227, 242, 253, 1),
          Color.fromRGBO(194, 236, 255, 1),
          Color.fromRGBO(255, 235, 238, 1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: width * 0.15,
            height: width * 0.15,
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: width * 0.1,
              color: primaryDark2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AutoSizeText(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: width * 0.0775,
                fontWeight: FontWeight.w600,
                color: primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.arrow_forward_ios,
            size: width * 0.05,
            color: primaryDark2,
          ),
        ],
      ),
    ),
  );
}
