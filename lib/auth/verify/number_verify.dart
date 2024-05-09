import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/events/events_main_page.dart';
import 'package:find_easy/events/register/events_register_details_page_1.dart';
import 'package:find_easy/services/main/services_main_page.dart';
import 'package:find_easy/services/register/services_register_details_page.dart';
import 'package:find_easy/vendors/page/main/main_page.dart';
import 'package:find_easy/vendors/register/user_register_details.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NumberVerifyPage extends StatefulWidget {
  const NumberVerifyPage({
    super.key,
    required this.verificationId,
    required this.isLogging,
    required this.phoneNumber,
    required this.mode,
  });

  final String mode;
  final String verificationId;
  final String phoneNumber;
  final bool isLogging;

  @override
  State<NumberVerifyPage> createState() => _NumberVerifyPageState();
}

class _NumberVerifyPageState extends State<NumberVerifyPage> {
  final TextEditingController otpController = TextEditingController();
  bool isOTPVerifying = false;

  // DISPOSE
  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(child: Container()),
              Text(
                overflow: TextOverflow.ellipsis,
                "An OTP has been sent to your Phone Number\nPls enter the OTP below",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryDark,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                ),
              ),
              const SizedBox(height: 10),
              MyTextFormField(
                hintText: "OTP - 6 Digits",
                controller: otpController,
                borderRadius: 12,
                horizontalPadding: MediaQuery.of(context).size.width * 0.066,
                keyboardType: TextInputType.number,
                autoFillHints: const [AutofillHints.oneTimeCode],
              ),
              const SizedBox(height: 20),
              isOTPVerifying
                  ? Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.055,
                        vertical: 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: buttonColor,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: white),
                      ),
                    )
                  : MyButton(
                      text: "Verify",
                      onTap: () async {
                        if (otpController.text.length == 6) {
                          final credential = PhoneAuthProvider.credential(
                            verificationId: widget.verificationId,
                            smsCode: otpController.text,
                          );
                          setState(() {
                            isOTPVerifying = true;
                          });
                          try {
                            await auth.signInWithCredential(credential);

                            if (!widget.isLogging) {
                              if (auth.currentUser != null) {
                                if (widget.mode == 'vendor') {
                                  await FirebaseFirestore.instance
                                      .collection('Business')
                                      .doc('Owners')
                                      .collection('Users')
                                      .doc(auth.currentUser!.uid)
                                      .set({
                                    'Phone Number': widget.phoneNumber,
                                    'Image': null,
                                    'Email': null,
                                    'Name': null,
                                    'uid': null,
                                    'numberVerified': true,
                                  });

                                  await FirebaseFirestore.instance
                                      .collection('Business')
                                      .doc('Owners')
                                      .collection('Shops')
                                      .doc(auth.currentUser!.uid)
                                      .set({
                                    "Name": null,
                                    'Views': null,
                                    'Favorites': null,
                                    "GSTNumber": null,
                                    "Address": null,
                                    "Special Note": null,
                                    "Industry": null,
                                    "Image": null,
                                    "Type": null,
                                    'MembershipName': null,
                                    'MembershipDuration': null,
                                    'MembershipTime': null,
                                  });
                                }
                              }
                            }
                            setState(() {
                              isOTPVerifying = false;
                            });
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: ((context) {
                                  if (widget.mode == 'vendor') {
                                    if (widget.isLogging) {
                                      return const MainPage();
                                    } else {
                                      return const UserRegisterDetailsPage();
                                    }
                                  } else if (widget.mode == 'services') {
                                    if (widget.isLogging) {
                                      return ServicesMainPage();
                                    } else {
                                      return const ServicesRegisterDetailsPage();
                                    }
                                  } else if (widget.mode == 'events') {
                                    if (widget.isLogging) {
                                      return EventsMainPage();
                                    } else {
                                      return const EventsRegisterDetailsPage1();
                                    }
                                  }
                                  return const MainPage();
                                })),
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isOTPVerifying = false;
                            });
                            setState(() {
                              if (mounted) {
                                mySnackBar(context, e.toString());
                              }
                            });
                          }
                        } else {
                          mySnackBar(
                            context,
                            "OTP should be 6 characters long",
                          );
                        }
                        return;
                      },
                      isLoading: isOTPVerifying,
                      horizontalPadding:
                          MediaQuery.of(context).size.width * 0.066,
                    ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
