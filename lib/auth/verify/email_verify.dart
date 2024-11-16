import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/page/register/owner_register_details_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class EmailVerifyPage extends StatefulWidget {
  const EmailVerifyPage({
    super.key,
    // required this.mode,
    required this.fromMainPage,
  });

  // final String mode;
  final bool fromMainPage;

  @override
  State<EmailVerifyPage> createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final changeEmailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Timer? timer;
  bool isEmailVerified = false;
  bool isEmailChanging = false;
  bool canResendEmail = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    super.initState();
    sendEmailVerification();
    isEmailVerified = auth.currentUser!.emailVerified;

    if (!isEmailVerified) {
      timer = Timer.periodic(const Duration(seconds: 2), (_) async {
        await checkEmailVerification(false);
      });
    }
  }

  // DISPOSE
  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  // CHECK EMAIL VERIFICATION
  Future<void> checkEmailVerification(bool fromButton) async {
    await auth.currentUser!.reload();

    isEmailVerified = auth.currentUser!.emailVerified;

    if (isEmailVerified) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
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
          }),
          (route) => false,
        );
      }
    } else {
      if (fromButton) {
        if (mounted) {
          return mySnackBar(context, 'Not Verified');
        }
      }
    }
  }

  // SEND EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      final user = auth.currentUser!;
      await user.sendEmailVerification();
      if (mounted) {
        mySnackBar(context, 'Verification Email Sent');
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

  // CHANGE EMAIL
  Future<void> changeEmail(double width) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Change Email'),
            content: Container(
              width: width * 0.9,
              height: width * 0.55,
              alignment: Alignment.center,
              child: Form(
                key: changeEmailKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyTextFormField(
                      hintText: 'Email',
                      controller: emailController,
                      borderRadius: 12,
                    ),
                    SizedBox(height: 12),
                    MyTextFormField(
                      hintText: 'Password',
                      controller: passwordController,
                      borderRadius: 12,
                    ),
                    SizedBox(height: 12),
                    MyButton(
                      text: 'DONE',
                      onTap: () async {
                        if (changeEmailKey.currentState!.validate()) {
                          setState(() {
                            isEmailChanging = true;
                            isDialog = true;
                          });

                          final userExistsSnap = await store
                              .collection('Users')
                              .where(
                                'Email',
                                isEqualTo:
                                    emailController.text.toString().trim(),
                              )
                              .where('Registration', isEqualTo: 'email')
                              .get();

                          if (userExistsSnap.docs.isNotEmpty) {
                            if (mounted) {
                              setState(() {
                                isEmailChanging = false;
                                isDialog = false;
                              });
                              return mySnackBar(
                                context,
                                'This account was created in User app, use a different Email here',
                              );
                            }
                          }

                          final vendorExistsSnap = await store
                              .collection('Business')
                              .doc('Owners')
                              .collection('Users')
                              .where(
                                'Email',
                                isEqualTo:
                                    emailController.text.toString().trim(),
                              )
                              .where('Registration', isEqualTo: 'email')
                              .get();

                          if (vendorExistsSnap.docs.isNotEmpty) {
                            if (mounted) {
                              await auth.signInWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                              setState(() {
                                isEmailChanging = false;
                                isDialog = false;
                              });

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const MainPage(),
                                ),
                                (route) => false,
                              );

                              return mySnackBar(
                                context,
                                'Signed In',
                              );
                            }
                          }

                          await auth.signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          await sendEmailVerification();

                          setState(() {
                            isEmailChanging = false;
                            isDialog = false;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
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
                    fontSize: MediaQuery.sizeOf(context).width * 0.05,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await changeEmail(width);
                  },
                  child: Text(
                    'Change Email',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: width * 0.025,
                      color: primaryDark,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'An email has been sent to your account, pls click on it\nTo verify your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryDark,
                    fontSize: MediaQuery.sizeOf(context).width * 0.045,
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'I have Verified my Email',
                  onTap: () async {
                    await checkEmailVerification(true);
                  },
                  horizontalPadding: MediaQuery.sizeOf(context).width * 0.066,
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: canResendEmail ? 1 : 0.5,
                  child: MyButton(
                    text: 'Resend Email',
                    onTap: canResendEmail
                        ? () async {
                            await sendEmailVerification();
                          }
                        : () {
                            return mySnackBar(context, 'Wait for 5 seconds');
                          },
                    horizontalPadding: MediaQuery.sizeOf(context).width * 0.066,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
