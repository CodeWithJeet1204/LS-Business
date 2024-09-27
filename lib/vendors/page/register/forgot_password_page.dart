import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/register/login_email_after_forget_password.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  bool isForget = false;
  bool isSent = false;
  bool isDialog = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Forgot Password'),
            actions: [
              IconButton(
                onPressed: () async {
                  await showYouTubePlayerDialog(
                    context,
                    getYoutubeVideoId(
                      '',
                    ),
                  );
                },
                icon: const Icon(
                  Icons.question_mark_outlined,
                ),
                tooltip: 'Help',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(width * 0.025),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: width * 0.66),
                    MyTextFormField(
                      hintText: 'Email*',
                      controller: emailController,
                      borderRadius: 12,
                      horizontalPadding: 0,
                      autoFillHints: const [],
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: 'FORGET',
                      onTap: () async {
                        if (emailController.text.contains('@') &&
                            emailController.text.contains('.co')) {
                          setState(() {
                            isForget = true;
                            isDialog = true;
                          });
                          List myEmails = [];
                          final userSnap =
                              await store.collection('Users').get();

                          for (var user in userSnap.docs) {
                            final userData = user.data();

                            final email = userData['Email'];

                            myEmails.add(email);
                          }

                          if (myEmails.contains(emailController.text)) {
                            try {
                              await auth.sendPasswordResetEmail(
                                email: emailController.text,
                              );
                              setState(() {
                                isForget = false;
                                isDialog = false;
                                isSent = true;
                              });
                              if (context.mounted) {
                                mySnackBar(
                                    context, 'Password Reset Email Sent');
                              }
                            } catch (e) {
                              setState(() {
                                isForget = false;
                                isDialog = false;
                              });
                              if (context.mounted) {
                                mySnackBar(context, e.toString());
                              }
                            }
                          } else {
                            setState(() {
                              isForget = false;
                              isDialog = false;
                            });
                            if (context.mounted) {
                              return mySnackBar(
                                context,
                                'This email was not used to create User account\nRegister first',
                              );
                            }
                          }
                        }
                      },
                      horizontalPadding: 0,
                    ),
                    !isSent ? Container() : const SizedBox(height: 12),
                    !isSent
                        ? Container()
                        : const Text(
                            'After resetting password, click below to Login',
                          ),
                    !isSent ? Container() : const SizedBox(height: 12),
                    !isSent
                        ? Container()
                        : MyButton(
                            text: 'LOGIN',
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LoginEmailAfterForgetPassword(
                                    email: emailController.text,
                                  ),
                                ),
                              );
                            },
                            horizontalPadding: 0,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
