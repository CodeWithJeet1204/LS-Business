import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/vendors/page/register/login_email_after_forget_password.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        actions: [
          IconButton(
            onPressed: () {
              BetterFeedback.of(context).show((feedback) async {
                Future<String> writeImageToStorage(
                    Uint8List feedbackScreenshot) async {
                  final Directory output = await getTemporaryDirectory();
                  final String screenshotFilePath =
                      '${output.path}/feedback.png';
                  final File screenshotFile = File(screenshotFilePath);
                  await screenshotFile.writeAsBytes(feedbackScreenshot);
                  return screenshotFilePath;
                }

                final screenshotFilePath =
                    await writeImageToStorage(feedback.screenshot);

                final Email email = Email(
                  body: feedback.text,
                  subject: 'Localsearch Feedback',
                  recipients: ['infinitylab1204@gmail.com'],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
              });
            },
            icon: const Icon(
              Icons.bug_report_outlined,
            ),
            tooltip: 'Report Problem',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            width * 0.025,
          ),
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
                      await showLoadingDialog(
                        context,
                        () async {
                          setState(() {
                            isForget = true;
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
                                isSent = true;
                              });
                              if (context.mounted) {
                                mySnackBar(
                                    context, 'Password Reset Email Sent');
                              }
                            } catch (e) {
                              setState(() {
                                isForget = false;
                              });
                              if (context.mounted) {
                                mySnackBar(context, e.toString());
                              }
                            }
                          } else {
                            setState(() {
                              isForget = false;
                            });
                            if (context.mounted) {
                              return mySnackBar(
                                context,
                                'This email was not used to create User account\nRegister first',
                              );
                            }
                          }
                        },
                      );
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
    );
  }
}
