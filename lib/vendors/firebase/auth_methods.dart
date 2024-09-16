import 'package:Localsearch/vendors/register/owner_register_details_page.dart';
import 'package:Localsearch/auth/verify/number_verify.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final auth = FirebaseAuth.instance;

  User get user => auth.currentUser!;

  // STATE PERSISTENCE
  Stream<User?> get authState => auth.authStateChanges();

  // EMAIL SIGNUP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      auth.currentUser!.sendEmailVerification();
      mySnackBar(context, 'Email Verification has been sent');
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.message!);
      }
    }
  }

  // EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      if (!auth.currentUser!.emailVerified) {
        if (context.mounted) {
          await sendEmailVerification(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.message!);
      }
    }
  }

  // GOOGLE SIGN IN
  final GoogleSignIn googleSignIn = GoogleSignIn(
    hostedDomain: '',
  );

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      // if (googleAuth.accessToken != null && googleAuth.idToken != null) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // ignore: unused_local_variable
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: ((context) => const OwnerRegisterDetailsPage(
                      fromMainPage: false,
                    )),
              ),
              (route) => false,
            );
          }
        }
      }
      // }
      return userCredential;
    } catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
      return null;
    }
  }

  // PHONE SIGN IN
  Future<void> phoneSignIn(
    BuildContext context,
    String phoneNumber,
    // String mode,
  ) async {
    // TextEditingController codeController = TextEditingController();
    // ADNROID / IOS

    auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (context.mounted) {
            mySnackBar(context, e.toString());
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NumberVerifyPage(
                verificationId: verificationId,
                fromMainPage: false,
                phoneNumber: phoneNumber,
                // mode: mode,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          mySnackBar(context, verificationId.toString());
        });
  }

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.message!);
      }
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount(BuildContext context) async {
    try {
      await auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.message!);
      }
    }
  }
}
