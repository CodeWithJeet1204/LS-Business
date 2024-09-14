import 'package:Localsearch/auth/login_page.dart';
import 'package:Localsearch/auth/register_method_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/vendors/utils/is_payed.dart';
import 'package:Localsearch/vendors/utils/size.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:flutter/material.dart';

class RegisterPayPage extends StatefulWidget {
  const RegisterPayPage({
    super.key,
    // required this.mode,
  });

  // final String mode;

  @override
  State<RegisterPayPage> createState() => _RegisterPayPageState();
}

class _RegisterPayPageState extends State<RegisterPayPage> {
  bool isPaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Pay'),
      ),
      body: SafeArea(
        child: MediaQuery.of(context).size.width < screenSize
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Expanded(
                  //   flex: 3,
                  //   child: Container(),
                  // ),

                  // // PAY HEADTEXT
                  // const HeadText(
                  //   text: 'PAY',
                  // ),
                  Expanded(
                    flex: 5,
                    child: Container(),
                  ),

                  // CONTINUE TEXT
                  const Text(
                    'To continue using the app, please pay Rs. 100',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PAY BUTTON
                  MyButton(
                    text: 'Pay',
                    onTap: () async {
                      try {
                        setState(() {
                          isPaying = true;
                        });
                        // Paying Methods
                        await saveIsPayed(true);
                        setState(() {
                          isPaying = false;
                        });

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) => RegisterMethodPage()),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isPaying = false;
                          if (mounted) {
                            if (mounted) {
                              mySnackBar(context, e.toString());
                            }
                          }
                        });
                      }
                    },
                    horizontalPadding:
                        MediaQuery.of(context).size.width * 0.066,
                    isLoading: isPaying,
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(),
                  ),

                  // ALREADY HAVE AN ACCOUNT ? TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        overflow: TextOverflow.ellipsis,
                      ),
                      MyTextButton(
                        onPressed: () {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => const LoginPage()),
                              ),
                            );
                          }
                        },
                        text: 'LOGIN',
                        textColor: buttonColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.66,
                    // child: const HeadText(
                    //   text: 'PAY',
                    // ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.33,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // CONTINUE TEXT
                        Text(
                          'To continue using the app, please pay Rs. 100',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: MediaQuery.of(context).size.width * 0.015,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.025,
                        ),

                        // PAY BUTTON
                        MyButton(
                          text: 'Pay',
                          onTap: () async {
                            try {
                              setState(() {
                                isPaying = true;
                              });
                              // Paying Methods
                              await saveIsPayed(true);
                              setState(() {
                                isPaying = false;
                              });
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: ((context) =>
                                        RegisterMethodPage()),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                isPaying = false;
                                if (mounted) {
                                  if (mounted) {
                                    mySnackBar(context, e.toString());
                                  }
                                }
                              });
                            }
                          },
                          horizontalPadding:
                              MediaQuery.of(context).size.width * 0.05,
                          isLoading: isPaying,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
