import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({
    super.key,
    required this.text,
    required this.animation,
    required this.textColor,
    required this.backgroundColor,
  });

  final String text;
  final String animation;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Lottie.network(
                animation,
                reverse: false,
                height: 400,
                // width: 300,
              ),
            ),
            const SizedBox(height: 36),
            text != "Lets get started"
                ? Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
