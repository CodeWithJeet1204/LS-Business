import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:uuid/uuid.dart';

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
          'postProductId': null,
          'postProductName': null,
          'postProductPrice': null,
          'postCategoryName': null,
          'postProductDescription': null,
          'postProductBrand': null,
          'postProductImages': null,
          'postImages': null,
          'post': postController.text,
          'postId': postId,
          'postVendorId': auth.currentUser!.uid,
          'postViews': 0,
          'postLikes': 0,
          'postComments': {},
          'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch,
          ),
          'isTextPost': true,
          'isLinked': false,
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
                        await post();
                      },
                      isLoading: isPosting,
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
