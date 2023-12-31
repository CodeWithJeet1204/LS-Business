import 'dart:async';
import 'package:find_easy/page/profile_page.dart';
import 'package:find_easy/page/register/user_register_details.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberVerifyPage extends StatefulWidget {
  const NumberVerifyPage({
    super.key,
    required this.verificationId,
    required this.isLogging,
  });
  final String verificationId;
  final bool isLogging;

  @override
  State<NumberVerifyPage> createState() => _NumberVerifyPageState();
}

class _NumberVerifyPageState extends State<NumberVerifyPage> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(child: Container()),
              Text(
                "An OTP has been sent to your Phone Number\nPls enter the OTP below",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              MyTextFormField(
                hintText: "OTP - 6 Digits",
                controller: otpController,
                borderRadius: 12,
                horizontalPadding: 24,
                keyboardType: TextInputType.number,
                autoFillHints: [AutofillHints.oneTimeCode],
              ),
              SizedBox(height: 20),
              MyButton(
                text: "Verify",
                onTap: () async {
                  if (otpController.text.length == 6) {
                    final credential = await PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpController.text,
                    );
                    try {
                      await _auth.signInWithCredential(credential);
                      Timer(Duration(milliseconds: 0), () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => widget.isLogging
                                ? ProfilePage()
                                : UserRegisterDetailsPage(
                                    emailChosen: false,
                                    numberChosen: true,
                                    googleChosen: false,
                                  )),
                          ),
                        );
                      });
                    } catch (e) {
                      setState(() {
                        mySnackBar(context, e.toString());
                      });
                    }
                  }
                  return;
                },
                isLoading: false,
                horizontalPadding: 24,
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
