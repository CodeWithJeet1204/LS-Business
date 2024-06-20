// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/events/events_main_page.dart';
import 'package:localy/select_mode_page.dart';
import 'package:localy/services/main/services_main_page.dart';
import 'package:localy/vendors/firebase/auth_methods.dart';
import 'package:localy/vendors/page/main/main_page.dart';
import 'package:localy/auth/register_pay.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/collapse_container.dart';
import 'package:localy/widgets/head_text.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:localy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.mode,
  });

  final String mode;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final GlobalKey<FormState> emailLoginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> numberLoginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String phoneText = 'VERIFY';
  String googleText = 'Sign in with GOOGLE';
  bool isGoogleLogging = false;
  bool isEmailLogging = false;
  bool isPhoneLogging = false;
  String? mode;

  // INIT STATE
  @override
  void initState() {
    mode = widget.mode;
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // LOGIN EMAIL
  Future<void> loginEmail() async {
    if (emailLoginFormKey.currentState!.validate()) {
      try {
        setState(() {
          isEmailLogging = true;
        });
        UserCredential? user = await auth.signInWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString(),
        );

        if (user != null) {
          final userExistsSnap =
              await store.collection('Users').doc(auth.currentUser!.uid).get();

          if (userExistsSnap.exists) {
            await auth.signOut();
            if (mounted) {
              return mySnackBar(
                context,
                'This account was created in User app, use a different email here',
              );
            }
          } else {
            if (mode == 'vendor') {
              final vendorSnap = await store
                  .collection('Business')
                  .doc('Owners')
                  .collection('Shops')
                  .doc(auth.currentUser!.uid)
                  .get();

              if (!vendorSnap.exists) {
                await auth.signOut();
                setState(() {
                  isEmailLogging = false;
                });
                if (mounted) {
                  return mySnackBar(
                    context,
                    'This account was created for Services ? Events',
                  );
                }
                return;
              }
            } else if (mode == 'services') {
              final serviceSnap = await store
                  .collection('Services')
                  .doc(auth.currentUser!.uid)
                  .get();

              if (!serviceSnap.exists) {
                await auth.signOut();
                setState(() {
                  isEmailLogging = false;
                });
                if (mounted) {
                  return mySnackBar(
                    context,
                    'This account was created for Vendor / Events',
                  );
                }
              }
              return;
            } else if (mode == 'events') {
              final serviceSnap = await store
                  .collection('Organizers')
                  .doc(auth.currentUser!.uid)
                  .get();

              if (!serviceSnap.exists) {
                await auth.signOut();
                setState(() {
                  isEmailLogging = false;
                });
                if (mounted) {
                  return mySnackBar(
                    context,
                    'This account was created for Vendor / Services',
                  );
                }
              }
              return;
            }
            if (mounted) {
              mySnackBar(
                context,
                'Signed In',
              );
            }
            setState(() {
              isEmailLogging = false;
            });
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: ((context) {
                    if (mode == 'vendor') {
                      return const MainPage();
                    } else if (mode == 'services') {
                      return const ServicesMainPage();
                    } else if (mode == 'events') {
                      return const EventsMainPage();
                    } else {
                      return const MainPage();
                    }
                  }),
                ),
                (route) => false,
              );
            }
          }
        } else {
          if (mounted) {
            return mySnackBar(context, 'Some error occurred');
          }
        }
      } catch (e) {
        setState(() {
          isEmailLogging = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  // LOGIN PHONE
  Future<void> loginPhone() async {
    if (numberLoginFormKey.currentState!.validate()) {
      final phoneSnap = await store
          .collection('Business')
          .doc('Owners')
          .collection('Users')
          .where('Phone Number', isEqualTo: phoneController.text)
          .get();

      if (phoneSnap.docs.isNotEmpty) {
        setState(() {
          isPhoneLogging = true;
        });
        try {
          if (mode == 'vendor') {
            final vendorSnap = await store
                .collection('Business')
                .doc('Owners')
                .collection('Shops')
                .doc(auth.currentUser!.uid)
                .get();

            if (!vendorSnap.exists) {
              await auth.signOut();
              setState(() {
                isPhoneLogging = false;
              });
              if (mounted) {
                return mySnackBar(
                  context,
                  'This account was created for Services ? Events',
                );
              }
              return;
            }
          } else if (mode == 'services') {
            final serviceSnap = await store
                .collection('Services')
                .doc(auth.currentUser!.uid)
                .get();

            if (!serviceSnap.exists) {
              await auth.signOut();
              setState(() {
                isPhoneLogging = false;
              });
              if (mounted) {
                return mySnackBar(
                  context,
                  'This account was created for Vendor / Events',
                );
              }
            }
            return;
          } else if (mode == 'events') {
            final serviceSnap = await store
                .collection('Organizers')
                .doc(auth.currentUser!.uid)
                .get();

            if (!serviceSnap.exists) {
              await auth.signOut();
              setState(() {
                isPhoneLogging = false;
              });
              if (mounted) {
                return mySnackBar(
                  context,
                  'This account was created for Vendor / Services',
                );
              }
            }
            return;
          }
          await auth.verifyPhoneNumber(
              phoneNumber: '+91 ${phoneController.text}',
              timeout: const Duration(seconds: 120),
              verificationCompleted: (PhoneAuthCredential credential) async {
                await auth.signInWithCredential(credential);
                setState(() {
                  isPhoneLogging = false;
                });
              },
              verificationFailed: (e) {
                if (mounted) {
                  mySnackBar(context, e.toString());
                }
                setState(() {
                  isPhoneLogging = false;
                });
              },
              codeSent: (String verificationId, int? token) {
                setState(() {
                  isPhoneLogging = false;
                });

                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    if (mode == 'vendor') {
                      return const MainPage();
                    } else if (mode == 'services') {
                      return const ServicesMainPage();
                    } else if (mode == 'events') {
                      return const EventsMainPage();
                    } else {
                      mySnackBar(context, 'Some error occured, try again');
                      return const SelectModePage();
                    }
                  }),
                );
              },
              codeAutoRetrievalTimeout: (e) {
                if (mounted) {
                  mySnackBar(context, e.toString());
                }
                setState(() {
                  isPhoneLogging = false;
                });
              });
        } catch (e) {
          setState(() {
            isPhoneLogging = false;
          });
          if (mounted) {
            mySnackBar(context, e.toString());
          }
        }
      } else {
        setState(() {
          isPhoneLogging = false;
        });
        if (mounted) {
          mySnackBar(context, 'You have not registered with this phone number');
        }
      }
    }
  }

  // LOGIN GOOGLE
  Future<void> loginGoogle() async {
    setState(() {
      isGoogleLogging = true;
    });
    try {
      await AuthMethods().signInWithGoogle(context);
      if (auth.currentUser != null) {
        final userExistsSnap =
            await store.collection('Users').doc(auth.currentUser!.uid).get();

        if (userExistsSnap.exists) {
          await auth.signOut();
          if (mounted) {
            return mySnackBar(
              context,
              'This account was created in User app, use a different email here',
            );
          }
        } else {
          if (mode == 'vendor') {
            final vendorSnap = await store
                .collection('Business')
                .doc('Owners')
                .collection('Shops')
                .doc(auth.currentUser!.uid)
                .get();

            if (!vendorSnap.exists) {
              await auth.signOut();
              setState(() {
                isGoogleLogging = false;
              });
              if (mounted) {
                return mySnackBar(
                  context,
                  'This account was created for Services ? Events',
                );
              }
              return;
            }
          } else if (mode == 'services') {
            final serviceSnap = await store
                .collection('Services')
                .doc(auth.currentUser!.uid)
                .get();

            if (!serviceSnap.exists) {
              await auth.signOut();
              setState(() {
                isGoogleLogging = false;
              });
              if (mounted) {
                return mySnackBar(
                  context,
                  'This account was created for Vendor / Events',
                );
              }
            }
            return;
          } else if (mode == 'events') {
            final serviceSnap = await store
                .collection('Organizers')
                .doc(auth.currentUser!.uid)
                .get();

            if (!serviceSnap.exists) {
              await auth.signOut();
              setState(() {
                isGoogleLogging = false;
              });
              if (mounted) {
                return mySnackBar(
                  context,
                  'This account was created for Vendor / Services',
                );
              }
            }
            return;
          }
          setState(() {
            isGoogleLogging = false;
          });

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: ((context) {
                  if (mode == 'vendor') {
                    return const MainPage();
                  } else if (mode == 'services') {
                    return const ServicesMainPage();
                  } else if (mode == 'events') {
                    return const EventsMainPage();
                  } else {
                    return const MainPage();
                  }
                }),
              ),
              (route) => false,
            );
          }
        }
      } else {
        setState(() {
          isGoogleLogging = false;
        });
        if (mounted) {
          mySnackBar(context, 'Some error occured');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isGoogleLogging = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: /* width < screenSize
            ? */
              Padding(
        padding: EdgeInsets.all(
          width * 0.006125,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: width * 0.033),
              Align(
                alignment: Alignment.centerLeft,
                child: MyTextButton(
                  onPressed: () async {
                    await showMenu(
                      context: context,
                      position: RelativeRect.fromSize(
                        Rect.largest,
                        Size(
                          width * 0.25,
                          100,
                        ),
                      ),
                      elevation: 0,
                      color: primary2,
                      items: [
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              mode = 'vendor';
                            });
                          },
                          child: Text('Vendor'),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              mode = 'events';
                            });
                          },
                          child: Text('Events'),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              mode = 'services';
                            });
                          },
                          child: Text('Services'),
                        ),
                      ],
                    );
                  },
                  text: '${mode} ↓',
                  textColor: primaryDark2,
                ),
              ),
              SizedBox(height: width * 0.135),
              const HeadText(
                text: 'LOGIN',
              ),
              SizedBox(height: width * 0.3),
              MyCollapseContainer(
                width: width,
                text: 'Email',
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
                          autoFillHints: const [AutofillHints.password],
                        ),
                        const SizedBox(height: 8),
                        MyButton(
                          text: 'LOGIN',
                          onTap: () async {
                            await loginEmail();
                          },
                          horizontalPadding: width * 0.066,
                          isLoading: isEmailLogging,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // PHONE NUMBER
              MyCollapseContainer(
                width: width,
                text: 'Phone Number',
                children: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.0125,
                    vertical: width * 0.025,
                  ),
                  child: Form(
                    key: numberLoginFormKey,
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
                            await loginPhone();
                          },
                          horizontalPadding: width * 0.066,
                          isLoading: isPhoneLogging,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: width * 0.033),

              // SIGN IN WITH GOOGLE
              GestureDetector(
                onTap: () async {
                  await loginGoogle();
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
                          overflow: TextOverflow.ellipsis,
                          googleText,
                          style: TextStyle(
                            color: buttonColor,
                            fontWeight: FontWeight.w600,
                            fontSize: width * 0.05,
                          ),
                        ),
                ),
              ),
              SizedBox(height: width * 0.33),

              // DONT HAVE AN ACCOUNT ? TEXT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    overflow: TextOverflow.ellipsis,
                    'Don\'t have an account?',
                  ),
                  MyTextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: ((context) => RegisterPayPage(
                                mode: mode!,
                              )),
                        ),
                      );
                    },
                    text: 'REGISTER',
                    textColor: buttonColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          // : Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Container(
          //         alignment: Alignment.center,
          //         width: width * 0.66,
          //         child: const HeadText(
          //           text: 'LOGIN',
          //         ),
          //       ),
          //       Container(
          //         width: width * 0.33,
          //         alignment: Alignment.center,
          //         child: SingleChildScrollView(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Column(
          //                 children: [
          //                   // EMAIL
          //                   MyCollapseContainer(
          //                     width: width,
          //                     text: 'Email',
          //                     children: Form(
          //                       key: emailLoginFormKey,
          //                       child: Padding(
          //                         padding: EdgeInsets.symmetric(
          //                           horizontal: width < screenSize
          //                               ? width * 0.0125
          //                               : width * 0.0,
          //                           vertical: width * 0.025,
          //                         ),
          //                         child: Column(
          //                           children: [
          //                             MyTextFormField(
          //                               hintText: 'Email',
          //                               controller: emailController,
          //                               borderRadius: 16,
          //                               horizontalPadding: width < screenSize
          //                                   ? width * 0.066
          //                                   : width * 0.05,
          //                               keyboardType:
          //                                   TextInputType.emailAddress,
          //                               autoFillHints: const [
          //                                 AutofillHints.email
          //                               ],
          //                             ),
          //                             const SizedBox(height: 8),
          //                             MyTextFormField(
          //                               hintText: 'Password',
          //                               controller: passwordController,
          //                               borderRadius: 16,
          //                               horizontalPadding: width < screenSize
          //                                   ? width * 0.066
          //                                   : width * 0.05,
          //                               isPassword: true,
          //                               autoFillHints: const [
          //                                 AutofillHints.password
          //                               ],
          //                             ),
          //                             const SizedBox(height: 8),
          //                             MyButton(
          //                               text: 'LOGIN',
          //                               onTap: () async {
          //                                 await loginWithEmail();
          //                               },
          //                               horizontalPadding: width < screenSize
          //                                   ? width * 0.066
          //                                   : width * 0.05,
          //                               isLoading: isEmailLogging,
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ),

          //                   // PHONE NUMBER
          //                   MyCollapseContainer(
          //                     width: width,
          //                     text: 'Phone Number',
          //                     children: Padding(
          //                       padding: EdgeInsets.symmetric(
          //                         horizontal: width < screenSize
          //                             ? width * 0.0125
          //                             : width * 0.0,
          //                         vertical: width * 0.025,
          //                       ),
          //                       child: Form(
          //                         key: numberLoginFormKey,
          //                         child: Column(
          //                           children: [
          //                             MyTextFormField(
          //                               hintText: 'Phone Number',
          //                               controller: phoneController,
          //                               borderRadius: 16,
          //                               horizontalPadding: width < screenSize
          //                                   ? width * 0.066
          //                                   : width * 0.05,
          //                               keyboardType: TextInputType.number,
          //                               autoFillHints: const [
          //                                 AutofillHints.telephoneNumberDevice
          //                               ],
          //                             ),
          //                             const SizedBox(height: 8),
          //                             MyButton(
          //                               text: phoneText,
          //                               onTap: () async {
          //                                 if (numberLoginFormKey.currentState!
          //                                     .validate()) {
          //                                   try {
          //                                     setState(() {
          //                                       isPhoneLogging = true;
          //                                     });
          //                                     // Register with Phone
          //                                     if (phoneController.text
          //                                         .contains('+91')) {
          //                                       await authMethods.phoneSignIn(
          //                                         context,
          //                                         ' ${phoneController.text}',
          //                                         mode,
          //                                       );
          //                                     } else if (phoneController.text
          //                                         .contains('+91 ')) {
          //                                       await authMethods.phoneSignIn(
          //                                         context,
          //                                         phoneController.text,
          //                                         mode,
          //                                       );
          //                                     } else {
          //                                       setState(() {
          //                                         isPhoneLogging = true;
          //                                       });
          //                                       await auth.verifyPhoneNumber(
          //                                           phoneNumber:
          //                                               '+91 ${phoneController.text}',
          //                                           verificationCompleted:
          //                                               (_) {
          //                                             setState(() {
          //                                               isPhoneLogging =
          //                                                   false;
          //                                             });
          //                                           },
          //                                           verificationFailed: (e) {
          //                                             if (mounted) {
          //                                               mySnackBar(context,
          //                                                   e.toString());
          //                                             }
          //                                             setState(() {
          //                                               isPhoneLogging =
          //                                                   false;
          //                                             });
          //                                           },
          //                                           codeSent: (String
          //                                                   verificationId,
          //                                               int? token) {
          //                                             Navigator.of(context)
          //                                                 .pop();
          //                                             Navigator.of(context)
          //                                                 .push(
          //                                               MaterialPageRoute(
          //                                                 builder: (context) =>
          //                                                     NumberVerifyPage(
          //                                                   verificationId:
          //                                                       verificationId,
          //                                                   isLogging: true,
          //                                                   phoneNumber:
          //                                                       phoneController
          //                                                           .text
          //                                                           .toString(),
          //                                                   mode: mode,
          //                                                 ),
          //                                               ),
          //                                             );
          //                                             setState(() {
          //                                               isPhoneLogging =
          //                                                   false;
          //                                             });
          //                                           },
          //                                           codeAutoRetrievalTimeout:
          //                                               (e) {
          //                                             if (mounted) {
          //                                               mySnackBar(context,
          //                                                   e.toString());
          //                                             }
          //                                             isPhoneLogging = false;
          //                                           });
          //                                     }
          //                                     setState(() {
          //                                       isPhoneLogging = false;
          //                                     });
          //                                   } catch (e) {
          //                                     setState(() {
          //                                       isPhoneLogging = false;
          //                                     });
          //                                     if (context.mounted) {
          //                                       mySnackBar(
          //                                         context,
          //                                         e.toString(),
          //                                       );
          //                                     }
          //                                   }
          //                                 }
          //                               },
          //                               horizontalPadding: width < screenSize
          //                                   ? width * 0.066
          //                                   : width * 0.05,
          //                               isLoading: isPhoneLogging,
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                   const SizedBox(height: 16),

          //                   // SIGN IN WITH GOOGLE
          //                 GestureDetector(
          //                     onTap: () async {
          //                       try {
          //                         setState(() {
          //                           isGoogleLogging = true;
          //                         });
          //                         // Sign In With Google
          //                         await AuthMethods()
          //                             .signInWithGoogle(context);
          //                         if (auth.currentUser !=
          //                             null) {
          //                           setState(() {});
          //                         } else {
          //                           if (mounted) {
          //                             mySnackBar(
          //                                 context, 'Some error occured!');
          //                           }
          //                         }
          //                       } on FirebaseAuthException catch (e) {
          //                         if (mounted) {
          //                           mySnackBar(context, e.toString());
          //                         }
          //                       }
          //                     },
          //                     child: Container(
          //                       margin: EdgeInsets.symmetric(
          //                         horizontal: width < screenSize
          //                             ? width * 0.035
          //                             : width * 0.0275,
          //                       ),
          //                       padding: EdgeInsets.symmetric(
          //                         vertical: width < screenSize
          //                             ? width * 0.033
          //                             : width * 0.0125,
          //                       ),
          //                       alignment: Alignment.center,
          //                       width: double.infinity,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(10),
          //                         color: primary2.withOpacity(0.75),
          //                       ),
          //                       child: isGoogleLogging
          //                           ? const Center(
          //                               child: CircularProgressIndicator(
          //                                 color: primaryDark,
          //                               ),
          //                             )
          //                           : Text(
          //                               googleText,
          //                               style: TextStyle(
          //                                 color: buttonColor,
          //                                 fontWeight: FontWeight.w600,
          //                                 fontSize: width < screenSize
          //                                     ? width * 0.05
          //                                     : width * 0.025,
          //                               ),
          //                             ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               const SizedBox(height: 120),

          //               // DONT HAVE AN ACCOUNT ? TEXT
          //               Padding(
          //                 padding: EdgeInsets.only(
          //                   bottom: MediaQuery.of(context).viewInsets.bottom,
          //                 ),
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   children: [
          //                     const Text(
          //                       'Don't have an account?',
          //                       overflow: TextOverflow.ellipsis,
          //                     ),
          //                     MyTextButton(
          //                       onPressed: () {
          //                         Navigator.of(context).pop();
          //                         Navigator.of(context).push(
          //                           MaterialPageRoute(
          //                             builder: ((context) => RegisterPayPage(
          //                                   mode: mode,
          //                                 )),
          //                           ),
          //                         );
          //                       },
          //                       text: 'REGISTER',
          //                       textColor: buttonColor,
          //                       fontSize: width * 0.0125,
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          ),
    );
  }
}
