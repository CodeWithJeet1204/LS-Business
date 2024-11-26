import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/page/register/owner_register_details_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class NumberVerifyPage extends StatefulWidget {
  const NumberVerifyPage({
    super.key,
    this.verificationId,
    required this.phoneNumber,
    // required this.fromMainPage,
    required this.isLogging,
    // required this.mode,
  });

  // final String mode;
  final String? verificationId;
  final String phoneNumber;
  // final bool fromMainPage;
  final bool isLogging;

  @override
  State<NumberVerifyPage> createState() => _NumberVerifyPageState();
}

class _NumberVerifyPageState extends State<NumberVerifyPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final otpController = TextEditingController();
  String? verificationId;
  bool isPhoneRegistering = false;
  bool isOTPVerifying = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    // if (widget.fromMainPage) {
    //   sendVerification();
    // }
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  // SEND VERIFICATION
  // Future<void> sendVerification() async {
  //   final userSnap =
  //       await store.collection('Users').doc(auth.currentUser!.uid).get();
  //   final userData = userSnap.data()!;
  //   final phoneNumber = userData['Phone Number'];
  //   await auth.verifyPhoneNumber(
  //     phoneNumber: phoneNumber,
  //     verificationCompleted: (_) {
  //       setState(() {
  //         isPhoneRegistering = false;
  //         isDialog = false;
  //       });
  //     },
  //     verificationFailed: (e) {
  //       setState(() {
  //         isPhoneRegistering = false;
  //         isDialog = false;
  //       });
  //       if (mounted) {
  //         mySnackBar(
  //           context,
  //           e.toString(),
  //         );
  //       }
  //     },
  //     codeSent: (
  //       String currentVerificationId,
  //       int? token,
  //     ) {
  //       setState(() {
  //         verificationId = currentVerificationId;
  //       });
  //     },
  //     codeAutoRetrievalTimeout: (e) {
  //       setState(() {
  //         isPhoneRegistering = false;
  //       });
  //       if (mounted) {
  //         mySnackBar(
  //           context,
  //           e.toString(),
  //         );
  //       }
  //     },
  //   );
  // }

  // VERIFY
  Future<void> verify() async {
    if (otpController.text.toString().trim().length == 6) {
      setState(() {
        isOTPVerifying = true;
        isDialog = true;
      });

      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId ?? verificationId!,
        smsCode: otpController.text.toString().trim(),
      );

      try {
        await auth.signInWithCredential(credential);

        if (auth.currentUser != null) {
          if (!widget.isLogging) {
            // if (widget.mode == 'vendor') {
            await store
                .collection('Business')
                .doc('Owners')
                .collection('Users')
                .doc(auth.currentUser!.uid)
                .set({
              'Phone Number': widget.phoneNumber,
              'Registration': 'phone number',
              'Image': null,
              'Email': null,
              'Name': null,
              // 'numberVerified': true,
              'allowCalls': true,
              'allowChats': true,
              // 'hasReviewed': false,
            });

            await store
                .collection('Business')
                .doc('Owners')
                .collection('Shops')
                .doc(auth.currentUser!.uid)
                .set({
              'Name': null,
              'Registration': 'phone number',
              'GSTNumber': null,
              'Description': null,
              // 'Industry': null,
              'Image': null,
              'Type': null,
              'MembershipName': null,
              'MembershipDuration': null,
              'MembershipStartDateTime': null,
            });
          }
          // }
        }
        setState(() {
          isOTPVerifying = false;
          isDialog = false;
        });
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
              // if (widget.mode == 'vendor') {
              // if (widget.fromMainPage) {
              //   return const MainPage();
              // } else {
              return widget.isLogging
                  ? const MainPage()
                  : const OwnerRegisterDetailsPage(
                      fromMainPage: false,
                    );
              // }
              // } else if (widget.mode == 'services') {
              //   if (widget.isLogging) {
              //     return const ServicesMainPage();
              //   } else {
              //     return const ServicesRegisterDetailsPage();
              //   }
              // } else if (widget.mode == 'events') {
              //   if (widget.isLogging) {
              //     return const EventsMainPage();
              //   } else {
              //     return const EventsRegisterDetailsPage1();
              //   }
              // }
              // return const MainPage();
            }),
            (route) => false,
          );
          widget.isLogging ? mySnackBar(context, 'Signed In') : null;
        }
      } catch (e) {
        setState(() {
          isOTPVerifying = false;
          isDialog = false;
        });
        setState(() {
          if (mounted) {
            mySnackBar(context, 'Error: ${e.toString()}');
          }
        });
      }
    } else {
      mySnackBar(
        context,
        'OTP should be 6 characters long',
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    'An OTP has been sent to your Phone Number\nPls enter the OTP below',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryDark,
                      fontSize: MediaQuery.sizeOf(context).width * 0.045,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextFormField(
                    hintText: 'OTP - 6 Digits',
                    controller: otpController,
                    borderRadius: 12,
                    horizontalPadding: MediaQuery.sizeOf(context).width * 0.066,
                    keyboardType: TextInputType.number,
                    autoFillHints: const [AutofillHints.oneTimeCode],
                  ),
                  const SizedBox(height: 20),
                  isOTPVerifying
                      ? Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: width * 0.055,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: buttonColor,
                          ),
                          child: const Center(
                            child: LoadingIndicator(),
                          ),
                        )
                      : MyButton(
                          text: 'Verify',
                          onTap: () async {
                            await verify();
                          },
                          horizontalPadding:
                              MediaQuery.sizeOf(context).width * 0.066,
                        ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
