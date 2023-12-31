import 'package:find_easy/page/register/verify/number_verify.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth _auth;
  AuthMethods(this._auth);

  User get user => _auth.currentUser!;

  // STATE PERSISTENCE
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();

  // EMAIL SIGNUP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      mySnackBar(context, e.message!);
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      mySnackBar(context, "Email Verification has been sent");
    } on FirebaseAuthException catch (e) {
      mySnackBar(context, e.message!);
    }
  }

  // EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!_auth.currentUser!.emailVerified) {
        await sendEmailVerification(context);
      }
    } on FirebaseAuthException catch (e) {
      mySnackBar(context, e.message!);
    }
  }

  // GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Bypass any existing sessions or cached credentials
      await GoogleSignIn()
          .signOut(); // Explicitly sign out to ensure a fresh sign-in

      // Prompt account picker directly
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication? googleAuth =
            await googleUser.authentication;

        if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
          // ignore: unused_local_variable
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );
          // ... (rest of your sign-in logic, including registration handling)
        }
      }
      print(googleUser!.displayName);
      print(googleUser.email);
      print(googleUser.photoUrl);
    } on FirebaseAuthException catch (e) {
      mySnackBar(context, e.message!);
    }
  }

  // final GoogleSignIn googleSignIn = GoogleSignIn(
  //   hostedDomain: "", // Prevent automatic sign-in
  // );

  // Future<void> signInWithGoogle(BuildContext context) async {
  //   try {
  //     final GoogleSignInAccount? googleUser =
  //         await googleSignIn.signInSilently();
  //     if (googleUser == null) {
  //       await googleSignIn.signIn(); // Prompt account picker
  //       final GoogleSignInAuthentication? googleAuth =
  //           await googleUser?.authentication;
  //       if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
  //         final credential = GoogleAuthProvider.credential(
  //           accessToken: googleAuth?.accessToken,
  //           idToken: googleAuth?.idToken,
  //         );
  //         // ...
  //       }
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     mySnackBar(context, e.message!);
  //   }
  // }

  // PHONE SIGN IN
  Future<void> phoneSignIn(BuildContext context, String phoneNumber) async {
    // TextEditingController codeController = TextEditingController();
    // ADNROID / IOS

    _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (_) {
          // setState(() {
          //   isPhoneRegistering = false;
          // });
        },
        verificationFailed: (e) {
          mySnackBar(context, e.toString());
        },
        codeSent: (String verificationId, int? token) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NumberVerifyPage(
                verificationId: verificationId,
                isLogging: false,
              ),
            ),
          );
          // setState(() {
          //   isPhoneRegistering = false;
          // });
        },
        codeAutoRetrievalTimeout: (e) {
          mySnackBar(context, e.toString());
          // isPhoneRegistering = false;
        });
  }

  // ANONYMOUS SIGN IN
  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      mySnackBar(context, e.message!);
    }
  }

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      mySnackBar(context, e.message!);
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      mySnackBar(context, e.message!);
    }
  }
}
