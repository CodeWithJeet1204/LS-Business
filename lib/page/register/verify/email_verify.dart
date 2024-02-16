import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/firebase/auth_methods.dart';
import 'package:find_easy/page/register/user_register_details.dart';
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

  @override
  void initState() {
    sendEmailVerification();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // SEND EMAIL VERIFICATION
  void sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

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
              "An email has been sent to your account, pls click on it\nTo verify your account\n\nClick on the button after verifying the email\n\n(It may take some time for email to arrive)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryDark,
                fontSize: MediaQuery.of(context).size.width * 0.045,
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: "I have verified my email",
              onTap: () async {
                setState(() {
                  checkingEmailVerified = true;
                });
                await auth.user.reload();
                if (_auth.currentUser!.emailVerified) {
                  setState(() {
                    checkingEmailVerified = false;
                  });
                  await store
                      .collection('Business')
                      .doc('Data')
                      .collection('Users')
                      .doc(_auth.currentUser!.uid)
                      .update({
                    'emailVerified': true,
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: ((context) => const UserRegisterDetailsPage()),
                      ),
                    );
                  }
                } else {
                  setState(() {
                    checkingEmailVerified = false;
                  });
                  if (context.mounted) {
                    mySnackBar(context, "Email not verified");
                  }
                }
              },
              isLoading: checkingEmailVerified,
              horizontalPadding: MediaQuery.of(context).size.width * 0.066,
            ),
          ],
        ),
      ),
    );
  }
}
