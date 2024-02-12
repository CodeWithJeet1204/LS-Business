import 'package:find_easy/firebase/auth_methods.dart';
import 'package:find_easy/page/register/verify/number_verify.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/collapse_container.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_button.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> emailLoginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> numberLoginFormKey = GlobalKey<FormState>();
  String phoneText = "Verify";
  String googleText = "Sign in With GOOGLE";
  bool isGoogleLogging = false;
  bool isEmailLogging = false;
  bool isPhoneLogging = false;

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final AuthMethods auth = AuthMethods();
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: width * 0.35),
              const HeadText(text: "LOGIN"),
              SizedBox(height: width * 0.3),
              Column(
                children: [
                  // EMAIL
                  MyCollapseContainer(
                    children: Form(
                      key: emailLoginFormKey,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: width * 0.0225,
                          horizontal: width * 0.01,
                        ),
                        child: Column(
                          children: [
                            MyTextFormField(
                              hintText: "Email",
                              controller: emailController,
                              borderRadius: 16,
                              horizontalPadding: width * 0.066,
                              keyboardType: TextInputType.emailAddress,
                              autoFillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 8),
                            MyTextFormField(
                              hintText: "Password",
                              controller: passwordController,
                              borderRadius: 16,
                              horizontalPadding: width * 0.066,
                              isPassword: true,
                              autoFillHints: const [AutofillHints.password],
                            ),
                            const SizedBox(height: 8),
                            MyButton(
                              text: "LOGIN",
                              onTap: () async {
                                if (emailLoginFormKey.currentState!
                                    .validate()) {
                                  try {
                                    setState(() {
                                      isEmailLogging = true;
                                    });
                                    // Login
                                    await _auth.signInWithEmailAndPassword(
                                      email: emailController.text.toString(),
                                      password:
                                          passwordController.text.toString(),
                                    );
                                    setState(() {});
                                    // if (context.mounted) {
                                    //   Navigator.of(context)
                                    //       .popAndPushNamed('/profile');
                                    // }
                                    setState(() {
                                      isEmailLogging = false;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      isEmailLogging = false;
                                    });
                                    if (context.mounted) {
                                      if (e !=
                                          "Null check operator used on a null value") {
                                        if (context.mounted) {
                                          mySnackBar(context, e.toString());
                                        }
                                      }
                                    }
                                  }
                                }
                              },
                              horizontalPadding: width * 0.066,
                              isLoading: isEmailLogging,
                            ),
                          ],
                        ),
                      ),
                    ),
                    width: width,
                    text: "Email",
                  ),

                  // PHONE NUMBER
                  MyCollapseContainer(
                    children: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.0125,
                        vertical: width * 0.025,
                      ),
                      child: Form(
                        key: numberLoginFormKey,
                        child: Column(
                          children: [
                            MyTextFormField(
                              hintText: "Phone Number",
                              controller: phoneController,
                              borderRadius: 16,
                              horizontalPadding: width * 0.066,
                              keyboardType: TextInputType.number,
                              autoFillHints: const [
                                AutofillHints.telephoneNumberDevice
                              ],
                            ),
                            const SizedBox(height: 8),
                            MyButton(
                              text: phoneText,
                              onTap: () async {
                                if (numberLoginFormKey.currentState!
                                    .validate()) {
                                  try {
                                    setState(() {
                                      isPhoneLogging = true;
                                      phoneText = "PLEASE WAIT";
                                    });
                                    // Register with Phone
                                    if (phoneController.text.contains("+91")) {
                                      await auth.phoneSignIn(
                                          context, " ${phoneController.text}");
                                    } else if (phoneController.text
                                        .contains("+91 ")) {
                                      await auth.phoneSignIn(
                                          context, phoneController.text);
                                    } else {
                                      setState(() {
                                        isPhoneLogging = true;
                                      });
                                      await _auth.verifyPhoneNumber(
                                          phoneNumber:
                                              "+91 ${phoneController.text}",
                                          verificationCompleted: (_) {
                                            setState(() {
                                              isPhoneLogging = false;
                                            });
                                          },
                                          verificationFailed: (e) {
                                            if (context.mounted) {
                                              mySnackBar(context, e.toString());
                                            }
                                            setState(() {
                                              isPhoneLogging = false;
                                            });
                                          },
                                          codeSent: (String verificationId,
                                              int? token) {
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NumberVerifyPage(
                                                  verificationId:
                                                      verificationId,
                                                  isLogging: true,
                                                ),
                                              ),
                                            );
                                            setState(() {
                                              isPhoneLogging = false;
                                            });
                                          },
                                          codeAutoRetrievalTimeout: (e) {
                                            if (context.mounted) {
                                              mySnackBar(context, e.toString());
                                            }
                                            isPhoneLogging = false;
                                          });
                                    }
                                    setState(() {
                                      isPhoneLogging = false;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      isPhoneLogging = false;
                                    });
                                    if (context.mounted) {
                                      mySnackBar(context, e.toString());
                                    }
                                  }
                                }
                              },
                              horizontalPadding: width * 0.066,
                              isLoading: isPhoneLogging,
                            ),
                          ],
                        ),
                      ),
                    ),
                    width: width,
                    text: "Phone Number",
                  ),
                  const SizedBox(height: 16),

                  // SIGN IN WITH GOOGLE
                  GestureDetector(
                    onTap: () async {
                      try {
                        setState(() {
                          googleText = "PLEASE WAIT";
                          isGoogleLogging = true;
                        });
                        // Sign In With Google
                        await AuthMethods().signInWithGoogle(context);
                        // SystemChannels.textInput
                        //     .invokeMethod('TextInput.hide');
                        if (FirebaseAuth.instance.currentUser != null) {
                          setState(() {});
                        } else {
                          if (context.mounted) {
                            mySnackBar(context, "Some error occured!");
                          }
                        }
                      } on FirebaseAuthException catch (e) {
                        if (context.mounted) {
                          mySnackBar(context, e.toString());
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: width * 0.033,
                      ),
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primary2.withOpacity(0.75),
                      ),
                      child: isGoogleLogging
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryDark,
                              ),
                            )
                          : Text(
                              googleText,
                              style: TextStyle(
                                color: buttonColor,
                                fontWeight: FontWeight.w600,
                                fontSize: width * 0.05,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 120),

              // DONT HAVE AN ACCOUNT ? TEXT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  MyTextButton(
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      Navigator.of(context).popAndPushNamed('/registerPay');
                    },
                    text: "REGISTER",
                    textColor: buttonColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
