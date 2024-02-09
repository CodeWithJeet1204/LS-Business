import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_image_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/info_box.dart';
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
      print((data['categories'] as List).contains(widget.categoryId));
      print("ABC");
      if ((data['products'] as List).contains(widget.productId) ||
          (data['categories'] as List).contains(widget.categoryId)) {
        print("DEF");
        if ((data['discountEndDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now()) &&
            !(data['discountStartDateTime'] as Timestamp)
                .toDate()
                .isAfter(DateTime.now())) {
          setState(() {
            isDiscount = true;
          });
          print(isDiscount);
        }
      }
    }
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
            onPressed: () {},
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: ((context, constraints) {
          double width = constraints.maxWidth;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: SizedBox(
                width: width,
                child: StreamBuilder(
                  stream: postStream,
                  builder: ((context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Something went wrong"),
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
                                                      ProductImageView(
                                                        imagesUrl: images,
                                                      )),
                                                ),
                                              );
                                            },
                                            child: Image.network(e),
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
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryDark,
                                fontSize: name.length > 12
                                    ? 28
                                    : name.length > 10
                                        ? 30
                                        : 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // PRICE
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: isDiscount
                                ? StreamBuilder(
                                    stream: discountPriceStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text('Something Went Wrong'),
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
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: RichText(
                                                text: TextSpan(
                                                  text: 'Rs. ',
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: price == ""
                                                          ? 'N/A (price)'
                                                          : data['isPercent']
                                                              ? '${(double.parse(price) * (100 - data['discountAmount']) / 100).toString()}  '
                                                              : '${double.parse(price) - data['discountAmount']}  ',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: price == ""
                                                          ? 'N/A (price)'
                                                          : price,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromRGBO(
                                                            255, 134, 125, 1),
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: data['isPercent']
                                                  ? Text(
                                                      "${data['discountAmount']}% off",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Save Rs. ${data['discountAmount']}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                (data['discountEndDateTime']
                                                                as Timestamp)
                                                            .toDate()
                                                            .difference(
                                                                DateTime.now())
                                                            .inHours <
                                                        24
                                                    ? '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inHours} Hours Left'''
                                                    : '''${(data['discountEndDateTime'] as Timestamp).toDate().difference(DateTime.now()).inDays} Days Left''',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    })
                                : Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      "Rs. ${postData['postProductPrice']}",
                                      style: TextStyle(
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
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              InfoBox(
                                text: "COMMENTS",
                                value: comments.length.toString(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  onPressed: () {
                                    // TODO Directly navigate to post's comments
                                  },
                                  icon:
                                      const Icon(Icons.navigate_next_outlined),
                                  tooltip: "See Comments",
                                ),
                              ),
                            ],
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
            ),
          );
        }),
      ),
    );
  }
}
