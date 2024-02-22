import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/firebase/auth_methods.dart';
import 'package:find_easy/page/register/user_register_details.dart';
import 'package:find_easy/page/register/verify/email_verify.dart';
import 'package:find_easy/page/register/verify/number_verify.dart';
import 'package:find_easy/provider/sign_in_method_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/utils/size.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/collapse_container.dart';
import 'package:find_easy/widgets/head_text.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:find_easy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RegisterCredPage extends StatefulWidget {
  const RegisterCredPage({super.key});

  @override
  State<RegisterCredPage> createState() => _RegisterCredPageState();
}

class _RegisterCredPageState extends State<RegisterCredPage> {
  final GlobalKey<FormState> registerEmailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerNumberFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String phoneButtonText = "SIGNUP";
  String googleText = "Signup With GOOGLE";
  bool isGoogleRegistering = false;
  bool isEmailRegistering = false;
  bool isPhoneRegistering = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // NAVIGATE TO EMAIL VERIFY SCREEN
  void navigateToEmailVerify() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Navigator.of(context).popAndPushNamed('/emailVerify');
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final AuthMethods auth = AuthMethods();
    final signInMethodProvider = Provider.of<SignInMethodProvider>(context);
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: width < screenSize
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // REGISTER HEADTEXT
                    SizedBox(height: width * 0.35),
                    const HeadText(text: "REGISTER"),
                    SizedBox(height: width * 0.3),

                    Column(
                      children: [
                        // EMAIL
                        MyCollapseContainer(
                          width: MediaQuery.of(context).size.width,
                          text: "Email",
                          children: Padding(
                            padding: EdgeInsets.all(width * 0.0225),
                            child: Form(
                              key: registerEmailFormKey,
                              child: Column(
                                children: [
                                  // EMAIL
                                  MyTextFormField(
                                    hintText: "Email",
                                    controller: emailController,
                                    borderRadius: 16,
                                    horizontalPadding:
                                        MediaQuery.of(context).size.width *
                                            0.066,
                                    keyboardType: TextInputType.emailAddress,
                                    autoFillHints: const [AutofillHints.email],
                                  ),
                                  const SizedBox(height: 8),

                                  // PASSWORD
                                  MyTextFormField(
                                    hintText: "Password",
                                    controller: passwordController,
                                    borderRadius: 16,
                                    horizontalPadding:
                                        MediaQuery.of(context).size.width *
                                            0.066,
                                    isPassword: true,
                                    autoFillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                  ),
                                  MyTextFormField(
                                    hintText: "Confirm Password",
                                    controller: confirmPasswordController,
                                    borderRadius: 16,
                                    horizontalPadding:
                                        MediaQuery.of(context).size.width *
                                            0.066,
                                    verticalPadding: 8,
                                    isPassword: true,
                                    autoFillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  MyButton(
                                    text: "SIGNUP",
                                    onTap: () async {
                                      if (passwordController.text ==
                                          confirmPasswordController.text) {
                                        if (registerEmailFormKey.currentState!
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

                                            if (_auth.currentUser != null) {
                                              print('abc');
                                              await FirebaseFirestore.instance
                                                  .collection('Business')
                                                  .doc('Owners')
                                                  .collection('Users')
                                                  .doc(_auth.currentUser!.uid)
                                                  .set({
                                                'Email': emailController.text
                                                    .toString(),
                                                'emailVerified': false,
                                                'Image': null,
                                                'Name': null,
                                                'Phone Number': null,
                                                'uid': null,
                                              });

                                              await FirebaseFirestore.instance
                                                  .collection('Business')
                                                  .doc('Owners')
                                                  .collection('Shops')
                                                  .doc(_auth.currentUser!.uid)
                                                  .set({
                                                "Name": null,
                                                'Views': null,
                                                'Favorites': null,
                                                "GSTNumber": null,
                                                "Address": null,
                                                "Special Note": null,
                                                "Industry": null,
                                                "Image": null,
                                                "Type": null,
                                                'MembershipName': null,
                                                'MembershipDuration': null,
                                                'MembershipTime': null,
                                              });

                                              signInMethodProvider
                                                  .chooseEmail();
                                            } else {
                                              mySnackBar(context, 'abc');
                                            }

                                            setState(() {
                                              isEmailRegistering = false;
                                            });
                                            if (FirebaseAuth.instance
                                                        .currentUser!.email !=
                                                    null ||
                                                _auth.currentUser!.email !=
                                                    null) {
                                              SystemChannels.textInput
                                                  .invokeMethod(
                                                      'TextInput.hide');
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const EmailVerifyPage(),
                                                  ),
                                                );
                                              }
                                            }
                                          } on FirebaseAuthException catch (e) {
                                            setState(() {
                                              isEmailRegistering = false;
                                            });

                                            if (e.code ==
                                                'email-already-in-use') {
                                              if (context.mounted) {
                                                mySnackBar(
                                                  context,
                                                  'This email is already in use.',
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                mySnackBar(
                                                  context,
                                                  e.message ??
                                                      'An error occurred.',
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            setState(() {
                                              isEmailRegistering = false;
                                            });
                                            if (context.mounted) {
                                              mySnackBar(context, e.toString());
                                            }
                                          }
                                        } else {
                                          mySnackBar(context,
                                              "Passwords do not match");
                                        }
                                      } else {
                                        mySnackBar(
                                          context,
                                          "Passwords dont match, check again!",
                                        );
                                      }
                                    },
                                    horizontalPadding: width * 0.066,
                                    isLoading: isEmailRegistering,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // PHONE NUMBER
                        MyCollapseContainer(
                          width: MediaQuery.of(context).size.width,
                          text: "Phone Number",
                          children: Padding(
                            padding: EdgeInsets.all(width * 0.0225),
                            child: Form(
                              key: registerNumberFormKey,
                              child: Column(
                                children: [
                                  MyTextFormField(
                                    hintText: "Phone Number",
                                    controller: phoneController,
                                    borderRadius: 16,
                                    horizontalPadding:
                                        MediaQuery.of(context).size.width *
                                            0.066,
                                    keyboardType: TextInputType.number,
                                    autoFillHints: const [
                                      AutofillHints.telephoneNumber
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  MyButton(
                                    text: phoneButtonText,
                                    onTap: () async {
                                      if (registerNumberFormKey.currentState!
                                          .validate()) {
                                        try {
                                          setState(() {
                                            isPhoneRegistering = true;
                                            phoneButtonText = "Please Wait";
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('Business')
                                              .doc('Owners')
                                              .collection('Users')
                                              .doc(_auth.currentUser!.uid)
                                              .set({
                                            'Phone Number':
                                                phoneController.text.toString(),
                                            'Image': null,
                                            'Email': null,
                                            'Name': null,
                                            'uid': null,
                                          });

                                          await FirebaseFirestore.instance
                                              .collection('Business')
                                              .doc('Owners')
                                              .collection('Shops')
                                              .doc(_auth.currentUser!.uid)
                                              .set({
                                            "Name": null,
                                            'Views': null,
                                            'Favorites': null,
                                            "GSTNumber": null,
                                            "Address": null,
                                            "Special Note": null,
                                            "Industry": null,
                                            "Image": null,
                                            "Type": null,
                                            'MembershipName': null,
                                            'MembershipDuration': null,
                                            'MembershipTime': null,
                                            'deliveryAvailable': null,
                                            'codAvailable': null,
                                            'refundAvailable': null,
                                            'replacementAvailable': null,
                                            'giftWrapAvailable': null,
                                            'bulkSellAvailable': null,
                                            'gstInvoiceAvailable': null,
                                            'membershipAvailable': null,
                                            'deliveryRange': null,
                                            'refundRange': null,
                                            'replacementRange': null,
                                          });

                                          // Register with Phone
                                          signInMethodProvider.chooseNumber();
                                          if (phoneController.text
                                              .contains("+91")) {
                                            if (context.mounted) {
                                              await auth.phoneSignIn(context,
                                                  " ${phoneController.text}");
                                            }
                                          } else if (phoneController.text
                                              .contains("+91 ")) {
                                            if (context.mounted) {
                                              await auth.phoneSignIn(context,
                                                  phoneController.text);
                                            }
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
                                                  if (context.mounted) {
                                                    mySnackBar(
                                                        context, e.toString());
                                                  }
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
                                                      .invokeMethod(
                                                          'TextInput.hide');
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
                                                  if (context.mounted) {
                                                    mySnackBar(
                                                        context, e.toString());
                                                  }
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
                                          if (context.mounted) {
                                            mySnackBar(context, e.toString());
                                          }
                                        }
                                      }
                                    },
                                    horizontalPadding:
                                        MediaQuery.of(context).size.width *
                                            0.066,
                                    isLoading: isPhoneRegistering,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // GOOGLE
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              isGoogleRegistering = true;
                              googleText = "PLEASE WAIT";
                            });
                            try {
                              // Sign In With Google
                              signInMethodProvider.chooseGoogle();
                              await AuthMethods().signInWithGoogle(context);
                              await _auth.currentUser!.reload();
                              if (FirebaseAuth.instance.currentUser != null) {
                                await FirebaseFirestore.instance
                                    .collection('Business')
                                    .doc('Owners')
                                    .collection('Users')
                                    .doc(_auth.currentUser!.uid)
                                    .set({
                                  "Email":
                                      FirebaseAuth.instance.currentUser!.email,
                                  "Name": FirebaseAuth
                                      .instance.currentUser!.displayName,
                                  "uid": FirebaseAuth.instance.currentUser!.uid,
                                  'Image': null,
                                  'Phone Number': null,
                                });

                                await FirebaseFirestore.instance
                                    .collection('Business')
                                    .doc('Owners')
                                    .collection('Shops')
                                    .doc(_auth.currentUser!.uid)
                                    .update({
                                  "Name": null,
                                  'Views': null,
                                  'Favorites': null,
                                  "GSTNumber": null,
                                  "Address": null,
                                  "Special Note": null,
                                  "Industry": null,
                                  "Image": null,
                                  "Type": null,
                                  'MembershipName': null,
                                  'MembershipDuration': null,
                                  'MembershipTime': null,
                                });

                                // SystemChannels.textInput.invokeMethod('TextInput.hide');
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: ((context) =>
                                          const UserRegisterDetailsPage()),
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  mySnackBar(
                                    context,
                                    "Some error occured\nTry signing with email / phone number",
                                  );
                                }
                              }
                              setState(() {
                                isGoogleRegistering = false;
                              });
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                isGoogleRegistering = false;
                              });
                              if (context.mounted) {
                                mySnackBar(context, e.toString());
                              }
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.035,
                              0,
                              MediaQuery.of(context).size.width * 0.035,
                              MediaQuery.of(context).viewInsets.bottom,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.033,
                            ),
                            alignment: Alignment.center,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primary2.withOpacity(0.75),
                            ),
                            child: isGoogleRegistering
                                ? const CircularProgressIndicator(
                                    color: primaryDark,
                                  )
                                : Text(
                                    overflow: TextOverflow.ellipsis,
                                    googleText,
                                    style: TextStyle(
                                      color: buttonColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.045,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Container(
                    width: width * 0.66,
                    alignment: Alignment.center,
                    child: const HeadText(text: "REGISTER"),
                  ),
                  Container(
                    width: width * 0.33,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // EMAIL
                        MyCollapseContainer(
                          width: MediaQuery.of(context).size.width,
                          text: "Email",
                          children: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width < screenSize
                                  ? width * 0.0125
                                  : width * 0.0,
                              vertical: width * 0.025,
                            ),
                            child: Form(
                              key: registerEmailFormKey,
                              child: Column(
                                children: [
                                  // EMAIL
                                  MyTextFormField(
                                    hintText: "Email",
                                    controller: emailController,
                                    borderRadius: 16,
                                    horizontalPadding: width < screenSize
                                        ? width * 0.066
                                        : width * 0.05,
                                    keyboardType: TextInputType.emailAddress,
                                    autoFillHints: const [AutofillHints.email],
                                  ),
                                  const SizedBox(height: 8),

                                  // PASSWORD
                                  MyTextFormField(
                                    hintText: "Password",
                                    controller: passwordController,
                                    borderRadius: 16,
                                    horizontalPadding: width < screenSize
                                        ? width * 0.066
                                        : width * 0.05,
                                    isPassword: true,
                                    autoFillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                  ),
                                  MyTextFormField(
                                    hintText: "Confirm Password",
                                    controller: confirmPasswordController,
                                    borderRadius: 16,
                                    horizontalPadding: width < screenSize
                                        ? width * 0.066
                                        : width * 0.05,
                                    verticalPadding: 8,
                                    isPassword: true,
                                    autoFillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  MyButton(
                                    text: "SIGNUP",
                                    onTap: () async {
                                      if (passwordController.text ==
                                          confirmPasswordController.text) {
                                        if (registerEmailFormKey.currentState!
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

                                            if (_auth.currentUser != null) {
                                              print('abc');
                                              await FirebaseFirestore.instance
                                                  .collection('Business')
                                                  .doc('Owners')
                                                  .collection('Users')
                                                  .doc(_auth.currentUser!.uid)
                                                  .set({
                                                'Email': emailController.text
                                                    .toString(),
                                                'emailVerified': false,
                                                'Image': null,
                                                'Name': null,
                                                'Phone Number': null,
                                                'uid': null,
                                              });

                                              await FirebaseFirestore.instance
                                                  .collection('Business')
                                                  .doc('Owners')
                                                  .collection('Shops')
                                                  .doc(_auth.currentUser!.uid)
                                                  .set({
                                                "Name": null,
                                                'Views': null,
                                                'Favorites': null,
                                                "GSTNumber": null,
                                                "Address": null,
                                                "Special Note": null,
                                                "Industry": null,
                                                "Image": null,
                                                "Type": null,
                                                'MembershipName': null,
                                                'MembershipDuration': null,
                                                'MembershipTime': null,
                                              });

                                              signInMethodProvider
                                                  .chooseEmail();
                                            } else {
                                              mySnackBar(context, 'abc');
                                            }

                                            setState(() {
                                              isEmailRegistering = false;
                                            });
                                            if (FirebaseAuth.instance
                                                        .currentUser!.email !=
                                                    null ||
                                                _auth.currentUser!.email !=
                                                    null) {
                                              SystemChannels.textInput
                                                  .invokeMethod(
                                                      'TextInput.hide');
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const EmailVerifyPage(),
                                                  ),
                                                );
                                              }
                                            }
                                          } on FirebaseAuthException catch (e) {
                                            setState(() {
                                              isEmailRegistering = false;
                                            });

                                            if (e.code ==
                                                'email-already-in-use') {
                                              if (context.mounted) {
                                                mySnackBar(
                                                  context,
                                                  'This email is already in use.',
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                mySnackBar(
                                                  context,
                                                  e.message ??
                                                      'An error occurred.',
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            setState(() {
                                              isEmailRegistering = false;
                                            });
                                            if (context.mounted) {
                                              mySnackBar(context, e.toString());
                                            }
                                          }
                                        } else {
                                          mySnackBar(context,
                                              "Passwords do not match");
                                        }
                                      } else {
                                        mySnackBar(
                                          context,
                                          "Passwords dont match, check again!",
                                        );
                                      }
                                    },
                                    horizontalPadding: width < screenSize
                                        ? width * 0.066
                                        : width * 0.05,
                                    isLoading: isEmailRegistering,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // PHONE NUMBER
                        MyCollapseContainer(
                          width: MediaQuery.of(context).size.width,
                          text: "Phone Number",
                          children: Padding(
                            padding: EdgeInsets.all(width * 0.0225),
                            child: Form(
                              key: registerNumberFormKey,
                              child: Column(
                                children: [
                                  MyTextFormField(
                                    hintText: "Phone Number",
                                    controller: phoneController,
                                    borderRadius: 16,
                                    horizontalPadding: width < screenSize
                                        ? width * 0.066
                                        : width * 0.05,
                                    keyboardType: TextInputType.number,
                                    autoFillHints: const [
                                      AutofillHints.telephoneNumber
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  MyButton(
                                    text: phoneButtonText,
                                    onTap: () async {
                                      if (registerNumberFormKey.currentState!
                                          .validate()) {
                                        try {
                                          setState(() {
                                            isPhoneRegistering = true;
                                            phoneButtonText = "Please Wait";
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('Business')
                                              .doc('Owners')
                                              .collection('Users')
                                              .doc(_auth.currentUser!.uid)
                                              .set({
                                            'Phone Number':
                                                phoneController.text.toString(),
                                            'Image': null,
                                            'Email': null,
                                            'Name': null,
                                            'uid': null,
                                          });

                                          await FirebaseFirestore.instance
                                              .collection('Business')
                                              .doc('Owners')
                                              .collection('Shops')
                                              .doc(_auth.currentUser!.uid)
                                              .set({
                                            "Name": null,
                                            'Views': null,
                                            'Favorites': null,
                                            "GSTNumber": null,
                                            "Address": null,
                                            "Special Note": null,
                                            "Industry": null,
                                            "Image": null,
                                            "Type": null,
                                            'MembershipName': null,
                                            'MembershipDuration': null,
                                            'MembershipTime': null,
                                            'deliveryAvailable': null,
                                            'codAvailable': null,
                                            'refundAvailable': null,
                                            'replacementAvailable': null,
                                            'giftWrapAvailable': null,
                                            'bulkSellAvailable': null,
                                            'gstInvoiceAvailable': null,
                                            'membershipAvailable': null,
                                            'deliveryRange': null,
                                            'refundRange': null,
                                            'replacementRange': null,
                                          });

                                          // Register with Phone
                                          signInMethodProvider.chooseNumber();
                                          if (phoneController.text
                                              .contains("+91")) {
                                            if (context.mounted) {
                                              await auth.phoneSignIn(context,
                                                  " ${phoneController.text}");
                                            }
                                          } else if (phoneController.text
                                              .contains("+91 ")) {
                                            if (context.mounted) {
                                              await auth.phoneSignIn(context,
                                                  phoneController.text);
                                            }
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
                                                  if (context.mounted) {
                                                    mySnackBar(
                                                        context, e.toString());
                                                  }
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
                                                      .invokeMethod(
                                                          'TextInput.hide');
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
                                                  if (context.mounted) {
                                                    mySnackBar(
                                                        context, e.toString());
                                                  }
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
                                          if (context.mounted) {
                                            mySnackBar(context, e.toString());
                                          }
                                        }
                                      }
                                    },
                                    horizontalPadding: width < screenSize
                                        ? width * 0.066
                                        : width * 0.05,
                                    isLoading: isPhoneRegistering,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // GOOGLE
                        // GestureDetector(
                        //   onTap: () async {
                        //     setState(() {
                        //       isGoogleRegistering = true;
                        //       googleText = "PLEASE WAIT";
                        //     });
                        //     try {
                        // Sign In With Google
                        //       signInMethodProvider.chooseGoogle();
                        //       await AuthMethods().signInWithGoogle(context);
                        //       await _auth.currentUser!.reload();
                        //       if (FirebaseAuth.instance.currentUser != null) {
                        //         await FirebaseFirestore.instance
                        //             .collection('Business')
                        //             .doc('Owners')
                        //             .collection('Users')
                        //             .doc(_auth.currentUser!.uid)
                        //             .set({
                        //           "Email":
                        //               FirebaseAuth.instance.currentUser!.email,
                        //           "Name": FirebaseAuth
                        //               .instance.currentUser!.displayName,
                        //           "uid": FirebaseAuth.instance.currentUser!.uid,
                        //           'Image': null,
                        //           'Phone Number': null,
                        //         });
                        //         await FirebaseFirestore.instance
                        //             .collection('Business')
                        //             .doc('Owners')
                        //             .collection('Shops')
                        //             .doc(_auth.currentUser!.uid)
                        //             .update({
                        //           "Name": null,
                        //           'Views': null,
                        //           'Favorites': null,
                        //           "GSTNumber": null,
                        //           "Address": null,
                        //           "Special Note": null,
                        //           "Industry": null,
                        //           "Image": null,
                        //           "Type": null,
                        //           'MembershipName': null,
                        //           'MembershipDuration': null,
                        //           'MembershipTime': null,
                        //         });
                        //         SystemChannels.textInput.invokeMethod('TextInput.hide');
                        //         if (context.mounted) {
                        //           Navigator.of(context).pop();
                        //           Navigator.of(context).push(
                        //             MaterialPageRoute(
                        //               builder: ((context) =>
                        //                   const UserRegisterDetailsPage()),
                        //             ),
                        //           );
                        //         }
                        //       } else {
                        //         if (context.mounted) {
                        //           mySnackBar(
                        //             context,
                        //             "Some error occured\nTry signing with email / phone number",
                        //           );
                        //         }
                        //       }
                        //       setState(() {
                        //         isGoogleRegistering = false;
                        //       });
                        //     } on FirebaseAuthException catch (e) {
                        //       setState(() {
                        //         isGoogleRegistering = false;
                        //       });
                        //       if (context.mounted) {
                        //         mySnackBar(context, e.toString());
                        //       }
                        //     }
                        //   },
                        //   child: Container(
                        //     margin: EdgeInsets.symmetric(
                        //       horizontal: width < screenSize
                        //           ? width * 0.035
                        //           : width * 0.0275,
                        //     ),
                        //     padding: EdgeInsets.symmetric(
                        //       vertical: width < screenSize
                        //           ? width * 0.033
                        //           : width * 0.0125,
                        //     ),
                        //     alignment: Alignment.center,
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(10),
                        //       color: primary2.withOpacity(0.75),
                        //     ),
                        //     child: isGoogleRegistering
                        //         ? const Center(
                        //             child: CircularProgressIndicator(
                        //               color: primaryDark,
                        //             ),
                        //           )
                        //         : Text(
                        //             googleText,
                        //             style: TextStyle(
                        //               color: buttonColor,
                        //               fontWeight: FontWeight.w600,
                        //               fontSize: width < screenSize
                        //                   ? width * 0.05
                        //                   : width * 0.025,
                        //             ),
                        //           ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
