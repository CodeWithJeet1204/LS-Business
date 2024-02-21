import 'package:find_easy/page/main/main_page.dart';
import 'package:find_easy/page/register/login_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.isLoggedIn,
  });

  final bool isLoggedIn;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration(milliseconds: 1500),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: ((context) =>
                widget.isLoggedIn ? MainPage() : LoginPage()),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              primary,
              primary2,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'files/FInd Easy Transparent.png',
              width: width * 0.5,
            ),
            SizedBox(height: width * 0.25),
            Text(
              'Find Easy',
              style: TextStyle(
                color: primaryDark2,
                fontSize: width * 0.08875,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
    );
  }
}
