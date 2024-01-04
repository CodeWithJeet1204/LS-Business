import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPayPage extends StatefulWidget {
  const RegisterPayPage({super.key});

  @override
  State<RegisterPayPage> createState() => _RegisterPayPageState();
}

class _RegisterPayPageState extends State<RegisterPayPage> {
  bool isPaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(),
            ),
            const HeadText(text: "PAY"),
            Expanded(
              flex: 2,
              child: Container(),
            ),
            const Text(
              "To continue using the app, please pay Rs. 100",
              style: TextStyle(
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            MyButton(
              text: "Pay",
              onTap: () {
                try {
                  setState(() {
                    isPaying = true;
                  });
                  // Paying Methods
                  setState(() {
                    isPaying = false;
                  });
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  Navigator.of(context).popAndPushNamed('/registerCred');
                } catch (e) {
                  setState(() {
                    isPaying = false;
                    if (context.mounted) {
                      if (context.mounted) {
                        mySnackBar(context, e.toString());
                      }
                    }
                  });
                }
              },
              horizontalPadding: 24,
              isLoading: isPaying,
            ),
            Expanded(
              flex: 4,
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                MyTextButton(
                  onPressed: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    Navigator.of(context).popAndPushNamed('/login');
                  },
                  text: "LOGIN",
                  textColor: buttonColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
