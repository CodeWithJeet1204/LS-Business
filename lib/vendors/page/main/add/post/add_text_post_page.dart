import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/widgets/my_button.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class AddTextPostPage extends StatefulWidget {
  const AddTextPostPage({
    super.key,
    required this.textPostRemaining,
  });

  final int textPostRemaining;

  @override
  State<AddTextPostPage> createState() => _AddTextPostPageState();
}

class _AddTextPostPageState extends State<AddTextPostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final postKey = GlobalKey<FormState>();
  final postController = TextEditingController();
  bool isPosting = false;

  // POST
  Future<void> post() async {
    if (postKey.currentState!.validate()) {
      setState(() {
        isPosting = true;
      });

      try {
        final String postId = const Uuid().v4();

        Map<String, dynamic> postInfo = {
          'postText': postController.text,
          'postId': postId,
          'postVendorId': auth.currentUser!.uid,
          'postViews': 0,
          'postLikes': 0,
          'postImages': null,
          'postComments': {},
          'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch,
          ),
          'isTextPost': true,
        };

        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .update({
          'noOfTextPosts': widget.textPostRemaining - 1,
        });

        await store
            .collection('Business')
            .doc('Data')
            .collection('Posts')
            .doc(postId)
            .set(postInfo);

        setState(() {
          isPosting = false;
        });

        if (mounted) {
          mySnackBar(context, 'Posted');
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          isPosting = false;
        });
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Text Post'),
        actions: [
          IconButton(
            onPressed: () {
              BetterFeedback.of(context).show((feedback) async {
                Future<String> writeImageToStorage(
                    Uint8List feedbackScreenshot) async {
                  final Directory output = await getTemporaryDirectory();
                  final String screenshotFilePath =
                      '${output.path}/feedback.png';
                  final File screenshotFile = File(screenshotFilePath);
                  await screenshotFile.writeAsBytes(feedbackScreenshot);
                  return screenshotFilePath;
                }

                final screenshotFilePath =
                    await writeImageToStorage(feedback.screenshot);

                final Email email = Email(
                  body: feedback.text,
                  subject: 'Localsearch Feedback',
                  recipients: ['infinitylab1204@gmail.com'],
                  attachmentPaths: [screenshotFilePath],
                  isHTML: false,
                );
                await FlutterEmailSender.send(email);
              });
            },
            icon: const Icon(
              Icons.bug_report_outlined,
            ),
            tooltip: 'Report Problem',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Form(
                key: postKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: width,
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.0225),
                        child: TextFormField(
                          autofocus: true,
                          controller: postController,
                          minLines: 1,
                          maxLines: 10,
                          maxLength: 1000,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Colors.cyan.shade700,
                              ),
                            ),
                            hintText: 'Post...',
                          ),
                          validator: (value) {
                            if (value != null) {
                              if (value.isNotEmpty) {
                                return null;
                              } else {
                                return 'Pls enter something';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    // DONE
                    MyButton(
                      text: 'DONE',
                      onTap: () async {
                        await showLoadingDialog(
                          context,
                          () async {
                            await post();
                          },
                        );
                      },
                      horizontalPadding: width * 0.0225,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
