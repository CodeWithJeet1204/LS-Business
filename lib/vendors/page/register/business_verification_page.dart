import 'package:ls_business/vendors/page/register/business_social_media_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

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
  // final gstController = TextEditingController();
  bool isAadhaarValidated = false;
  bool isAadhaarNotValidated = false;
  bool isNext = false;
  bool isDialog = false;

  // DISPOSE
  @override
  void dispose() {
    aadhaarController.dispose();
    // gstController.dispose();
    super.dispose();
  }

  // VERIFY AADHAAR NUMBER
  Future<void> validateAadhaarNumber() async {
    if (verifyKey.currentState!.validate()) {
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
      if (!aadhaarPattern.hasMatch(aadhaarController.text.toString().trim())) {
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

      if (validateVerhoeff(aadhaarController.text.toString().trim())) {
        final vendorSnap = await store
            .collection('Business')
            .doc('Owners')
            .collection('Users')
            .where(
              'AadhaarNumber',
              isEqualTo: aadhaarController.text.toString().trim(),
            )
            .get();

        if (vendorSnap.docs.isEmpty) {
          setState(() {
            isAadhaarValidated = true;
            isAadhaarNotValidated = false;
          });
        } else {
          if (mounted) {
            mySnackBar(
              context,
              'This Aadhaar Number is already registered\nTry using different Aadhaar Number',
            );
          }
          setState(() {
            isAadhaarNotValidated = true;
            isAadhaarValidated = false;
          });
        }
      } else {
        setState(() {
          isAadhaarNotValidated = true;
          isAadhaarValidated = false;
        });
      }
    }
  }

  // NEXT
  Future<void> next() async {
    if (verifyKey.currentState!.validate()) {
      if (isAadhaarValidated) {
        setState(() {
          isNext = true;
          isDialog = true;
        });

        try {
          // if (gstController.text.isNotEmpty) {
          //   final gstSnap = await store
          //       .collection('Business')
          //       .doc('Owners')
          //       .collection('Shops')
          //       .where(
          //         'GSTNumber',
          //         isEqualTo: gstController.text.toString().trim(),
          //       )
          //       .get();

          //   if (gstSnap.docs.isNotEmpty) {
          //     if (mounted) {
          //       return mySnackBar(
          //         context,
          //         'This GST Number is already registered\nRecheck GST Number',
          //       );
          //     }
          //   }
          // }

          // await store
          //     .collection('Business')
          //     .doc('Owners')
          //     .collection('Shops')
          //     .doc(auth.currentUser!.uid)
          //     .update({
          //   'GSTNumber': gstController.text.toString().trim(),
          // });

          await store
              .collection('Business')
              .doc('Owners')
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .update({
            'AadhaarNumber': aadhaarController.text.toString().trim(),
          });

          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BusinessSocialMediaPage(
                  isChanging: false,
                  fromMainPage: false,
                ),
              ),
            );
          }
          setState(() {
            isNext = false;
            isDialog = false;
          });
        } catch (e) {
          setState(() {
            isNext = false;
            isDialog = false;
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
    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: LoadingIndicator(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Verification'),
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
                          const Center(
                            child: Text(
                              'Aadhaar & GST Number Cannot Be Changed Later',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // AADHAAR
                          TextFormField(
                            controller: aadhaarController,
                            minLines: 1,
                            maxLines: 1,
                            maxLength: 12,
                            keyboardType: TextInputType.number,
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

                          SizedBox(height: 12),

                          // VALIDATE
                          // isAadhaarValidated
                          //     ? const SizedBox(
                          //         height: 80,
                          //         child: Center(
                          //           child: Text(
                          //             'Aadhaar Validated',
                          //             textAlign: TextAlign.center,
                          //           ),
                          //         ),
                          //       )
                          //     : MyButton(
                          //         onTap: () async {
                          //           await validateAadhaarNumber();
                          //         },
                          //         text: isAadhaarNotValidated
                          //             ? 'TRY AGAIN'
                          //             : 'VALIDATE AADHAAR',
                          //       ),

                          // const Divider(),

                          // GST NUMBER
                          // TextFormField(
                          //   controller: gstController,
                          //   minLines: 1,
                          //   maxLines: 1,
                          //   maxLength: 15,
                          //   onTapOutside: (event) =>
                          //       FocusScope.of(context).unfocus(),
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //       borderSide: BorderSide(
                          //         color: Colors.cyan.shade700,
                          //       ),
                          //     ),
                          //     hintText: 'GST Number',
                          //   ),
                          //   validator: (value) {
                          //     if (value != null) {
                          //       if (value.isNotEmpty) {
                          //         if (value.length != 15) {
                          //           return 'GST Number should be exactly 15 chars long';
                          //         }
                          //       } else {
                          //         return null;
                          //       }
                          //     }
                          //     return null;
                          //   },
                          // ),

                          // const SizedBox(height: 36),

                          // NEXT
                          MyButton(
                            onTap: () async {
                              await validateAadhaarNumber();
                              if (isAadhaarValidated &&
                                  !isAadhaarNotValidated) {
                                await next();
                              } else {
                                mySnackBar(
                                  context,
                                  'Incorrect Aadhaar Number, check again',
                                );
                              }
                            },
                            text: 'NEXT',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
