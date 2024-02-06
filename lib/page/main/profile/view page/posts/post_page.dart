import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/page/main/profile/view%20page/product/product_image_page.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/info_box.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final store = FirebaseFirestore.instance;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final postStream = store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .doc(widget.postId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
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
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: SizedBox(
                width: width,
                child: StreamBuilder(
                  stream: postStream,
                  builder: ((context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Something went wrong"),
                      );
                    }

                    if (snapshot.hasData) {
                      final postData = snapshot.data!;
                      final bool isTextPost = postData['isTextPost'];
                      final String name = postData['postName'];
                      final String brand = postData['postBrand'];
                      final String price = postData['postPrice'];
                      final String description = postData['postDescription'];
                      final int likes = postData['postLikes'];
                      final int views = postData['postViews'];
                      final Map comments = postData['postComments'];
                      final List images = postData['postImages'];

                      return Column(
                        children: [
                          isTextPost
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
                          isTextPost
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(),
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
                                            width:
                                                _currentIndex == index ? 12 : 8,
                                            height:
                                                _currentIndex == index ? 12 : 8,
                                            margin: EdgeInsets.all(4),
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
                              : Container(),

                          // NAME
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              price == "" ? 'N/A (price)' : 'Rs. ${price}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryDark,
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
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
                                  icon: Icon(Icons.navigate_next_outlined),
                                  tooltip: "See Comments",
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Center(
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
