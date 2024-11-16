import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/vendors/page/register/select_shop_types_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class BusinessSocialMediaPage extends StatefulWidget {
  const BusinessSocialMediaPage({
    super.key,
    required this.isChanging,
    this.instagram,
    this.facebook,
    this.website,
    required this.fromMainPage,
  });

  final bool isChanging;
  final bool fromMainPage;
  final String? instagram;
  final String? facebook;
  final String? website;

  @override
  State<BusinessSocialMediaPage> createState() =>
      _BusinessSocialMediaPageState();
}

class _BusinessSocialMediaPageState extends State<BusinessSocialMediaPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final instaController = TextEditingController();
  final facebookController = TextEditingController();
  final websiteController = TextEditingController();
  bool isNext = false;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    setState(() {
      if (widget.instagram != null) {
        instaController.text = widget.instagram!.toString().trim();
      }
      if (widget.facebook != null) {
        facebookController.text = widget.facebook!.toString().trim();
      }
      if (widget.website != null) {
        websiteController.text = widget.website!.toString().trim();
      }
    });
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    instaController.dispose();
    facebookController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  // NEXT
  Future<void> next() async {
    try {
      setState(() {
        isNext = true;
        isDialog = true;
      });

      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'Instagram': instaController.text.toString().trim(),
        'Facebook': facebookController.text.toString().trim(),
        'Website': websiteController.text.toString().trim(),
      });

      setState(() {
        isNext = false;
        isDialog = false;
      });
      if (mounted) {
        if (widget.fromMainPage) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
            (route) => false,
          );
        } else if (widget.isChanging) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SelectShopTypesPage(
                isEditing: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isNext = false;
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // SKIP
  Future<void> skip() async {
    try {
      setState(() {
        isNext = true;
        isDialog = true;
      });

      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'Instagram': '',
        'Facebook': '',
        'Website': '',
      });

      setState(() {
        isNext = false;
        isDialog = false;
      });
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SelectShopTypesPage(
              isEditing: false,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isNext = false;
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
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
        blur: 0.5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Social Media Info'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // INSTAGRAM
                        MyTextFormField(
                          hintText: 'Instagram (Link)',
                          controller: instaController,
                          borderRadius: 12,
                        ),

                        const SizedBox(height: 12),

                        // FACEBOOK
                        MyTextFormField(
                          hintText: 'Facebook (Link)',
                          controller: facebookController,
                          borderRadius: 12,
                        ),

                        const SizedBox(height: 12),

                        // WEBSITE
                        MyTextFormField(
                          hintText: 'Personal Website (Link)',
                          controller: websiteController,
                          borderRadius: 12,
                        ),

                        const SizedBox(height: 24),

                        // NEXT
                        MyButton(
                          onTap: () async {
                            await next();
                          },
                          text: widget.isChanging ? 'DONE' : 'NEXT',
                        ),
                        const SizedBox(height: 24),

                        // SKIP
                        widget.isChanging
                            ? Container()
                            : MyButton(
                                onTap: () async {
                                  await skip();
                                },
                                text: 'SKIP',
                              ),
                      ],
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
