import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/add/post/select_product_for_post_page.dart';
import 'package:find_easy/provider/select_product_for_post_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isFit = false;
  int currentImageIndex = 0;
  bool isPosting = false;

  Future<String> post(
      SelectProductForPostProvider postprovider, bool isTextPost) async {
    String res = "Some error occured";
    try {
      bool postDoesntExists = true;
      final previousPosts = await firestore
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .where('postVendorId',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      for (QueryDocumentSnapshot doc in previousPosts.docs) {
        if (doc['postProductId'] == postprovider.selectedProduct[0] &&
            isTextPost == doc['isTextPost']) {
          if (context.mounted) {
            mySnackBar(
              context,
              isTextPost
                  ? "Text Post Already Exists for this product"
                  : "Image Post Already Exists for this product",
            );
          }
          postDoesntExists = false;
        }
      }

      if (postDoesntExists) {
        setState(() {
          isPosting = true;
        });

        final productDocSnap = await firestore
            .collection('Business')
            .doc('Data')
            .collection('Products')
            .doc(postprovider.selectedProduct[0])
            .get();

        final String postId = const Uuid().v4();

        Map<String, dynamic> postInfo = {
          'postId': postId,
          'postProductId': productDocSnap['productId'],
          'postName': productDocSnap['productName'],
          'postPrice': productDocSnap['productPrice'],
          'postCategoryId': productDocSnap['categoryId'],
          'postDescription': productDocSnap['productDescription'],
          'postBrand': productDocSnap['productBrand'],
          'postImages': isTextPost ? null : productDocSnap['images'],
          'postVendorId': productDocSnap['vendorId'],
          'postViews': 0,
          'postLikes': 0,
          'postComments': {},
          'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch,
          ),
          'isTextPost': isTextPost,
        };

        await firestore
            .collection('Business')
            .doc('Data')
            .collection('Posts')
            .doc(postId)
            .set(postInfo);
        if (context.mounted) {
          mySnackBar(context, "Posted");
          Navigator.of(context).pop();
        }
      }

      setState(() {
        isPosting = false;
      });
      res = "";
    } catch (e) {
      res = e.toString();
      setState(() {
        isPosting = false;
      });
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    final selectedProductProvider =
        Provider.of<SelectProductForPostProvider>(context);
    final List<String> selectedProduct =
        selectedProductProvider.selectedProduct;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("CREATE POST"),
        actions: [
          IconButton(
            onPressed: () async {
              if (selectedProduct.isEmpty ||
                  selectedProductProvider.isTextPost == null) {
                return mySnackBar(context, "Select a Post Type");
              } else {
                String res = await post(selectedProductProvider,
                    selectedProductProvider.isTextPost!);
                if (res == "") {
                  selectedProductProvider.clear();
                }
              }
            },
            icon: const Icon(Icons.ios_share),
            tooltip: "Post",
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isPosting ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isPosting ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select the type of post you want to create",
            style: TextStyle(
              color: primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            "Just select the product you want the post",
            style: TextStyle(
              color: primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            "Then the product details will automatically be added",
            style: TextStyle(
              color: primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          MyButton(
            text: selectedProduct.length < 2
                ? "TEXT POST"
                : selectedProductProvider.isTextPost == true
                    ? "TEXT POST: ${selectedProduct[1]}"
                    : "TEXT POST",
            onTap: () {
              selectedProductProvider.changePostType(true);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: ((context) => const SelectProductForPostPage()),
                ),
              );
            },
            isLoading: false,
            horizontalPadding: 20,
          ),
          const SizedBox(height: 20),
          MyButton(
            text: selectedProduct.length < 2
                ? "IMAGE POST"
                : selectedProductProvider.isTextPost == false
                    ? "IMAGE POST: ${selectedProduct[1]}"
                    : "IMAGE POST",
            onTap: () {
              selectedProductProvider.changePostType(false);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: ((context) => const SelectProductForPostPage()),
                ),
              );
            },
            isLoading: false,
            horizontalPadding: 20,
          ),
        ],
      ),
    );
  }
}
