import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/firebase/auth_methods.dart';
import 'package:find_easy/page/main/main_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerifyPage extends StatefulWidget {
  const EmailVerifyPage({
    super.key,
  });

  @override
  State<EmailVerifyPage> createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  // ignore: no_leading_underscores_for_local_identifiers
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final AuthMethods auth = AuthMethods();
  bool checkingEmailVerified = false;
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
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      timer = Timer.periodic(const Duration(seconds: 2), (_) async {
        await checkEmailVerification();
      });
    }
  }

  // CHECK EMAIL VERIFICATION
  Future<void> checkEmailVerification() async {
    await FirebaseAuth.instance.currentUser!.reload();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (isEmailVerified) {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: ((context) => const MainPage())),
          (route) => false,
        );
      }
    }
  }

  // SEND EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      if (context.mounted) {
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
      if (context.mounted) {
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
              _auth.currentUser!.email!,
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
              isLoading: checkingEmailVerified,
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
                        mySnackBar(context, "Wait for 5 seconds");
                      },
                isLoading: checkingEmailVerified,
                horizontalPadding: MediaQuery.of(context).size.width * 0.066,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
