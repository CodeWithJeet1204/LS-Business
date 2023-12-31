import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/page_view.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPageView extends StatefulWidget {
  const IntroPageView({super.key});

  @override
  State<IntroPageView> createState() => _IntroPageViewState();
}

class _IntroPageViewState extends State<IntroPageView> {
  int currentIndex = 0;
  String nextText = "NEXT";

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    void onSkip() {
      controller.animateToPage(
        2,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }

    void onNext() {
      nextText == "NEXT"
          ? controller.animateToPage(
              currentIndex + 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            )
          : Navigator.of(context).popAndPushNamed('profile');
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView(
            controller: controller,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
                if (value != 2) {
                  setState(() {
                    nextText = "NEXT";
                  });
                }
                if (value == 2) {
                  setState(() {
                    nextText = "DONE";
                  });
                }
              });
            },
            children: [
              MyPageView(
                text: "Reach new customers in your neighborhood",
                animation:
                    'https://lottie.host/42f81d17-142d-477a-a114-0e8fd17cf3d1/BtWfHFygeT.json',
                textColor: const Color.fromARGB(255, 255, 53, 39),
                backgroundColor: Color.fromARGB(255, 251, 227, 225),
              ),
              MyPageView(
                text: "Track sales, analyze trends, understand what works",
                animation:
                    'https://lottie.host/45111ab9-1b7f-4f96-bda8-3ff1bda7a995/t750Okdqh3.json',
                textColor: Colors.green,
                backgroundColor: const Color.fromARGB(255, 210, 255, 211),
              ),
              MyPageView(
                text: "Lets get Started",
                animation:
                    'https://lottie.host/958e98ec-395e-435b-b0f2-91e22622d2c6/szwj6ORXWP.json',
                textColor: Color.fromARGB(255, 0, 140, 255),
                backgroundColor: Color.fromARGB(255, 219, 239, 255),
              ),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyTextButton(
                  onPressed: onSkip,
                  text: "SKIP",
                  textColor: buttonColor,
                ),
                SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                ),
                TextButton(
                  onPressed: onNext,
                  child: Text(
                    nextText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
