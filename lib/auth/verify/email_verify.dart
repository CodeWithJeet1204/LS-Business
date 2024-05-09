import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/events/events_main_page.dart';
import 'package:find_easy/events/register/events_register_details_page_1.dart';
import 'package:find_easy/services/main/services_main_page.dart';
import 'package:find_easy/services/register/services_register_details_page.dart';
import 'package:find_easy/vendors/firebase/auth_methods.dart';
import 'package:find_easy/vendors/page/main/main_page.dart';
import 'package:find_easy/vendors/register/user_register_details.dart';
import 'package:find_easy/vendors/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerifyPage extends StatefulWidget {
  const EmailVerifyPage({
    super.key,
    required this.mode,
    required this.isLogging,
  });

  final String mode;
  final bool isLogging;

  @override
  State<EmailVerifyPage> createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthMethods authMethods = AuthMethods();
  final store = FirebaseFirestore.instance;
  bool isCheckingEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  bool isEmailVerified = false;

  // DISPOSE
  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  // INIT STATE + CHECKING EMAIL VERIFY
  @override
  void initState() {
    super.initState();
    sendEmailVerification();
    isEmailVerified = auth.currentUser!.emailVerified;

    if (!isEmailVerified) {
      timer = Timer.periodic(const Duration(seconds: 2), (_) async {
        await checkEmailVerification();
      });
    }
  }

  // CHECK EMAIL VERIFICATION
  Future<void> checkEmailVerification() async {
    setState(() {
      isCheckingEmailVerified = true;
    });

    await auth.currentUser!.reload();

    isEmailVerified = auth.currentUser!.emailVerified;

    setState(() {
      isCheckingEmailVerified = false;
    });

    if (isEmailVerified) {
      if (mounted) {
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
    }
  }

  // SEND EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      final user = auth.currentUser!;
      await user.sendEmailVerification();
      if (mounted) {
        mySnackBar(context, "Verification Email Sent");
      }

      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              auth.currentUser!.email!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryDark,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "An email has been sent to your account, pls click on it\nTo verify your account\n\nIf you want to resend email click below\n\n(It may take some time for email to arrive)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryDark,
                fontSize: MediaQuery.of(context).size.width * 0.045,
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: "I have Verified my Email",
              onTap: () async {
                await checkEmailVerification();
              },
              isLoading: isCheckingEmailVerified,
              horizontalPadding: MediaQuery.of(context).size.width * 0.066,
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: canResendEmail ? 1 : 0.5,
              child: MyButton(
                text: "Resend Email",
                onTap: canResendEmail
                    ? () async {
                        await sendEmailVerification();
                      }
                    : () {
                        return mySnackBar(context, "Wait for 5 seconds");
                      },
                isLoading: false,
                horizontalPadding: MediaQuery.of(context).size.width * 0.066,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
