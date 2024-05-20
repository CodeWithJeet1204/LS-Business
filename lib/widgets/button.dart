import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/vendors/utils/size.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.isLoading,
    this.width = double.infinity,
    required this.horizontalPadding,
    this.verticalPadding = 0,
  });

  final String text;
  final bool isLoading;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width < screenSize
              ? MediaQuery.of(context).size.width * 0.033
              : MediaQuery.of(context).size.width * 0.0066,
        ),
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: buttonColor,
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: white,
                ),
              )
            : Text(
                overflow: TextOverflow.ellipsis,
                text,
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
