import 'package:ls_business/widgets/show_loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';

class LoginEmailAfterForgetPassword extends StatefulWidget {
  const LoginEmailAfterForgetPassword({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<LoginEmailAfterForgetPassword> createState() =>
      _LoginEmailAfterForgetPasswordState();
}

class _LoginEmailAfterForgetPasswordState
    extends State<LoginEmailAfterForgetPassword> {
  final auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isEmailLogging = false;

  // LOGIN WITH EMAIL
  Future<void> loginWithEmail() async {
    if (passwordController.text.length > 6) {
      try {
        setState(() {
          isEmailLogging = true;
        });
        await auth.signInWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString(),
        );
        if (mounted) {
          mySnackBar(context, 'Signed In');
        }
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: ((context) => const MainPage()),
            ),
            (route) => false,
          );
        }
        setState(() {
          isEmailLogging = false;
        });
      } catch (e) {
        setState(() {
          isEmailLogging = false;
        });
        if (mounted) {
          mySnackBar(
            context,
            e.toString(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Login'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            width * 0.0125,
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // SizedBox(height: width * 0.35),
                  // const HeadText(
                  //   text: 'LOGIN WITH EMAIL',
                  // ),
                  SizedBox(height: width * 0.65),
                  MyTextFormField(
                    hintText: 'Email*',
                    controller: emailController,
                    borderRadius: 16,
                    horizontalPadding: width * 0.066,
                    keyboardType: TextInputType.emailAddress,
                    autoFillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 8),
                  MyTextFormField(
                    hintText: 'Password*',
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
                      await showLoadingDialog(
                        context,
                        () async {
                          await loginWithEmail();
                        },
                      );
                    },
                    horizontalPadding: width * 0.066,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
