import 'package:localy/vendors/utils/colors.dart';
import 'package:flutter/material.dart';

class PropertyBox extends StatelessWidget {
  const PropertyBox({
    super.key,
    required this.headText,
    required this.widget1,
    required this.widget2,
  });

  final String headText;
  final Widget widget1;
  final Widget widget2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary3.withOpacity(0.5),
          border: Border.all(
            color: primary3,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                overflow: TextOverflow.ellipsis,
                headText,
                style: const TextStyle(
                  color: primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            widget1,
            const SizedBox(height: 4),
            widget2,
          ],
        ),
      ),
    );
  }
}
