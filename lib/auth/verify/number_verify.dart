import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/page/main/main_page.dart';
import 'package:Localsearch/vendors/page/register/owner_register_details_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NumberVerifyPage extends StatefulWidget {
  const NumberVerifyPage({
    super.key,
    required this.phoneNumber,
    required this.fromMainPage,
    this.verificationId,
    // required this.mode,
  });

  // final String mode;
  final String phoneNumber;
  final bool fromMainPage;
  final String? verificationId;

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

  // INIT STATE
  @override
  void initState() {
    if (widget.fromMainPage) {
      sendVerification();
    }
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  // SEND VERIFICATION
  Future<void> sendVerification() async {
    final userSnap =
        await store.collection('Users').doc(auth.currentUser!.uid).get();

    final userData = userSnap.data()!;

    final phoneNumber = userData['Phone Number'];

    await auth.verifyPhoneNumber(
      phoneNumber: '+91 $phoneNumber',
      verificationCompleted: (_) {
        setState(() {
          isPhoneRegistering = false;
        });
      },
      verificationFailed: (e) {
        setState(() {
          isPhoneRegistering = false;
        });
        if (mounted) {
          mySnackBar(
            context,
            e.toString(),
          );
        }
      },
      codeSent: (
        String currentVerificationId,
        int? token,
      ) {
        setState(() {
          verificationId = currentVerificationId;
        });
      },
      codeAutoRetrievalTimeout: (e) {
        setState(() {
          isPhoneRegistering = false;
        });
        if (mounted) {
          mySnackBar(
            context,
            e.toString(),
          );
        }
      },
    );
  }

  // VERIFY
  Future<void> verify() async {
    if (otpController.text.length == 6) {
      setState(() {
        isOTPVerifying = true;
      });

      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId ?? verificationId!,
        smsCode: otpController.text,
      );

      try {
        await auth.signInWithCredential(credential);

        await auth.currentUser?.reload();
        if (auth.currentUser != null) {
          // if (widget.mode == 'vendor') {
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .set({
            'Phone Number': '+91 ${widget.phoneNumber}',
            'registration': 'phone number',
            'Image': null,
            'Email': null,
            'Name': null,
            'numberVerified': true,
            'allowCall': true,
            'allowChat': true,
            'hasReviewed': false,
          });

          await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(auth.currentUser!.uid)
              .set({
            'Name': null,
            'registration': 'phone number',
            'GSTNumber': null,
            'Description': null,
            // 'Industry': null,
            'Image': null,
            'Type': [],
            'MembershipName': null,
            'MembershipDuration': null,
            'MembershipStartDateTime': null,
          });
          // }
        }
        setState(() {
          isOTPVerifying = false;
        });
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: ((context) {
              // if (widget.mode == 'vendor') {
              if (widget.fromMainPage) {
                return const MainPage();
              } else {
                return const OwnerRegisterDetailsPage(
                  fromMainPage: false,
                );
              }
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
        'OTP should be 6 characters long',
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
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
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                ),
              ),
              const SizedBox(height: 10),
              MyTextFormField(
                hintText: 'OTP - 6 Digits',
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
                        child: CircularProgressIndicator(color: white),
                      ),
                    )
                  : MyButton(
                      text: 'Verify',
                      onTap: () async {
                        await showLoadingDialog(
                          context,
                          () async {
                            await verify();
                          },
                        );
                      },
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
