import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/auth/verify/email_verify.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    // required this.mode,
  });

  // final String mode;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  // final AuthMethods authMethods = AuthMethods();
  final signInEmailFormKey = GlobalKey<FormState>();
  // final signInPhoneFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // final phoneController = TextEditingController();
  bool isEmailSigningIn = false;
  // bool isPhoneSigningIn = false;
  // bool isGoogleSigningIn = false;
  bool isDialog = false;

  // DISPOSE
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // phoneController.dispose();
    super.dispose();
  }

  // REGISTER EMAIL
  Future<void> registerEmail() async {
    if (signInEmailFormKey.currentState!.validate()) {
      try {
        setState(() {
          isEmailSigningIn = true;
          isDialog = true;
        });

        final userExistsSnap = await store
            .collection('Users')
            .where('Email', isEqualTo: emailController.text.toString().trim())
            .where('Registration', isEqualTo: 'email')
            .get();

        if (userExistsSnap.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              isEmailSigningIn = false;
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
            .where('Email', isEqualTo: emailController.text.toString().trim())
            .where('Registration', isEqualTo: 'email')
            .get();

        if (vendorExistsSnap.docs.isNotEmpty) {
          if (mounted) {
            await auth.signInWithEmailAndPassword(
              email: emailController.text.toString().trim(),
              password: passwordController.text.toString().trim(),
            );

            setState(() {
              isEmailSigningIn = false;
              isDialog = false;
            });

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
                'Signed In',
              );
            }
          }
        }

        if (mounted) {
          await auth.createUserWithEmailAndPassword(
            email: emailController.text.toString().trim(),
            password: passwordController.text.toString().trim(),
          );
          await auth.signInWithEmailAndPassword(
            email: emailController.text.toString().trim(),
            password: passwordController.text.toString().trim(),
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
            'Email': emailController.text.toString().trim(),
            'Registration': 'email',
            'Image': null,
            'Name': null,
            'Phone Number': null,
            'allowCalls': true,
            'allowChats': true,
            // 'hasReviewed': false,
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

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const EmailVerifyPage(
                  fromMainPage: false,
                ),
              ),
              (route) => false,
            );
          }
        } else {
          setState(() {
            isEmailSigningIn = false;
            isDialog = false;
          });
          if (mounted) {
            return mySnackBar(
              context,
              'Some error occured, try closing & opening the app',
            );
          }
        }
      } catch (e) {
        setState(() {
          isEmailSigningIn = false;
          isDialog = false;
        });
        if (mounted) {
          return mySnackBar(context, 'Error: ${e.toString()}');
        }
      }
    }
  }

  // REGISTER PHONE
  // Future<void> registerPhone() async {
  //   if (signInPhoneFormKey.currentState!.validate()) {
  //     try {
  //       setState(() {
  //         isPhoneSigningIn = true;
  //         isDialog = true;
  //       });
  //       final userExistsSnap = await store
  //           .collection('Users')
  //           .where('Phone Number',
  //               isGreaterThanOrEqualTo: phoneController.text.toString().trim())
  //           .where('Registration', isEqualTo: 'phone number')
  //           .get();
  //       if (userExistsSnap.docs.isNotEmpty) {
  //         if (mounted) {
  //           setState(() {
  //             isPhoneSigningIn = false;
  //             isDialog = false;
  //           });
  //           return mySnackBar(
  //             context,
  //             'This account was created in User app, use a different Phone Number here',
  //           );
  //         }
  //       }
  //       final vendorExistsSnap = await store
  //           .collection('Business')
  //           .doc('Owners')
  //           .collection('Users')
  //           .where('Phone Number',
  //               isGreaterThanOrEqualTo: phoneController.text.toString().trim())
  //           .where('Registration', isEqualTo: 'phone number')
  //           .get();
  //       if (vendorExistsSnap.docs.isNotEmpty) {
  //         if (mounted) {
  //           await auth.verifyPhoneNumber(
  //             phoneNumber:
  //                 phoneController.text.toString().trim().contains('+91 ')
  //                     ? phoneController.text.toString().trim()
  //                     : '+91 ${phoneController.text.toString().trim()}',
  //             verificationCompleted: (_) {
  //               setState(() {
  //                 isPhoneSigningIn = false;
  //               });
  //             },
  //             verificationFailed: (e) {
  //               if (context.mounted) {
  //                 setState(() {
  //                   isPhoneSigningIn = false;
  //                   isDialog = false;
  //                 });
  //                 mySnackBar(context, 'Error: ${e.toString()}');
  //               }
  //             },
  //             codeSent: (
  //               String verificationId,
  //               int? token,
  //             ) {
  //               setState(() {
  //                 isPhoneSigningIn = false;
  //                 isDialog = false;
  //               });
  //               Navigator.of(context).pushAndRemoveUntil(
  //                 MaterialPageRoute(
  //                   builder: (context) => NumberVerifyPage(
  //                     phoneNumber: phoneController.text
  //                             .toString()
  //                             .trim()
  //                             .contains('+91 ')
  //                         ? phoneController.text.toString().trim()
  //                         : '+91 ${phoneController.text.toString().trim()}',
  //                     verificationId: verificationId,
  //                     isLogging: true,
  //                     // fromMainPage: false,
  //                   ),
  //                 ),
  //                 (route) => false,
  //               );
  //             },
  //             codeAutoRetrievalTimeout: (e) {
  //               if (context.mounted) {
  //                 setState(() {
  //                   isPhoneSigningIn = false;
  //                   isDialog = false;
  //                 });
  //                 mySnackBar(context, 'Error: ${e.toString()}');
  //               }
  //             },
  //           );
  //         }
  //       }
  //       await auth.verifyPhoneNumber(
  //         phoneNumber: phoneController.text.toString().trim().contains('+91 ')
  //             ? phoneController.text.toString().trim()
  //             : '+91 ${phoneController.text.toString().trim()}',
  //         verificationCompleted: (_) {
  //           setState(() {
  //             isPhoneSigningIn = false;
  //             isDialog = false;
  //           });
  //         },
  //         verificationFailed: (e) {
  //           setState(() {
  //             isPhoneSigningIn = false;
  //             isDialog = false;
  //           });
  //           if (mounted) {
  //             mySnackBar(context, 'Error: ${e.toString()}');
  //           }
  //         },
  //         codeSent: (
  //           String verificationId,
  //           int? token,
  //         ) {
  //           setState(() {
  //             isPhoneSigningIn = false;
  //             isDialog = false;
  //           });
  //           Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(
  //               builder: (context) => NumberVerifyPage(
  //                 verificationId: verificationId,
  //                 phoneNumber:
  //                     phoneController.text.toString().trim().contains('+91 ')
  //                         ? phoneController.text.toString().trim()
  //                         : '+91 ${phoneController.text.toString().trim()}',
  //                 isLogging: false,
  //                 // fromMainPage: false,
  //               ),
  //             ),
  //             (route) => false,
  //           );
  //         },
  //         codeAutoRetrievalTimeout: (e) {
  //           setState(() {
  //             isPhoneSigningIn = false;
  //             isDialog = false;
  //           });
  //           if (mounted) {
  //             mySnackBar(context, 'Error: ${e.toString()}');
  //           }
  //         },
  //       );
  //     } catch (e) {
  //       setState(() {
  //         isPhoneSigningIn = false;
  //         isDialog = false;
  //       });
  //       if (mounted) {
  //         return mySnackBar(context, 'Error: ${e.toString()}');
  //       }
  //     }
  //   }
  // }

  // REGISTER GOOGLE
  // Future<void> registerGoogle() async {
  //   try {
  //     setState(() {
  //       isGoogleSigningIn = true;
  //       isDialog = true;
  //     });
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser!.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     final vendorCredential = await auth.signInWithCredential(credential);
  //     if (auth.currentUser != null) {
  //       final userExistsSnap = await store
  //           .collection('Users')
  //           .where('Email', isEqualTo: auth.currentUser!.email)
  //           .where('Registration', isEqualTo: 'google')
  //           .get();
  //       if (userExistsSnap.docs.isNotEmpty) {
  //         await auth.signOut();
  //         setState(() {
  //           isGoogleSigningIn = false;
  //           isDialog = false;
  //         });
  //         if (mounted) {
  //           return mySnackBar(
  //             context,
  //             'This account was created in User app, use a different Google Account here',
  //           );
  //         }
  //       }
  //       final vendorExistsSnap = await store
  //           .collection('Business')
  //           .doc('Owners')
  //           .collection('Users')
  //           .where('Email', isEqualTo: auth.currentUser!.email)
  //           .where('Registration', isEqualTo: 'google')
  //           .get();
  //       if (vendorExistsSnap.docs.isNotEmpty &&
  //           (vendorCredential.additionalUserInfo == null
  //               ? true
  //               : !vendorCredential.additionalUserInfo!.isNewUser)) {
  //         if (mounted) {
  //           setState(() {
  //             isGoogleSigningIn = false;
  //             isDialog = false;
  //           });
  //           Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(
  //               builder: (context) => const MainPage(),
  //             ),
  //             (route) => false,
  //           );
  //           return mySnackBar(
  //             context,
  //             'Signed In',
  //           );
  //         }
  //       }
  //       // if (widget.mode == 'vendor') {
  //       await store
  //           .collection('Business')
  //           .doc('Owners')
  //           .collection('Users')
  //           .doc(auth.currentUser!.uid)
  //           .set({
  //         'Email': auth.currentUser!.email,
  //         'Registration': 'google',
  //         'Image': null,
  //         'Name': null,
  //         'Phone Number': null,
  //         'allowCalls': true,
  //         'allowChats': true,
  //         // 'hasReviewed': false,
  //       });
  //       await store
  //           .collection('Business')
  //           .doc('Owners')
  //           .collection('Shops')
  //           .doc(auth.currentUser!.uid)
  //           .set({
  //         'Name': null,
  //         'Registration': 'google',
  //         'GSTNumber': null,
  //         'Description': null,
  //         // 'Industry': null,
  //         'Image': null,
  //         'Type': null,
  //         'MembershipName': null,
  //         'MembershipDuration': null,
  //         'MembershipStartDateTime': null,
  //       });
  //       /*}  else if (widget.mode == 'services') {
  //             // nothing
  //           } else if (widget.mode == 'events') {
  //             // code for events
  //           }*/
  //     } else {
  //       setState(() {
  //         isGoogleSigningIn = false;
  //         isDialog = false;
  //       });
  //       if (mounted) {
  //         return mySnackBar(
  //           context,
  //           'Some error occured\nTry signing with Email / Phone Number',
  //         );
  //       }
  //     }
  //     if (mounted) {
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) {
  //           // if (widget.mode == 'vendor') {
  //           return const OwnerRegisterDetailsPage(
  //             fromMainPage: false,
  //           );
  //           // } else if (widget.mode == 'services') {
  //           //   return const ServicesRegisterDetailsPage();
  //           // } else if (widget.mode == 'events') {
  //           //   return const EventsRegisterDetailsPage1();
  //           // }
  //           // return const MainPage();
  //         }),
  //         (route) => false,
  //       );
  //     }
  //     setState(() {
  //       isGoogleSigningIn = false;
  //       isDialog = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isGoogleSigningIn = false;
  //       isDialog = false;
  //     });
  //     if (mounted) {
  //       return mySnackBar(context, 'Error: ${e.toString()}');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: LoadingIndicator(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Sign In'),
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
                child: Form(
                  key: signInEmailFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyTextFormField(
                        hintText: 'Email',
                        controller: emailController,
                        borderRadius: 16,
                        horizontalPadding: width * 0.066,
                        keyboardType: TextInputType.emailAddress,
                        autoFillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 8),
                      MyTextFormField(
                        hintText: 'Password',
                        controller: passwordController,
                        borderRadius: 16,
                        horizontalPadding: width * 0.066,
                        isPassword: true,
                        autoFillHints: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: 8),
                      MyButton(
                        text: 'SIGN IN',
                        onTap: () async {
                          await registerEmail();
                        },
                        horizontalPadding: width * 0.066,
                      ),
                      // REGISTER HEADTEXT
                      // SizedBox(height: width * 0.35),
                      // const HeadText(
                      //   text: 'REGISTER',
                      // ),
                      // SizedBox(height: width * 0.65),

                      // EMAIL
                      // MyCollapseContainer(
                      //   width: width,
                      //   text: 'Email',
                      //   isExpanded: false,
                      //   children: Padding(
                      //     padding: EdgeInsets.all(width * 0.0225),
                      //     child: Form(
                      //       key: signInEmailFormKey,
                      //       child: Column(
                      //         children: [
                      //           MyTextFormField(
                      //             hintText: 'Email',
                      //             controller: emailController,
                      //             borderRadius: 16,
                      //             horizontalPadding: width * 0.066,
                      //             keyboardType: TextInputType.emailAddress,
                      //             autoFillHints: const [AutofillHints.email],
                      //           ),
                      //           const SizedBox(height: 8),
                      //           MyTextFormField(
                      //             hintText: 'Password',
                      //             controller: passwordController,
                      //             borderRadius: 16,
                      //             horizontalPadding: width * 0.066,
                      //             isPassword: true,
                      //             autoFillHints: const [
                      //               AutofillHints.newPassword
                      //             ],
                      //           ),
                      //           const SizedBox(height: 8),
                      //           MyButton(
                      //             text: 'SIGN IN',
                      //             onTap: () async {
                      //               await registerEmail();
                      //             },
                      //             horizontalPadding: width * 0.066,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),

                      // GOOGLE
                      // GestureDetector(
                      //   onTap: () async {
                      //     await registerGoogle();
                      //   },
                      //   child: Container(
                      //     margin: EdgeInsets.fromLTRB(
                      //       width * 0.035,
                      //       0,
                      //       width * 0.035,
                      //       MediaQuery.of(context).viewInsets.bottom,
                      //     ),
                      //     padding: EdgeInsets.symmetric(
                      //       vertical: width * 0.033,
                      //     ),
                      //     alignment: Alignment.center,
                      //     width: double.infinity,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10),
                      //       color: primary2.withOpacity(0.75),
                      //     ),
                      //     child: isGoogleSigningIn
                      //         ? const LoadingIndicator(
                      //             color: primaryDark,
                      //           )
                      //         : Text(
                      //             'Sign In With GOOGLE',
                      //             overflow: TextOverflow.ellipsis,
                      //             style: TextStyle(
                      //               color: buttonColor,
                      //               fontWeight: FontWeight.w600,
                      //               fontSize: width * 0.045,
                      //             ),
                      //           ),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),

                      // PHONE NUMBER
                      // MyCollapseContainer(
                      //   width: width,
                      //   text: 'Phone Number',
                      //   isExpanded: false,
                      //   children: Padding(
                      //     padding: EdgeInsets.all(width * 0.0225),
                      //     child: Form(
                      //       key: signInPhoneFormKey,
                      //       child: Column(
                      //         children: [
                      //           Padding(
                      //             padding: EdgeInsets.symmetric(
                      //               horizontal: width * 0.07,
                      //             ),
                      //             child: TextFormField(
                      //               autofocus: false,
                      //               controller: phoneController,
                      //               keyboardType: TextInputType.number,
                      //               onTapOutside: (event) =>
                      //                   FocusScope.of(context).unfocus(),
                      //               maxLines: 1,
                      //               minLines: 1,
                      //               decoration: InputDecoration(
                      //                 prefixText: '+91 ',
                      //                 border: OutlineInputBorder(
                      //                   borderRadius: BorderRadius.circular(12),
                      //                   borderSide: BorderSide(
                      //                     color: Colors.cyan.shade700,
                      //                   ),
                      //                 ),
                      //                 hintText: 'Phone Number',
                      //               ),
                      //               validator: (value) {
                      //                 if (value != null) {
                      //                   if (value.isEmpty) {
                      //                     return 'Please enter Phone Number';
                      //                   } else {
                      //                     if (value.length != 10) {
                      //                       return 'Number must be 10 chars long';
                      //                     }
                      //                   }
                      //                 }
                      //                 return null;
                      //               },
                      //             ),
                      //           ),
                      //           const SizedBox(height: 8),
                      //           MyButton(
                      //             text: 'VERIFY',
                      //             onTap: () async {
                      //               await registerPhone();
                      //             },
                      //             horizontalPadding: width * 0.066,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
