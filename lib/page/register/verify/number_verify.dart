import 'package:find_easy/page/main/profile_page.dart';
import 'package:find_easy/page/register/firestore_info.dart';
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
    final FirebaseAuth auth = FirebaseAuth.instance;
    bool isOTPVerifying = false;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(child: Container()),
              const Text(
                "An OTP has been sent to your Phone Number\nPls enter the OTP below",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              MyTextFormField(
                hintText: "OTP - 6 Digits",
                controller: otpController,
                borderRadius: 12,
                horizontalPadding: 24,
                keyboardType: TextInputType.number,
                autoFillHints: const [AutofillHints.oneTimeCode],
              ),
              const SizedBox(height: 20),
              MyButton(
                text: "Verify",
                onTap: () async {
                  if (otpController.text.length == 6) {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpController.text,
                    );
                    try {
                      setState(() {
                        isOTPVerifying = true;
                      });
                      await auth.signInWithCredential(credential);
                      userFirestoreData.addAll({
                        'Phone Number': auth.currentUser!.phoneNumber,
                      });
                      setState(() {
                        isOTPVerifying = false;
                      });
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => widget.isLogging
                                ? const ProfilePage()
                                : const UserRegisterDetailsPage(
                                    emailChosen: false,
                                    numberChosen: true,
                                    googleChosen: false,
                                  )),
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isOTPVerifying = false;
                      });
                      setState(() {
                        if (context.mounted) {
                          mySnackBar(context, e.toString());
                        }
                      });
                    }
                  } else {
                    mySnackBar(context, "OTP should be 6 characters long");
                  }
                  return;
                },
                isLoading: isOTPVerifying,
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
