import 'package:Localsearch/vendors/page/register/business_social_media_page.dart';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/snack_bar.dart';

class BusinessVerificationPage extends StatefulWidget {
  const BusinessVerificationPage({
    super.key,
    this.name,
  });

  final String? name;

  @override
  State<BusinessVerificationPage> createState() =>
      _BusinessVerificationPageState();
}

class _BusinessVerificationPageState extends State<BusinessVerificationPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final verifyKey = GlobalKey<FormState>();
  final aadhaarController = TextEditingController();
  final gstController = TextEditingController();
  bool isAadhaarValidated = false;
  bool isAadhaarNotValidated = false;
  bool isNext = false;

  // DISPOSE
  @override
  void dispose() {
    gstController.dispose();
    super.dispose();
  }

  // VERIFY AADHAAR NUMBER
  void validateAadhaarNumber(String aadhaarNumber) {
    final List<List<int>> d = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
      [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
      [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
      [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
      [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
      [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
      [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
      [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    ];

    final List<List<int>> p = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
      [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
      [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
      [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
      [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
      [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
      [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
    ];

    final RegExp aadhaarPattern = RegExp(r'^\d{12}$');
    if (!aadhaarPattern.hasMatch(aadhaarNumber)) {
      return;
    }

    List<int> stringToReversedIntArray(String num) {
      return num.split('').map(int.parse).toList().reversed.toList();
    }

    bool validateVerhoeff(String num) {
      int c = 0;
      List<int> myArray = stringToReversedIntArray(num);

      for (int i = 0; i < myArray.length; i++) {
        c = d[c][p[i % 8][myArray[i]]];
      }

      return c == 0;
    }

    if (validateVerhoeff(aadhaarNumber)) {
      setState(() {
        isAadhaarValidated = true;
        isAadhaarNotValidated = false;
      });
    } else {
      setState(() {
        isAadhaarNotValidated = true;
        isAadhaarValidated = false;
      });
    }
  }

  // NEXT
  Future<void> next() async {
    if (verifyKey.currentState!.validate()) {
      if (isAadhaarValidated) {
        setState(() {
          isNext = true;
        });
        try {
          await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(auth.currentUser!.uid)
              .update({
            'GSTNumber': gstController.text,
            'AadhaarNumber': aadhaarController.text,
          });

          if (mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const BusinessSocialMediaPage(
                      isChanging: false,
                      fromMainPage: false,
                    )),
              ),
            );
          }
          setState(() {
            isNext = false;
          });
        } catch (e) {
          setState(() {
            isNext = false;
          });
          if (mounted) {
            mySnackBar(context, e.toString());
          }
        }
      } else {
        return mySnackBar(context, 'Please Validate Your Aadhaar Number');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(width * 0.0225),
                child: Form(
                  key: verifyKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CANNOT BE CHANGED
                      Text(
                        'Aadhaar & GST Number Cannot Be Changed Later',
                        textAlign: TextAlign.center,
                      ),

                      // AADHAAR
                      isAadhaarValidated
                          ? Container()
                          : TextFormField(
                              controller: aadhaarController,
                              minLines: 1,
                              maxLines: 1,
                              maxLength: 12,
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.cyan.shade700,
                                  ),
                                ),
                                hintText: 'Aadhaar Number*',
                              ),
                              validator: (value) {
                                if (value != null) {
                                  if (value.isNotEmpty) {
                                    if (value.length != 12) {
                                      return 'Aadhaar Number should be exactly 12 chars long';
                                    }
                                  } else {
                                    return 'Pls enter Aadhaar Number';
                                  }
                                }
                                return null;
                              },
                            ),

                      // VALIDATE
                      MyButton(
                        onTap: isAadhaarValidated
                            ? () {}
                            : () {
                                validateAadhaarNumber(aadhaarController.text);
                              },
                        text: !isAadhaarValidated
                            ? isAadhaarNotValidated
                                ? 'NOT VALID TRY AGAIN'
                                : 'VALIDATE AADHAAR'
                            : 'AADHAAR VALIDATED',
                        horizontalPadding: 0,
                      ),

                      Divider(),

                      // GST NUMBER
                      TextFormField(
                        controller: gstController,
                        minLines: 1,
                        maxLines: 1,
                        maxLength: 15,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.cyan.shade700,
                            ),
                          ),
                          hintText: 'GST Number',
                        ),
                        validator: (value) {
                          if (value != null) {
                            if (value.isNotEmpty) {
                              if (value.length != 15) {
                                return 'GST Number should be exactly 15 chars long';
                              }
                            } else {
                              return null;
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // NEXT
                      MyButton(
                        onTap: () async {
                          await showLoadingDialog(
                            context,
                            () async {
                              await next();
                            },
                          );
                        },
                        text: 'NEXT',
                        horizontalPadding: 0,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
