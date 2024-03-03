import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:find_easy/page/main/profile/view%20page/product/image_view.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/info_box.dart';
import 'package:find_easy/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.postId,
    required this.productId,
    required this.productName,
    required this.categoryId,
  });

  final String postId;
  final String productId;
  final String productName;
  final String categoryId;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  int _currentIndex = 0;
  bool isDiscount = false;

  // INIT STATE
  @override
  void initState() {
    ifDiscount();
    super.initState();
  }

  // IF DISCOUNT
  Future<void> ifDiscount() async {
    final discount = await store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in discount.docs) {
      final data = doc.data();
      if ((data['products'] as List).contains(widget.productId) ||
          (data['categories'] as List).contains(widget.categoryId)) {
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
        }
      }
    }
  }

  // DELETE POST
  void deletePost() async {
    try {
      await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .doc(widget.postId)
          .delete();
      if (context.mounted) {
        Navigator.of(context).pop();
        mySnackBar(context, "Post Deleted");
      }
    } catch (e) {
      if (context.mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CONFIRM DELETE
  void confirmDelete() async {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(overflow: TextOverflow.ellipsis, "Confirm DELETE"),
          content: const Text(
            overflow: TextOverflow.ellipsis,
            "Are you sure you want to delete this Post\nProduct of this post will not be deleted",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                deletePost();
                Navigator.of(context).pop();
              },
              child: const Text(
                overflow: TextOverflow.ellipsis,
                'YES',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postStream = store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .doc(widget.postId)
        .snapshots();

    final discountPriceStream = store
        .collection('Business')
        .doc('Data')
        .collection('Discounts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: confirmDelete,
            icon: const Icon(
              FeatherIcons.trash,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.0166,
          horizontal: MediaQuery.of(context).size.width * 0.0225,
        ),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: StreamBuilder(
                  stream: postStream,
                  builder: ((context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          "Something went wrong",
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final postData = snapshot.data!;
                      final bool isTextPost = postData['isTextPost'];
                      final String name = postData['postProductName'];
                      final String brand = postData['postProductBrand'];
                      final String price = postData['postProductPrice'];
                      final String description =
                          postData['postProductDescription'];
                      final int likes = postData['postLikes'];
                      final int views = postData['postViews'];
                      final Map comments = postData['postComments'];
                      final List images =
                          isTextPost ? [] : postData['postProductImages'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          !isTextPost
                              // IMAGE
                              ? CarouselSlider(
                                  items: images
                                      .map(
                                        (e) => Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: primaryDark2,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: ((context) =>
                                                      ImageView(
                                                        imagesUrl: images,
                                                      )),
                                                ),
                                              );
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl: e,
                                              imageBuilder:
                                                  (context, imageProvider) {
                                                return Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      11,
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  options: CarouselOptions(
                                    enableInfiniteScroll:
                                        images.length > 1 ? true : false,
                                    aspectRatio: 1.2,
                                    enlargeCenterPage: true,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _currentIndex = index;
                                      });
                                    },
                                  ),
                                )
                              : Container(),

                          // DOTS
                          !isTextPost
                              ? images.length > 1
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: width * 0.035,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: (images).map((e) {
                                              int index = images.indexOf(e);

                                              return Container(
                                                width: _currentIndex == index
                                                    ? 12
                                                    : 8,
                                                height: _currentIndex == index
                                                    ? 12
                                                    : 8,
                                                margin: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _currentIndex == index
                                                      ? primaryDark
                                                      : primary2,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        )
                                      ],
                                    )
                                  : Container()
                              : Container(),

                          // NAME
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.028,
                              vertical: width * 0.028,
                            ),
                            child: SizedBox(
                              width: width * 0.875,
                              child: AutoSizeText(
                                overflow: TextOverflow.ellipsis,
                                name,
                                maxLines: 1,
                                style: TextStyle(
                                  color: primaryDark,
                                  fontSize: width * 0.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // PRICE
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.0175,
                            ),
                            child: isDiscount
                                ? StreamBuilder(
                                    stream: discountPriceStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text(
                                            overflow: TextOverflow.ellipsis,
                                            'Something went wrong',
                                          ),
                                        );
                                      }

                                      if (snapshot.hasData) {
                                        final priceSnap = snapshot.data!;
                                        Map<String, dynamic> data = {};
                                        for (QueryDocumentSnapshot<
                                                Map<String, dynamic>> doc
                                            in priceSnap.docs) {
                                          data = doc.data();
                                        }

                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // PRICE
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.028,
                                              ),
                                              child: RichText(
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  text: 'Rs. ',
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.06,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: price == ""
                                                          ? 'N/A (price)'
                                                          : data['isPercent']
                                                              ? '${(double.parse(price) * (100 - (data['discountAmount'])) / 100).toStringAsFixed(2)}  '
                                                              : '${(double.parse(price) - (data['discountAmount'])).toStringAsFixed(2)}  ',
                                                      style: const TextStyle(
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: price == ""
                                                          ? 'N/A (price)'
                                                          : price,
                                                      style: TextStyle(
                                                        fontSize: width * 0.055,
                                                        color: const Color
                                                            .fromRGBO(
                                                          255,
                                                          134,
                                                          125,
                                                          1,
                                                        ),
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),

                                            // DISCOUNT
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: width * 0.028,
                                              ),
                                              child: data['isPercent']
                                                  ? Text(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      "${data['discountAmount']}% off",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    )
                                                  : Text(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      "Save Rs. ${data['discountAmount']}",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                            ),

                                            // TIME
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.028,
                                                vertical: width * 0.00625,
                                              ),
                                              child: Text(
                                                overflow: TextOverflow.ellipsis,
                                                (data['discountEndDateTime']
                                                                as Timestamp)
                                                            .toDate()
                                                            .difference(
                                                                DateTime.now())
                                                            .inHours <
                                                        24
                                                    ? '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours Left'''
                                                    : '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days Left''',
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    })
                                : Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      "Rs. ${postData['postProductPrice']}",
                                      style: const TextStyle(
                                        color: primaryDark,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                          ),

                          // DESCRIPTION
                          InfoBox(
                            text: "DESCRIPTION",
                            value: description,
                          ),

                          // BRAND
                          InfoBox(
                            text: "BRAND",
                            value: brand,
                          ),

                          // LIKES
                          InfoBox(
                            text: "LIKES",
                            value: likes.toString(),
                          ),

                          // VIEWS
                          InfoBox(
                            text: "VIEWS",
                            value: views.toString(),
                          ),

                          // COMMENTS
                          InkWell(
                            onTap: () {},
                            splashColor: primary2,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                InfoBox(
                                  text: "COMMENTS",
                                  value: comments.length.toString(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(FeatherIcons.chevronRight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
