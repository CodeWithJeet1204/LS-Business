import 'package:find_easy/firebase/auth_methods.dart';
import 'package:find_easy/page/register/business_register_details.dart';
import 'package:find_easy/page/register/firestore_info.dart';
import 'package:find_easy/page/register/verify/email_verify.dart';
import 'package:find_easy/page/register/verify/number_verify.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/collapse_container.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterCredPage extends StatefulWidget {
  const RegisterCredPage({super.key});

  @override
  State<RegisterCredPage> createState() => _RegisterCredPageState();
}

class _RegisterCredPageState extends State<RegisterCredPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  String phoneButtonText = "SIGNUP";
  String googleText = "SIGNUP";
  bool isGoogleRegistering = false;
  bool isShowEmail = false;
  bool isShowNumber = false;
  bool isEmailRegistering = false;
  bool isPhoneRegistering = false;
  bool isEmailChosen = false;
  bool isNumberChosen = false;
  bool isGoogleChosen = false;

  void navigateToEmailVerify() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Navigator.of(context).popAndPushNamed('/emailVerify');
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final AuthMethods auth = AuthMethods(_auth);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                  flex: 4,
                ),
                HeadText(text: "REGISTER"),
                Expanded(
                  child: Container(),
                  flex: 4,
                ),
                Column(
                  children: [
                    MyCollapseContainer(
                      headText: "Email",
                      isShow: isShowEmail,
                      horizontalMargin: 20,
                      horizontalPadding: 12,
                      verticalPadding: 8,
                      bodyWidget: Form(
                        key: registerFormKey,
                        child: Column(
                          children: [
                            MyTextFormField(
                              hintText: "Email",
                              controller: emailController,
                              borderRadius: 16,
                              horizontalPadding: 24,
                              keyboardType: TextInputType.emailAddress,
                              autoFillHints: [AutofillHints.email],
                            ),
                            SizedBox(height: 8),
                            MyTextFormField(
                              hintText: "Password",
                              controller: passwordController,
                              borderRadius: 16,
                              horizontalPadding: 24,
                              isPassword: true,
                              autoFillHints: [AutofillHints.newPassword],
                            ),
                            MyTextFormField(
                              hintText: "Confirm Password",
                              controller: confirmPasswordController,
                              borderRadius: 12,
                              horizontalPadding: 20,
                              verticalPadding: 8,
                              isPassword: true,
                              autoFillHints: [AutofillHints.newPassword],
                            ),
                            SizedBox(height: 8),
                            MyButton(
                              text: "SIGNUP",
                              onTap: () async {
                                if (passwordController.text ==
                                    confirmPasswordController.text) {
                                  if (registerFormKey.currentState!
                                      .validate()) {
                                    setState(() {
                                      isEmailRegistering = true;
                                    });

                                    try {
                                      await auth.signUpWithEmail(
                                        email: emailController.text,
                                        password: passwordController.text,
                                        context: context,
                                      );

                                      // Registration successful
                                      UserFirestoreData.addAll({
                                        'Email':
                                            emailController.text.toString(),
                                      });
                                      print(UserFirestoreData);

                                      isEmailChosen = true;
                                      setState(() {
                                        isEmailRegistering = false;
                                      });
                                      if (FirebaseAuth.instance.currentUser!
                                                  .email !=
                                              null ||
                                          _auth.currentUser!.email != null) {
                                        SystemChannels.textInput
                                            .invokeMethod('TextInput.hide');
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EmailVerifyPage(),
                                          ),
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      setState(() {
                                        isEmailRegistering = false;
                                      });

                                      if (e.code == 'email-already-in-use') {
                                        mySnackBar(
                                          context,
                                          'This email is already in use.',
                                        );
                                      } else {
                                        mySnackBar(context,
                                            e.message ?? 'An error occurred.');
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isEmailRegistering = false;
                                      });
                                      mySnackBar(context, e.toString());
                                    }
                                  } else {
                                    mySnackBar(
                                        context, "Passwords do not match");
                                  }
                                }
                              },
                              horizontalPadding: 24,
                              isLoading: isEmailRegistering,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isShowNumber = false;
                          isShowEmail = !isShowEmail;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    MyCollapseContainer(
                      headText: "Phone Number",
                      isShow: isShowNumber,
                      horizontalMargin: 20,
                      horizontalPadding: 12,
                      verticalPadding: 8,
                      bodyWidget: Form(
                        key: registerFormKey,
                        child: Column(
                          children: [
                            MyTextFormField(
                              hintText: "Phone Number",
                              controller: phoneController,
                              borderRadius: 16,
                              horizontalPadding: 24,
                              keyboardType: TextInputType.number,
                              autoFillHints: [AutofillHints.telephoneNumber],
                            ),
                            SizedBox(height: 8),
                            MyButton(
                              text: phoneButtonText,
                              onTap: () async {
                                if (registerFormKey.currentState!.validate()) {
                                  try {
                                    setState(() {
                                      isPhoneRegistering = true;
                                      phoneButtonText = "Please Wait";
                                    });
                                    isNumberChosen = true;
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
                                        isPhoneRegistering = true;
                                      });
                                      await _auth.verifyPhoneNumber(
                                          phoneNumber:
                                              "+91 ${phoneController.text}",
                                          verificationCompleted: (_) {
                                            setState(() {
                                              isPhoneRegistering = false;
                                            });
                                          },
                                          verificationFailed: (e) {
                                            mySnackBar(context, e.toString());
                                            setState(() {
                                              isPhoneRegistering = false;
                                              phoneButtonText = "SIGNUP";
                                            });
                                          },
                                          codeSent: (
                                            String verificationId,
                                            int? token,
                                          ) {
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NumberVerifyPage(
                                                  verificationId:
                                                      verificationId,
                                                  isLogging: false,
                                                ),
                                              ),
                                            );
                                            setState(() {
                                              isPhoneRegistering = false;
                                              phoneButtonText = "SIGNUP";
                                            });
                                          },
                                          codeAutoRetrievalTimeout: (e) {
                                            mySnackBar(context, e.toString());
                                            setState(() {
                                              isPhoneRegistering = false;
                                              phoneButtonText = "SIGNUP";
                                            });
                                          });
                                    }
                                    setState(() {
                                      isPhoneRegistering = false;
                                      phoneButtonText = "SIGNUP";
                                    });
                                  } catch (e) {
                                    setState(() {
                                      isPhoneRegistering = false;
                                      phoneButtonText = "SIGNUP";
                                    });
                                    mySnackBar(context, e.toString());
                                  }
                                }
                              },
                              horizontalPadding: 24,
                              isLoading: isPhoneRegistering,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isShowEmail = false;
                          isShowNumber = !isShowNumber;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isShowEmail = false;
                          isShowNumber = false;
                          isGoogleRegistering = true;
                          googleText = "PLEASE WAIT";
                        });
                        try {
                          // Sign In With Google
                          await AuthMethods(FirebaseAuth.instance)
                              .signInWithGoogle(context);
                          print("Signed in");
                          await _auth.currentUser!.reload();
                          if (FirebaseAuth.instance.currentUser != null) {
                            print(FirebaseAuth.instance.currentUser!.email);
                            UserFirestoreData.addAll({
                              "Email": FirebaseAuth.instance.currentUser!.email,
                              "Name": FirebaseAuth
                                  .instance.currentUser!.displayName,
                              "Phone Number": FirebaseAuth
                                  .instance.currentUser!.phoneNumber,
                              "uid": FirebaseAuth.instance.currentUser!.uid,
                              "Image":
                                  FirebaseAuth.instance.currentUser!.photoURL,
                            });
                            print("Data added");
                            // SystemChannels.textInput.invokeMethod('TextInput.hide');
                            // Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) =>
                                    BusinessRegisterDetailsPage()),
                              ),
                            );
                          } else {
                            print("User is null");
                          }
                          setState(() {
                            isGoogleRegistering = false;
                          });
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            isShowEmail = false;
                            isShowNumber = false;
                            isGoogleRegistering = false;
                          });
                          mySnackBar(context, e.toString());
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: isGoogleRegistering
                            ? CircularProgressIndicator(
                                color: primaryDark,
                              )
                            : Text(
                                googleText,
                                style: TextStyle(
                                  color: buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primary2.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
