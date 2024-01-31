import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/add/post/select_product_for_post_page.dart';
import 'package:find_easy/provider/select_product_for_post_provider.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/button.dart';
import 'package:find_easy/widgets/snack_bar.dart';
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

  Future<String> post(SelectProductForPostProvider postPprovider) async {
    setState(() {
      isPosting = true;
    });
    String res = "Some error occured";
    try {
      final productDocSnap = await firestore
          .collection('Business')
          .doc('Data')
          .collection('Products')
          .doc(postPprovider.selectedProduct[0])
          .get();

      final String postId = Uuid().v6();

      Map<String, dynamic> postInfo = {
        'postId': postId,
        'postProductId': productDocSnap['productId'],
        'postName': productDocSnap['productName'],
        'postPrice': productDocSnap['productPrice'],
        'postDescription': productDocSnap['productDescription'],
        'postBrand': productDocSnap['productBrand'],
        'postImages': productDocSnap['images'],
        'postVendorId': productDocSnap['vendorId'],
        'postViews': 0,
        'postLikes': 0,
        'postComments': {},
        'postDateTime': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
        ),
      };

      await firestore
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .doc(postId)
          .set(postInfo);

      setState(() {
        isPosting = false;
      });
      res = "";

      mySnackBar(context, "Posted");
      Navigator.of(context).pop();
    } catch (e) {
      res = e.toString();
      setState(() {
        isPosting = false;
      });
      mySnackBar(context, e.toString());
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
      appBar: AppBar(
        title: Text("CREATE POST"),
        actions: [
          IconButton(
            onPressed: () async {
              if (selectedProduct.isEmpty) {
                return mySnackBar(context, "Select a Product");
              } else {
                String res = await post(selectedProductProvider);
                if (res == "") {
                  selectedProductProvider.clear();
                }
              }
            },
            icon: Icon(Icons.ios_share),
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
          Text(
            "Just select the product you want the post",
            style: TextStyle(
              color: primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Then the product details will automatically be added",
            style: TextStyle(
              color: primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          MyButton(
            text: selectedProduct.length < 2
                ? "LINK PRODUCT"
                : "PRODUCT: ${selectedProduct[1]}",
            onTap: () {
              print("ABC");
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: ((context) => SelectProductForPostPage()),
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
