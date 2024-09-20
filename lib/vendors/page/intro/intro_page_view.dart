import 'package:Localsearch/vendors/page/main/main_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/page_view.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPageView extends StatefulWidget {
  const IntroPageView({super.key});

  @override
  State<IntroPageView> createState() => _IntroPageViewState();
}

class _IntroPageViewState extends State<IntroPageView> {
  final controller = PageController();
  int currentIndex = 0;
  String nextText = 'NEXT';

  // ON SKIP
  void onSkip() {
    controller.animateToPage(
      2,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  // ON NEXT
  void onNext() {
    if (nextText == 'NEXT') {
      controller.animateToPage(
        currentIndex + 1,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    nextText = 'NEXT';
                  });
                }
                if (value == 3) {
                  setState(() {
                    nextText = 'OK';
                  });
                }
              });
            },
            children: const [
              MyPageView(
                text: 'Why\nLocalsearch ?',
                animation:
                    'https://lottie.host/42f81d17-142d-477a-a114-0e8fd17cf3d1/BtWfHFygeT.json',
                textColor: Color.fromARGB(255, 12, 0, 104),
                backgroundColor: Color.fromARGB(255, 251, 227, 225),
                fontSize: 32,
              ),
              MyPageView(
                text:
                    'Reach new customers in your neighborhood and 27000+ pincodes across India',
                animation:
                    'https://lottie.host/42f81d17-142d-477a-a114-0e8fd17cf3d1/BtWfHFygeT.json',
                textColor: Color.fromARGB(255, 255, 53, 39),
                backgroundColor: Color.fromARGB(255, 251, 227, 225),
              ),
              MyPageView(
                text: 'Track sales, analyze trends,\nunderstand what works',
                animation:
                    'https://lottie.host/45111ab9-1b7f-4f96-bda8-3ff1bda7a995/t750Okdqh3.json',
                textColor: Color.fromARGB(255, 0, 86, 3),
                backgroundColor: Color.fromARGB(255, 210, 255, 211),
                fontSize: 24,
              ),
              MyPageView(
                text: 'BUSINESS ON THE GO!\nLets get Started',
                animation:
                    'https://lottie.host/958e98ec-395e-435b-b0f2-91e22622d2c6/szwj6ORXWP.json',
                textColor: Color.fromARGB(255, 0, 59, 107),
                backgroundColor: Color.fromARGB(255, 219, 239, 255),
                fontSize: 24,
              ),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyTextButton(
                  onPressed: onSkip,
                  text: 'SKIP',
                  textColor: buttonColor,
                ),
                // SmoothPageIndicator(
                //   controller: controller,
                //   count: 4,
                // ),
                TextButton(
                  onPressed: onNext,
                  child: Text(
                    nextText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      color: const Color.fromARGB(255, 0, 33, 91),
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
