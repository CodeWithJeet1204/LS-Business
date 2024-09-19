import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/product/image_view.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/info_box.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  int _currentIndex = 0;
  bool isDiscount = false;

  // INIT STATE
  @override
  void initState() {
    super.initState();
  }

  // DELETE POST
  Future<void> deletePost(bool isTextPost) async {
    try {
      if (mounted) {
        Navigator.of(context).pop();
      }

      int textPostRemaining = 0;
      int imagePostRemaining = 0;

      final vendorSnap = await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .get();

      setState(() {
        textPostRemaining = vendorSnap['noOfTextPosts'];
        imagePostRemaining = vendorSnap['noOfImagePosts'];
      });

      await store
          .collection('Business')
          .doc('Data')
          .collection('Posts')
          .doc(widget.postId)
          .delete();

      isTextPost
          ? await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(auth.currentUser!.uid)
              .update({
              'noOfTextPosts': textPostRemaining + 1,
            })
          : await store
              .collection('Business')
              .doc('Owners')
              .collection('Shops')
              .doc(auth.currentUser!.uid)
              .update({
              'noOfImagePosts': imagePostRemaining + 1,
            });

      if (mounted) {
        mySnackBar(context, 'Post Deleted');
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // CONFIRM DELETE
  Future<void> confirmDelete(bool isTextPost) async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Confirm DELETE',
          ),
          content: const Text(
            'Are you sure you want to delete this Post',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'NO',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await deletePost(isTextPost);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
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

  // GET IS TEXT POST
  Future<bool> getIsTextPost() async {
    bool isTextPost = false;
    final postSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .doc(widget.postId)
        .get();

    final postData = postSnap.data();

    if (postData != null) {
      isTextPost = postData['isTextPost'];
    }

    return isTextPost;
  }

  @override
  Widget build(BuildContext context) {
    final postStream = store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .doc(widget.postId)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          FutureBuilder(
              future: getIsTextPost(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }

                if (snapshot.hasData) {
                  return IconButton(
                    onPressed: () async {
                      await confirmDelete(snapshot.data!);
                    },
                    icon: const Icon(
                      FeatherIcons.trash,
                      color: Colors.red,
                    ),
                  );
                }

                return Container();
              }),
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
                          'Something went wrong',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final postData = snapshot.data!;
                      final bool isTextPost = postData['isTextPost'];
                      final String? name = postData['postText'];
                      final int likes = postData['postLikes'];
                      final int views = postData['postViews'];
                      final Map comments = postData['postComments'];
                      final List images =
                          isTextPost ? [] : postData['postImages'];

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

                          images.isEmpty ? Container() : const Divider(),

                          // NAME
                          name == null
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.785,
                                    child: Text(
                                      name,
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.06,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                          name == null ? Container() : const Divider(),

                          // LIKES
                          InfoBox(
                            text: 'LIKES',
                            value: likes.toString(),
                          ),

                          // VIEWS
                          InfoBox(
                            text: 'VIEWS',
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
                                  text: 'COMMENTS',
                                  value: comments.length.toString(),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
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
