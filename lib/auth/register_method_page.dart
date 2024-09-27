import 'package:ls_business/auth/login_page.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/firebase/auth_methods.dart';
import 'package:ls_business/vendors/page/register/owner_register_details_page.dart';
import 'package:ls_business/auth/verify/email_verify.dart';
import 'package:ls_business/auth/verify/number_verify.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/collapse_container.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class RegisterMethodPage extends StatefulWidget {
  const RegisterMethodPage({
    super.key,
    // required this.mode,
  });

  // final String mode;

  @override
  State<RegisterMethodPage> createState() => _RegisterMethodPageState();
}

class _RegisterMethodPageState extends State<RegisterMethodPage> {
  final auth = FirebaseAuth.instance;
  final AuthMethods authMethods = AuthMethods();
  final store = FirebaseFirestore.instance;
  final GlobalKey<FormState> registerEmailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerNumberFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  String phoneText = 'SIGNUP';
  String googleText = 'Signup With GOOGLE';
  bool isEmailRegistering = false;
  bool isPhoneRegistering = false;
  bool isGoogleRegistering = false;
  bool isDialog = false;

  // DISPOSE
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // REGISTER EMAIL
  Future<void> registerEmail() async {
    if (passwordController.text == confirmPasswordController.text) {
      if (registerEmailFormKey.currentState!.validate()) {
        try {
          setState(() {
            isEmailRegistering = true;
            isDialog = true;
          });

          final userExistsSnap = await store
              .collection('Users')
              .where('Email', isEqualTo: emailController.text)
              .where('Registration', isEqualTo: 'email')
              .get();

          if (userExistsSnap.docs.isNotEmpty) {
            if (mounted) {
              setState(() {
                isEmailRegistering = false;
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
              .where('Email', isEqualTo: emailController.text)
              .where('Registration', isEqualTo: 'email')
              .get();

          if (vendorExistsSnap.docs.isNotEmpty) {
            if (mounted) {
              setState(() {
                isEmailRegistering = false;
                isDialog = false;
              });
              await auth.signInWithEmailAndPassword(
                email: emailController.text.toString(),
                password: passwordController.text.toString(),
              );
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const MainPage(),
                  ),
                  (route) => false,
                );
                return;
              }
              if (mounted) {
                return mySnackBar(
                  context,
                  'This account is already registered. Signing you in',
                );
              }
            }
          }

          if (mounted) {
            await authMethods.signUpWithEmail(
              email: emailController.text,
              password: passwordController.text,
              context: context,
            );
          }

          if (auth.currentUser != null) {
            // if (widget.mode == 'vendor') {
            await store
                .collection('Business')
                .doc('Owners')
                .collection('Users')
                .doc(auth.currentUser!.uid)
                .set({
              'Email': emailController.text.toString(),
              'Registration': 'email',
              'Image': null,
              'Name': null,
              'Phone Number': null,
              'allowCalls': true,
              'allowChats': true,
              'hasReviewed': false,
            });

            await store
                .collection('Business')
                .doc('Owners')
                .collection('Shops')
                .doc(auth.currentUser!.uid)
                .set({
              'Name': null,
              'Registration': 'email',
              'GSTNumber': null,
              'Description': null,
              // 'Industry': null,
              'Image': null,
              'Type': null,
              'MembershipName': null,
              'MembershipDuration': null,
              'MembershipStartDateTime': null,
            });
            /*}  else if (widget.mode == 'services') {
              // nothing
            } else if (widget.mode == 'events') {
              // code for events
            }*/
          } else {
            setState(() {
              isEmailRegistering = false;
              isDialog = false;
            });
            if (mounted) {
              return mySnackBar(context, 'Some error occured');
            }
          }

          setState(() {
            isEmailRegistering = false;
            isDialog = false;
          });
          if (auth.currentUser!.email != null) {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EmailVerifyPage(
                    fromMainPage: false,
                  ),
                ),
              );
            }
          }
        } catch (e) {
          setState(() {
            isEmailRegistering = false;
            isDialog = false;
          });
          if (mounted) {
            return mySnackBar(context, e.toString());
          }
        }
      }
    } else {
      return mySnackBar(
        context,
        'Passwords do not match, check again!',
      );
    }
  }

  // REGISTER PHONE
  Future<void> registerPhone() async {
    if (registerNumberFormKey.currentState!.validate()) {
      try {
        setState(() {
          isPhoneRegistering = true;
          isDialog = true;
        });

        final userExistsSnap = await store
            .collection('Users')
            .where('Phone Number', isEqualTo: '+91 ${phoneController.text}')
            .where('Registration', isEqualTo: 'phone number')
            .get();

        if (userExistsSnap.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              isPhoneRegistering = false;
              isDialog = false;
            });
            return mySnackBar(
              context,
              'This account was created in User app, use a different Phone Number here',
            );
          }
        }

        final vendorExistsSnap = await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .where('Phone Number', isEqualTo: '+91 ${phoneController.text}')
            .where('Registration', isEqualTo: 'phone number')
            .get();

        if (vendorExistsSnap.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              isPhoneRegistering = false;
              isDialog = false;
            });
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => false,
            );
            return mySnackBar(
              context,
              'This account is already registered. Log in',
            );
          }
        }

        await auth.verifyPhoneNumber(
          phoneNumber: '+91 ${phoneController.text}',
          verificationCompleted: (_) {
            setState(() {
              isPhoneRegistering = false;
              isDialog = false;
            });
          },
          verificationFailed: (e) {
            setState(() {
              isPhoneRegistering = false;
              isDialog = false;
            });
            if (mounted) {
              mySnackBar(
                context,
                e.toString(),
              );
            }
          },
          codeSent: (
            String verificationId,
            int? token,
          ) {
            setState(() {
              isPhoneRegistering = false;
              isDialog = false;
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NumberVerifyPage(
                  verificationId: verificationId,
                  fromMainPage: false,
                  phoneNumber: phoneController.text.toString(),
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (e) {
            setState(() {
              isPhoneRegistering = false;
              isDialog = false;
            });
            if (mounted) {
              mySnackBar(
                context,
                e.toString(),
              );
            }
          },
        );
      } catch (e) {
        setState(() {
          isPhoneRegistering = false;
          isDialog = false;
        });
        if (mounted) {
          return mySnackBar(context, e.toString());
        }
      }
    }
  }

  // REGISTER GOOGLE
  Future<void> registerGoogle() async {
    try {
      setState(() {
        isGoogleRegistering = true;
        isDialog = true;
      });

      await AuthMethods().signInWithGoogle(context);
      await auth.currentUser?.reload();
      if (auth.currentUser != null) {
        final userExistsSnap = await store
            .collection('Users')
            .where('Email', isEqualTo: auth.currentUser!.email)
            .where('Registration', isEqualTo: 'google')
            .get();

        if (userExistsSnap.docs.isNotEmpty) {
          await auth.signOut();
          setState(() {
            isGoogleRegistering = false;
            isDialog = false;
          });
          if (mounted) {
            return mySnackBar(
              context,
              'This account was created in User app, use a different Google Account here',
            );
          }
        }

        final vendorExistsSnap = await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .where('Email', isEqualTo: auth.currentUser!.email)
            .where('Registration', isEqualTo: 'google')
            .get();

        if (vendorExistsSnap.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              isGoogleRegistering = false;
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
              'This account is already registered. Signing you in',
            );
          }
        }

        // if (widget.mode == 'vendor') {
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .set({
          'Email': auth.currentUser!.email,
          'Registration': 'google',
          'Image': null,
          'Name': null,
          'Phone Number': null,
          'allowCalls': true,
          'allowChats': true,
          'hasReviewed': false,
        });

        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .set({
          'Name': null,
          'Registration': 'google',
          'GSTNumber': null,
          'Description': null,
          // 'Industry': null,
          'Image': null,
          'Type': null,
          'MembershipName': null,
          'MembershipDuration': null,
          'MembershipStartDateTime': null,
        });
        /*}  else if (widget.mode == 'services') {
              // nothing
            } else if (widget.mode == 'events') {
              // code for events
            }*/
      } else {
        setState(() {
          isGoogleRegistering = false;
          isDialog = false;
        });
        if (mounted) {
          return mySnackBar(
            context,
            'Some error occured\nTry signing with Email / Phone Number',
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
            // if (widget.mode == 'vendor') {
            return const OwnerRegisterDetailsPage(
              fromMainPage: false,
            );
            // } else if (widget.mode == 'services') {
            //   return const ServicesRegisterDetailsPage();
            // } else if (widget.mode == 'events') {
            //   return const EventsRegisterDetailsPage1();
            // }
            // return const MainPage();
          }),
          (route) => false,
        );
      }
      setState(() {
        isGoogleRegistering = false;
        isDialog = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isGoogleRegistering = false;
        isDialog = false;
      });
      if (mounted) {
        return mySnackBar(context, e.toString());
      }
    }
  }

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
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Register'),
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
            child: /* width < screenSize
                ?*/
                Padding(
              padding: EdgeInsets.all(
                width * 0.006125,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // REGISTER HEADTEXT
                    // SizedBox(height: width * 0.35),
                    // const HeadText(
                    //   text: 'REGISTER',
                    // ),
                    // SizedBox(height: width * 0.65),

                    // EMAIL
                    MyCollapseContainer(
                      width: width,
                      text: 'Email',
                      isExpanded: false,
                      children: Padding(
                        padding: EdgeInsets.all(width * 0.0225),
                        child: Form(
                          key: registerEmailFormKey,
                          child: Column(
                            children: [
                              // EMAIL
                              MyTextFormField(
                                hintText: 'Email',
                                controller: emailController,
                                borderRadius: 16,
                                horizontalPadding: width * 0.066,
                                keyboardType: TextInputType.emailAddress,
                                autoFillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: 8),

                              // PASSWORD
                              MyTextFormField(
                                hintText: 'Password',
                                controller: passwordController,
                                borderRadius: 16,
                                horizontalPadding: width * 0.066,
                                isPassword: true,
                                autoFillHints: const [
                                  AutofillHints.newPassword
                                ],
                              ),
                              MyTextFormField(
                                hintText: 'Confirm Password',
                                controller: confirmPasswordController,
                                borderRadius: 16,
                                horizontalPadding: width * 0.066,
                                verticalPadding: 8,
                                isPassword: true,
                                autoFillHints: const [
                                  AutofillHints.newPassword
                                ],
                              ),
                              const SizedBox(height: 8),
                              MyButton(
                                text: 'SIGNUP',
                                onTap: () async {
                                  await registerEmail();
                                },
                                horizontalPadding: width * 0.066,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // PHONE NUMBER
                    MyCollapseContainer(
                      width: width,
                      text: 'Phone Number',
                      isExpanded: false,
                      children: Padding(
                        padding: EdgeInsets.all(width * 0.0225),
                        child: Form(
                          key: registerNumberFormKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.07,
                                ),
                                child: TextFormField(
                                  autofocus: false,
                                  controller: phoneController,
                                  keyboardType: TextInputType.number,
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  maxLines: 1,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    prefixText: '+91 ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.cyan.shade700,
                                      ),
                                    ),
                                    hintText: 'Phone Number',
                                  ),
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.isEmpty) {
                                        return 'Please enter Phone Number';
                                      } else {
                                        if (value.length != 10) {
                                          return 'Number must be 10 chars long';
                                        }
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              MyButton(
                                text: phoneText,
                                onTap: () async {
                                  await registerPhone();
                                },
                                horizontalPadding: width * 0.066,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // GOOGLE
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          await registerGoogle();
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                            width * 0.035,
                            0,
                            width * 0.035,
                            MediaQuery.of(context).viewInsets.bottom,
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
                          child: isGoogleRegistering
                              ? const CircularProgressIndicator(
                                  color: primaryDark,
                                )
                              : Text(
                                  googleText,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: buttonColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: width * 0.045,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // ALREADY HAVE AN ACCOUNT ? TEXT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                        ),
                        MyTextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          text: 'LOGIN',
                          textColor: buttonColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // : Row(
            //     children: [
            //       Container(
            //         width: width * 0.66,
            //         alignment: Alignment.center,
            //         child: const HeadText(
            //           text: 'REGISTER',
            //         ),
            //       ),
            //       Container(
            //         width: width * 0.33,
            //         alignment: Alignment.center,
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             // EMAIL
            //             MyCollapseContainer(
            //               width: width,
            //               text: 'Email',
            //               children: Padding(
            //                 padding: EdgeInsets.symmetric(
            //                   horizontal: width < screenSize
            //                       ? width * 0.0125
            //                       : width * 0.0,
            //                   vertical: width * 0.025,
            //                 ),
            //                 child: Form(
            //                   key: registerEmailFormKey,
            //                   child: Column(
            //                     children: [
            //                       // EMAIL
            //                       MyTextFormField(
            //                         hintText: 'Email',
            //                         controller: emailController,
            //                         borderRadius: 16,
            //                         horizontalPadding: width < screenSize
            //                             ? width * 0.066
            //                             : width * 0.05,
            //                         keyboardType: TextInputType.emailAddress,
            //                         autoFillHints: const [AutofillHints.email],
            //                       ),
            //                       const SizedBox(height: 8),
            //                       // PASSWORD
            //                       MyTextFormField(
            //                         hintText: 'Password',
            //                         controller: passwordController,
            //                         borderRadius: 16,
            //                         horizontalPadding: width < screenSize
            //                             ? width * 0.066
            //                             : width * 0.05,
            //                         isPassword: true,
            //                         autoFillHints: const [
            //                           AutofillHints.newPassword
            //                         ],
            //                       ),
            //                       MyTextFormField(
            //                         hintText: 'Confirm Password',
            //                         controller: confirmPasswordController,
            //                         borderRadius: 16,
            //                         horizontalPadding: width < screenSize
            //                             ? width * 0.066
            //                             : width * 0.05,
            //                         verticalPadding: 8,
            //                         isPassword: true,
            //                         autoFillHints: const [
            //                           AutofillHints.newPassword
            //                         ],
            //                       ),
            //                       const SizedBox(height: 8),
            //                       MyButton(
            //                         text: 'SIGNUP',
            //                         onTap: () async {
            //                           if (passwordController.text ==
            //                               confirmPasswordController.text) {
            //                             if (registerEmailFormKey.currentState!
            //                                 .validate()) {
            //                               setState(() {
            //                                 isEmailRegistering = true;
            //                               });
            //                               try {
            //                                 await authMethods.signUpWithEmail(
            //                                   email: emailController.text,
            //                                   password: passwordController.text,
            //                                   context: context,
            //                                 );
            //                                 if (auth.currentUser != null) {
            //                                   await store
            //                                       .collection('Business')
            //                                       .doc('Owners')
            //                                       .collection('Users')
            //                                       .doc(auth.currentUser!.uid)
            //                                       .set({
            //                                     'Email': emailController.text
            //                                         .toString(),
            //                                     'Image': null,
            //                                     'Name': null,
            //                                     'Phone Number': null,
            //                                   });
            //                                   await store
            //                                       .collection('Business')
            //                                       .doc('Owners')
            //                                       .collection('Shops')
            //                                       .doc(auth.currentUser!.uid)
            //                                       .set({
            //                                     'Name': null,
            //                                     'GSTNumber': null,
            //                                     'Description': null,
            //                                     'Industry': null,
            //                                     'Image': null,
            //                                     'Type': null,
            //                                     'MembershipName': null,
            //                                     'MembershipDuration': null,
            //                                     'MembershipStartDateTime': null,
            //                                   });
            //                                   signInMethodProvider
            //                                       .chooseEmail();
            //                                 } else {
            //                                   if (context.mounted) {
            //                                     mySnackBar(context, 'abc');
            //                                   }
            //                                 }
            //                                 setState(() {
            //                                   isEmailRegistering = false;
            //                                 });
            //                                 if (FirebaseAuth.instance
            //                                             .currentUser!.email !=
            //                                         null ||
            //                                     auth.currentUser!.email !=
            //                                         null) {
            //                                   if (context.mounted) {
            //                                     Navigator.of(context).push(
            //                                       MaterialPageRoute(
            //                                         builder: (context) =>
            //                                             EmailVerifyPage(
            //                                           mode: widget.mode,
            //                                           isLogging: false,
            //                                         ),
            //                                       ),
            //                                     );
            //                                   }
            //                                 }
            //                               } on FirebaseAuthException catch (e) {
            //                                 setState(() {
            //                                   isEmailRegistering = false;
            //                                 });
            //                                 if (e.code ==
            //                                     'email-already-in-use') {
            //                                   if (context.mounted) {
            //                                     mySnackBar(
            //                                       context,
            //                                       'This Email is already in use.',
            //                                     );
            //                                   }
            //                                 } else {
            //                                   if (context.mounted) {
            //                                     mySnackBar(
            //                                       context,
            //                                       e.message ??
            //                                           'An error occurred.',
            //                                     );
            //                                   }
            //                                 }
            //                               } catch (e) {
            //                                 setState(() {
            //                                   isEmailRegistering = false;
            //                                 });
            //                                 if (context.mounted) {
            //                                   mySnackBar(context, e.toString());
            //                                 }
            //                               }
            //                             } else {
            //                               mySnackBar(context,
            //                                   'Passwords do not match');
            //                             }
            //                           } else {
            //                             mySnackBar(
            //                               context,
            //                               'Passwords dont match, check again!',
            //                             );
            //                           }
            //                         },
            //                         horizontalPadding: width < screenSize
            //                             ? width * 0.066
            //                             : width * 0.05,
            //                         isLoading: isEmailRegistering,
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(height: 12),
            //             // PHONE NUMBER
            //             MyCollapseContainer(
            //               width: width,
            //               text: 'Phone Number',
            //               children: Padding(
            //                 padding: EdgeInsets.all(width * 0.0225),
            //                 child: Form(
            //                   key: registerNumberFormKey,
            //                   child: Column(
            //                     children: [
            //                       MyTextFormField(
            //                         hintText: 'Phone Number',
            //                         controller: phoneController,
            //                         borderRadius: 16,
            //                         horizontalPadding: width < screenSize
            //                             ? width * 0.066
            //                             : width * 0.05,
            //                         keyboardType: TextInputType.number,
            //                         autoFillHints: const [
            //                           AutofillHints.telephoneNumber
            //                         ],
            //                       ),
            //                       const SizedBox(height: 8),
            //                       MyButton(
            //                         text: phoneText,
            //                         onTap: () async {
            //                           await phoneNumberRegister(
            //                               signInMethodProvider);
            //                         },
            //                         horizontalPadding: width < screenSize
            //                             ? width * 0.066
            //                             : width * 0.05,
            //                         isLoading: isPhoneRegistering,
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(height: 16),
            //             // GOOGLE
            //             // GestureDetector(
            //             //   onTap: () async {
            //             //     setState(() {
            //             //       isGoogleRegistering = true;
            //             //     });
            //             //     try {
            //             // Sign In With Google
            //             //       signInMethodProvider.chooseGoogle();
            //             //       await AuthMethods().signInWithGoogle(context);
            //             //       await _auth.currentUser!.reload();
            //             //       if (auth.currentUser != null) {
            //             //         await store
            //             //             .collection('Business')
            //             //             .doc('Owners')
            //             //             .collection('Users')
            //             //             .doc(_auth.currentUser!.uid)
            //             //             .set({
            //             //           'Email':
            //             //               auth.currentUser!.email,
            //             //           'Name': FirebaseAuth
            //             //               .instance.currentUser!.displayName,
            //             //           'Image': null,
            //             //           'Phone Number': null,
            //             //         });
            //             //         await store
            //             //             .collection('Business')
            //             //             .doc('Owners')
            //             //             .collection('Shops')
            //             //             .doc(_auth.currentUser!.uid)
            //             //             .update({
            //             //           'Name': null,
            //             //           'GSTNumber': null,
            //             //           'Description': null,
            //             //           'Industry': null,
            //             //           'Image': null,
            //             //           'Type': null,
            //             //           'MembershipName': null,
            //             //           'MembershipDuration': null,
            //             //           'MembershipStartDateTime': null,
            //             //         });
            //             //
            //             //         if (mounted) {
            //             //           Navigator.of(context).pop();
            //             //           Navigator.of(context).push(
            //             //             MaterialPageRoute(
            //             //               builder: (context) =>
            //             //                   const UserRegisterDetailsPage(),
            //             //             ),
            //             //           );
            //             //         }
            //             //       } else {
            //             //         if (mounted) {
            //             //           mySnackBar(
            //             //             context,
            //             //             'Some error occured\nTry signing with Email / Phone Number',
            //             //           );
            //             //         }
            //             //       }
            //             //       setState(() {
            //             //         isGoogleRegistering = false;
            //             //       });
            //             //     } on FirebaseAuthException catch (e) {
            //             //       setState(() {
            //             //         isGoogleRegistering = false;
            //             //       });
            //             //       if (mounted) {
            //             //         mySnackBar(context, e.toString());
            //             //       }
            //             //     }
            //             //   },
            //             //   child: Container(
            //             //     margin: EdgeInsets.symmetric(
            //             //       horizontal: width < screenSize
            //             //           ? width * 0.035
            //             //           : width * 0.0275,
            //             //     ),
            //             //     padding: EdgeInsets.symmetric(
            //             //       vertical: width < screenSize
            //             //           ? width * 0.033
            //             //           : width * 0.0125,
            //             //     ),
            //             //     alignment: Alignment.center,
            //             //     width: double.infinity,
            //             //     decoration: BoxDecoration(
            //             //       borderRadius: BorderRadius.circular(10),
            //             //       color: primary2.withOpacity(0.75),
            //             //     ),
            //             //     child: isGoogleRegistering
            //             //         ? const Center(
            //             //             child: CircularProgressIndicator(
            //             //               color: primaryDark,
            //             //             ),
            //             //           )
            //             //         : Text(
            //             //             googleText,
            //             //             style: TextStyle(
            //             //               color: buttonColor,
            //             //               fontWeight: FontWeight.w600,
            //             //               fontSize: width < screenSize
            //             //                   ? width * 0.05
            //             //                   : width * 0.025,
            //             //             ),
            //             //           ),
            //             //   ),
            //             // ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
          ),
        ),
      ),
    );
  }
}
