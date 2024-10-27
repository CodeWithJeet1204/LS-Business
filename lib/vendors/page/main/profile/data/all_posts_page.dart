import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:ls_business/vendors/page/main/add/post/add_post_page.dart';
import 'package:ls_business/vendors/page/main/profile/view%20page/posts/post_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/shimmer_skeleton_container.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class allPostPage extends StatefulWidget {
  const allPostPage({super.key});

  @override
  State<allPostPage> createState() => _allPostPageState();
}

class _allPostPageState extends State<allPostPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  Map<String, Map<String, dynamic>> allPost = {};
  Map<String, Map<String, dynamic>> currentPost = {};
  int? total;
  int noOfGridView = 8;
  bool isLoadMoreGridView = false;
  final scrollControllerGridView = ScrollController();
  int noOfListView = 20;
  bool isLoadMoreListView = false;
  final scrollControllerListView = ScrollController();
  bool isGridView = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getTotal();
    getPostsData();
    scrollControllerGridView.addListener(scrollListenerGridView);
    scrollControllerListView.addListener(scrollListenerListView);
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    scrollControllerGridView.dispose();
    scrollControllerListView.dispose();
    super.dispose();
  }

  // SCROLL LISTENER GRID VIEW
  Future<void> scrollListenerGridView() async {
    if (total != null && noOfGridView < total!) {
      if (scrollControllerGridView.position.pixels ==
          scrollControllerGridView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreGridView = true;
        });
        noOfGridView = noOfGridView + 8;
        await getPostsData();
        setState(() {
          isLoadMoreGridView = false;
        });
      }
    }
  }

  // SCROLL LISTENER LIST VIEW
  Future<void> scrollListenerListView() async {
    if (total != null && noOfListView < total!) {
      if (scrollControllerListView.position.pixels ==
          scrollControllerListView.position.maxScrollExtent) {
        setState(() {
          isLoadMoreListView = true;
        });
        noOfListView = noOfListView + 12;
        await getPostsData();
        setState(() {
          isLoadMoreListView = false;
        });
      }
    }
  }

  // GET TOTAL
  Future<void> getTotal() async {
    final brandSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Post')
        .where('postVendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    final brandLength = brandSnap.docs.length;

    setState(() {
      total = brandLength;
    });
  }

  // GET POSTS DATA
  Future<void> getPostsData() async {
    Map<String, Map<String, dynamic>> myPost = {};
    final postSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Post')
        .where('postVendorId', isEqualTo: auth.currentUser!.uid)
        .limit(isGridView ? noOfGridView : noOfListView)
        .get();

    for (var post in postSnap.docs) {
      final postId = post.id;
      final postData = post.data();

      myPost[postId] = postData;
    }

    setState(() {
      currentPost = myPost;
      allPost = myPost;
      isData = true;
    });
  }

  // CONFIRM DELETE
  Future<void> confirmDelete(String postId, List? postImage) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm DELETE',
          ),
          content: const Text(
            'Are you sure you want to delete this Post?',
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
                await delete(postId, postImage);
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
      },
    );
  }

  // DELETE
  Future<void> delete(String postId, List? postImage) async {
    try {
      if (postImage != null) {
        for (var image in postImage) {
          await storage.refFromURL(image).delete();
        }
      }

      await store
          .collection('Business')
          .doc('Data')
          .collection('Post')
          .doc(postId)
          .delete();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'All Posts',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddPostPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
            ),
            tooltip: 'Add Post',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(width, 80),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.0166,
              vertical: width * 0.0225,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autocorrect: false,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search ...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() async {
                        if (value.isEmpty) {
                          setState(() {
                            currentPost =
                                Map<String, Map<String, dynamic>>.from(allPost);
                          });
                        } else {
                          Map<String, Map<String, dynamic>> filteredPost =
                              Map<String, Map<String, dynamic>>.from(allPost);

                          List<String> keysToRemove = await Future.wait(
                            filteredPost.entries.map((entry) async {
                              if (!entry.value['postText']
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase().trim())) {
                                return entry.key;
                              }
                              return null;
                            }),
                          ).then(
                              (result) => result.whereType<String>().toList());

                          setState(() {
                            keysToRemove.forEach(filteredPost.remove);
                            currentPost = filteredPost;
                          });
                        }
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                  icon: Icon(
                    isGridView ? FeatherIcons.list : FeatherIcons.grid,
                  ),
                  tooltip: isGridView ? 'List View' : 'Grid View',
                ),
              ],
            ),
          ),
        ),
      ),
      body: !isData
          ? SafeArea(
              child: isGridView
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: width * 0.5 / width * 1.6,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: GridViewSkeleton(
                            width: width,
                            isPrice: false,
                            isDelete: true,
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: ListViewSkeleton(
                            width: width,
                            isPrice: false,
                            height: 30,
                            isDelete: true,
                          ),
                        );
                      },
                    ),
            )
          : currentPost.isEmpty
              ? const Center(
                  child: Text('No Posts'),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.006125),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        return isGridView
                            ? GridView.builder(
                                controller: scrollControllerGridView,
                                cacheExtent: height * 1.5,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.725,
                                ),
                                itemCount: noOfGridView > currentPost.length
                                    ? currentPost.length
                                    : noOfGridView,
                                itemBuilder: ((context, index) {
                                  final postData = currentPost[
                                      currentPost.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PostPage(
                                            postId: postData['postId'],
                                            postText: postData['postText'],
                                            imageUrl: postData['postImage'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: white,
                                        border: Border.all(
                                          width: 0.25,
                                          color: primaryDark,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      margin: EdgeInsets.all(width * 0.00625),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          postData['postImage'][0] != null
                                              // ? CachedNetworkImage(
                                              //     imageUrl: brandData['imageUrl'],
                                              //     imageBuilder:
                                              //         (context, imageProvider) {
                                              //       return Center(
                                              //         child: ClipRRect(
                                              //           borderRadius:
                                              //               BorderRadius.circular(
                                              //             12,
                                              //           ),
                                              //           child: Container(
                                              //             width: width * 0.4,
                                              //             height: width * 0.4,
                                              //             decoration: BoxDecoration(
                                              //               image: DecorationImage(
                                              //                 image: imageProvider,
                                              //                 fit: BoxFit.cover,
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ),
                                              //       );
                                              //     },
                                              //   )
                                              ? Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        width * 0.006125,
                                                    vertical:
                                                        width * 0.00306125,
                                                  ),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        2,
                                                      ),
                                                      child: Container(
                                                        width: width * 0.5,
                                                        height: width * 0.5,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                              postData['postImage']
                                                                      [0]
                                                                  .trim(),
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: width * 0.5,
                                                  child: const Center(
                                                    child: Text(
                                                      'No Image',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: primaryDark2,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          Divider(
                                            height:
                                                postData['postImage'][0] != null
                                                    ? 0
                                                    : 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.02,
                                                ),
                                                child: SizedBox(
                                                  width: width * 0.325,
                                                  child: Text(
                                                    postData['postText']
                                                        .toString()
                                                        .trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.06,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await confirmDelete(
                                                    postData['postId'],
                                                    postData['postImage'],
                                                  );
                                                  if (context.mounted) {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const allPostPage(),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: Icon(
                                                  FeatherIcons.trash,
                                                  color: Colors.red,
                                                  size: width * 0.08,
                                                ),
                                                tooltip: 'DELETE',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              )
                            : ListView.builder(
                                controller: scrollControllerListView,
                                cacheExtent: height * 1.5,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: noOfListView > currentPost.length
                                    ? currentPost.length
                                    : noOfListView,
                                itemBuilder: ((context, index) {
                                  final postData = currentPost[
                                      currentPost.keys.toList()[index]]!;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PostPage(
                                            postId: postData['postId'],
                                            postText: postData['postText'],
                                            imageUrl: postData['postImage'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: white,
                                        border: Border.all(
                                          width: 0.5,
                                          color: primaryDark,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      margin: EdgeInsets.all(
                                        width * 0.0125,
                                      ),
                                      child: ListTile(
                                        visualDensity: VisualDensity.standard,
                                        leading: postData['postImage'][0] !=
                                                null
                                            // ? CachedNetworkImage(
                                            //     imageUrl: brandData['imageUrl'],
                                            //     imageBuilder:
                                            //         (context, imageProvider) {
                                            //       return ClipRRect(
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //           4,
                                            //         ),
                                            //         child: Container(
                                            //           width: width * 0.133,
                                            //           height: width * 0.133,
                                            //           decoration: BoxDecoration(
                                            //             image: DecorationImage(
                                            //               image: imageProvider,
                                            //               fit: BoxFit.cover,
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       );
                                            //     },
                                            //   )
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  2,
                                                ),
                                                child: Image.network(
                                                  postData['postImage'][0]
                                                      .toString()
                                                      .trim(),
                                                  width: width * 0.15,
                                                  height: width * 0.15,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : SizedBox(
                                                width: width * 0.15,
                                                height: width * 0.15,
                                                child: const Center(
                                                  child: Text(
                                                    'No Image',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        title: Text(
                                          postData['postText']
                                              .toString()
                                              .trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.06,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          onPressed: () async {
                                            await confirmDelete(
                                              postData['postId'],
                                              postData['postImage'],
                                            );
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const allPostPage(),
                                                ),
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            FeatherIcons.trash,
                                            color: Colors.red,
                                            size: width * 0.075,
                                          ),
                                          tooltip: 'DELETE',
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                      },
                    ),
                  ),
                ),
    );
  }
}
