import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/page/main/add/post/select_product_for_post_page.dart';
import 'package:localy/vendors/provider/select_product_for_post_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isFit = false;
  int currentImageIndex = 0;
  bool isPosting = false;
  int textPostRemaining = 0;
  int imagePostRemaining = 0;

  // INIT STATE
  @override
  void initState() {
    getNoOfPosts();
    super.initState();
  }

  // POST
  Future<void> post(
    SelectProductForPostProvider postProvider,
    bool isTextPost,
  ) async {
    if (((isTextPost ? textPostRemaining : imagePostRemaining) -
            postProvider.selectedProducts.length) >=
        0) {
      try {
        bool postDoesntExists = true;
        final previousPosts = await store
            .collection('Business')
            .doc('Data')
            .collection('Posts')
            .where('postVendorId', isEqualTo: auth.currentUser!.uid)
            .get();

        for (QueryDocumentSnapshot doc in previousPosts.docs) {
          for (var id in postProvider.selectedProducts) {
            if (doc['postProductId'] == id && isTextPost == doc['isTextPost']) {
              if (mounted) {
                mySnackBar(
                  context,
                  isTextPost
                      ? 'Text Post Already Exists for one of the product'
                      : 'Image Post Already Exists for the product',
                );
              }
              postDoesntExists = false;
            }
          }
        }

        if (postDoesntExists) {
          setState(() {
            isPosting = true;
          });

          // ignore: avoid_function_literals_in_foreach_calls
          postProvider.selectedProducts.forEach((id) async {
            await store
                .collection('Business')
                .doc('Owners')
                .collection('Shops')
                .doc(auth.currentUser!.uid)
                .update({
              'noOfTextPosts': isTextPost
                  ? textPostRemaining - postProvider.selectedProducts.length
                  : textPostRemaining,
              'noOfImagePosts': !isTextPost
                  ? imagePostRemaining - postProvider.selectedProducts.length
                  : imagePostRemaining,
            });

            final productDocSnap = await store
                .collection('Business')
                .doc('Data')
                .collection('Products')
                .doc(id)
                .get();

            final String postId = const Uuid().v4();

            Map<String, dynamic> postInfo = {
              'postId': postId,
              'postProductId': productDocSnap['productId'],
              'postProductName': productDocSnap['productName'],
              'postProductPrice': productDocSnap['productPrice'],
              'postCategoryName': productDocSnap['categoryName'],
              'postProductDescription': productDocSnap['productDescription'],
              'postProductBrand': productDocSnap['productBrand'],
              'postProductImages': isTextPost ? null : productDocSnap['images'],
              'postVendorId': productDocSnap['vendorId'],
              'postViews': 0,
              'postLikes': 0,
              'postComments': {},
              'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch,
              ),
              'isTextPost': isTextPost,
            };

            await store
                .collection('Business')
                .doc('Data')
                .collection('Posts')
                .doc(postId)
                .set(postInfo);
          });

          setState(() {
            isPosting = false;
          });

          postProvider.clear();

          if (mounted) {
            mySnackBar(context, 'Posted');
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        setState(() {
          isPosting = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      mySnackBar(
        context,
        'You have ${isTextPost ? textPostRemaining : imagePostRemaining} ${isTextPost ? 'Text' : 'Image'} Posts remaining, remove ${-(textPostRemaining - postProvider.selectedProducts.length)} product to continue',
      );
    }
  }

  // GET NO OF POSTS
  Future<void> getNoOfPosts() async {
    final productData = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    setState(() {
      textPostRemaining = productData['noOfTextPosts'];
      imagePostRemaining = productData['noOfImagePosts'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedProductProvider =
        Provider.of<SelectProductForPostProvider>(context);
    final List<String> selectedProducts =
        selectedProductProvider.selectedProducts;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'CREATE POST',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          MyTextButton(
            onPressed: () async {
              if (selectedProducts.isEmpty ||
                  selectedProductProvider.isTextPost == null) {
                return mySnackBar(context, 'Select a Post Type');
              } else {
                await post(
                  selectedProductProvider,
                  selectedProductProvider.isTextPost!,
                );
              }
            },
            text: 'DONE',
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isPosting ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isPosting ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width * 0.9,
                height: width * 0.2,
                margin: EdgeInsets.symmetric(vertical: width * 0.05),
                decoration: BoxDecoration(
                  color: primary2.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remaining Text Post - $textPostRemaining',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryDark,
                        fontWeight: FontWeight.w500,
                        fontSize: width * 0.05,
                      ),
                    ),
                    Text(
                      'Remaining Image Post - $imagePostRemaining',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryDark,
                        fontWeight: FontWeight.w500,
                        fontSize: width * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
              textPostRemaining > 0 || imagePostRemaining > 0
                  ? Column(
                      children: [
                        Text(
                          'Select the type of post you want to create',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Just select the product you want the post',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Then the product details will automatically be added',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Your no of Text & Image Posts has reached 0\nYou cannot post another post until your current memberhsip ends',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryDark,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              SizedBox(height: width * 0.055),
              Opacity(
                opacity: textPostRemaining > 0 ? 1 : 0.5,
                child: MyButton(
                  text: selectedProducts.isEmpty
                      ? 'TEXT POST'
                      : selectedProductProvider.isTextPost == true
                          ? 'TEXT POSTS: ${selectedProducts.length}'
                          : 'TEXT POST',
                  onTap: textPostRemaining > 0
                      ? () {
                          selectedProductProvider.changePostType(true);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) => SelectProductForPostPage(
                                    isTextPost:
                                        selectedProductProvider.isTextPost ==
                                            true,
                                    postRemaining: textPostRemaining,
                                  )),
                            ),
                          );
                        }
                      : null,
                  isLoading: false,
                  horizontalPadding: width * 0.055,
                ),
              ),
              // IMAGE POST BUTTON
              SizedBox(height: width * 0.055),
              Opacity(
                opacity: imagePostRemaining > 0 ? 1 : 0.5,
                child: MyButton(
                  text: selectedProducts.isEmpty
                      ? 'IMAGE POST'
                      : selectedProductProvider.isTextPost == false
                          ? 'IMAGE POSTS: ${selectedProducts.length}'
                          : 'IMAGE POST',
                  onTap: imagePostRemaining > 0
                      ? () {
                          selectedProductProvider.changePostType(false);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) => SelectProductForPostPage(
                                    isTextPost:
                                        selectedProductProvider.isTextPost ==
                                            true,
                                    postRemaining: imagePostRemaining,
                                  )),
                            ),
                          );
                        }
                      : null,
                  isLoading: false,
                  horizontalPadding: width * 0.055,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
