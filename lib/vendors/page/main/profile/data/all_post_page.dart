import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/profile/view%20page/posts/post_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  // Map<String, Map<String, dynamic>> allPosts = {};
  Map<String, Map<String, dynamic>> currentPosts = {};
  Map<String, Map<String, dynamic>> unlinkedTextPosts = {};
  Map<String, Map<String, dynamic>> unlinkedImagePosts = {};
  String type = 'Image';
  bool isGridView = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // DISPOSE
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET DATA
  Future<void> getData() async {
    final postsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Posts')
        .where('postVendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (var post in postsSnap.docs) {
      final postId = post.id;

      final postData = post.data();

      final isTextPost = postData['isTextPost'];

      if (isTextPost) {
        unlinkedTextPosts[postId] = postData;
      } else {
        unlinkedImagePosts[postId] = postData;
      }
    }

    // for (var map in [
    //   linkedTextPosts,
    //   unlinkedTextPosts,
    //   linkedImagePosts,
    //   unlinkedImagePosts,
    // ]) {
    //   map.forEach((key, value) {
    //     if (allPosts.containsKey(key)) {
    //       allPosts[key]?.addAll(value);
    //     } else {
    //       allPosts[key] = value;
    //     }
    //   });
    // }

    setState(() {
      currentPosts = unlinkedImagePosts;
      isData = true;
    });
  }

  // DELETE POST
  Future<void> deletePost(String postId, bool isTextPost) async {
    try {
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
          .doc(postId)
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
  Future<void> confirmDelete(String postId, bool isTextPost) async {
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
                await deletePost(postId, isTextPost);
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

  // UPDATE CURRENT POSTS
  void updateCurrentPosts() {
    setState(() {
      if (type == 'Image') {
        currentPosts = unlinkedImagePosts;
      } else {
        currentPosts = unlinkedTextPosts;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
        // bottom: PreferredSize(
        //   preferredSize: Size(
        //     MediaQuery.of(context).size.width,
        //     80,
        //   ),
        //   child: Padding(
        //     padding: EdgeInsets.all(
        //       MediaQuery.of(context).size.width * 0.0125,
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Expanded(
        //           child: TextField(
        //             controller: searchController,
        //             autocorrect: false,
        //             onTapOutside: (event) => FocusScope.of(context).unfocus(),
        //             decoration: const InputDecoration(
        //               hintText: 'Search ...',
        //               border: OutlineInputBorder(),
        //             ),
        //             onChanged: (value) {
        //               setState(() {
        //                 if (value.isEmpty) {
        //                   currentPosts = Map<String, Map<String, dynamic>>.from(
        //                     type == 'Image'
        //                         ? link == 'Linked'
        //                             ? linkedImagePosts
        //                             : unlinkedImagePosts
        //                         : link == 'Unlinked'
        //                             ? unlinkedTextPosts
        //                             : linkedTextPosts,
        //                   );
        //                 } else {
        //                   Map<String, Map<String, dynamic>> filteredPosts =
        //                       Map<String, Map<String, dynamic>>.from(
        //                     type == 'Image'
        //                         ? link == 'Linked'
        //                             ? linkedImagePosts
        //                             : unlinkedImagePosts
        //                         : link == 'Unlinked'
        //                             ? unlinkedTextPosts
        //                             : linkedTextPosts,
        //                   );
        //                   List<String> keysToRemove = [];
        //                   filteredPosts.forEach((key, postData) {
        //                     if (!postData['postProductName']
        //                         .toString()
        //                         .toLowerCase()
        //                         .contains(value.toLowerCase().trim())) {
        //                       // ignore: unnecessary_null_comparison
        //                       if (!postData['postText'] != null &&
        //                           !postData['postText']
        //                               .toString()
        //                               .toLowerCase()
        //                               .contains(value.toLowerCase().trim())) {
        //                         keysToRemove.add(key);
        //                       } else {
        //                         keysToRemove.add(key);
        //                       }
        //                     }
        //                   });
        //                   for (var key in keysToRemove) {
        //                     filteredPosts.remove(key);
        //                   }
        //                   setState(() {
        //                     currentPosts = filteredPosts;
        //                   });
        //                 }
        //               });
        //             },
        //           ),
        //         ),
        //         IconButton(
        //           onPressed: () {
        //             setState(() {
        //               isGridView = !isGridView;
        //             });
        //           },
        //           icon: Icon(
        //             isGridView ? FeatherIcons.list : FeatherIcons.grid,
        //           ),
        //           tooltip: isGridView ? 'List View' : 'Grid View',
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
      body: !isData
          ? SafeArea(
              child: GridView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
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
                      isPrice: true,
                      isDelete: true,
                    ),
                  );
                },
              ),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.0125,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(width * 0.0125),
                              child: ActionChip(
                                label: Text(
                                  'Image',
                                  style: TextStyle(
                                    color:
                                        type == 'Image' ? white : primaryDark,
                                  ),
                                ),
                                tooltip: 'Select Image',
                                onPressed: () {
                                  setState(() {
                                    type = 'Image';
                                  });
                                  updateCurrentPosts();
                                },
                                backgroundColor:
                                    type == 'Image' ? primaryDark : primary2,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(width * 0.0125),
                              child: ActionChip(
                                label: Text(
                                  'Text',
                                  style: TextStyle(
                                    color: type == 'Text' ? white : primaryDark,
                                  ),
                                ),
                                tooltip: 'Select Text',
                                onPressed: () {
                                  setState(() {
                                    type = 'Text';
                                  });
                                  updateCurrentPosts();
                                },
                                backgroundColor:
                                    type == 'Text' ? primaryDark : primary2,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 0,
                        ),
                        currentPosts.isEmpty
                            ? SizedBox(
                                height: 80,
                                child: const Center(
                                  child: Text('No Posts'),
                                ),
                              )
                            : SizedBox(
                                width: width,
                                child: type == 'Image'
                                    ? isGridView
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 0.725,
                                            ),
                                            itemCount: currentPosts.length,
                                            itemBuilder: ((context, index) {
                                              final postData = currentPosts[
                                                  currentPosts.keys
                                                      .toList()[index]]!;

                                              return postData['isTextPost']
                                                  ? Container()
                                                  : GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                ((context) =>
                                                                    PostPage(
                                                                      postId: postData[
                                                                          'postId'],
                                                                    )),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: white,
                                                          border: Border.all(
                                                            width: 0.25,
                                                            color: primaryDark,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                        ),
                                                        margin: EdgeInsets.all(
                                                            width * 0.00625),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // postData['postImages'] !=
                                                            //         null
                                                            // ? CachedNetworkImage(
                                                            //     imageUrl:
                                                            //         postData['postImages']
                                                            //             [0],
                                                            //     imageBuilder:
                                                            //         (context, imageProvider) {
                                                            //       return Center(
                                                            //         child: ClipRRect(
                                                            //           borderRadius:
                                                            //               BorderRadius.circular(
                                                            //             12,
                                                            //           ),
                                                            //           child: Container(
                                                            //             width: width * 0.4125,
                                                            //             height: width * 0.4125,
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
                                                            currentPosts ==
                                                                    unlinkedImagePosts
                                                                ? Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(
                                                                      width *
                                                                          0.00625,
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                          2,
                                                                        ),
                                                                        child: Image
                                                                            .network(
                                                                          postData['postImages']
                                                                              [
                                                                              0],
                                                                          width:
                                                                              width * 0.5,
                                                                          height:
                                                                              width * 0.5,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : postData[
                                                                        'isTextPost']
                                                                    ? Container()
                                                                    : SizedBox(
                                                                        width: width *
                                                                            0.5,
                                                                        height: width *
                                                                            0.5,
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Text(
                                                                            'No Image',
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              color: primaryDark2,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                            SizedBox(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          width *
                                                                              0.025,
                                                                          width *
                                                                              0.0125,
                                                                          width *
                                                                              0.0125,
                                                                          0,
                                                                        ),
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              width * 0.275,
                                                                          child:
                                                                              Text(
                                                                            postData['postText'],
                                                                            maxLines:
                                                                                8,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: width * 0.05,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await confirmDelete(
                                                                        postData[
                                                                            'postId'],
                                                                        postData[
                                                                            'isTextPost'],
                                                                      );
                                                                    },
                                                                    icon: Icon(
                                                                      FeatherIcons
                                                                          .trash,
                                                                      color: Colors
                                                                          .red,
                                                                      size: width *
                                                                          0.08,
                                                                    ),
                                                                    tooltip:
                                                                        'Delete Post',
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                            }),
                                          )
                                        : SizedBox(
                                            width: width,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              itemCount: currentPosts.length,
                                              itemBuilder: ((context, index) {
                                                final postData = currentPosts[
                                                    currentPosts.keys
                                                        .toList()[index]]!;

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: ((context) =>
                                                            PostPage(
                                                              postId: postData[
                                                                  'postId'],
                                                            )),
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                    ),
                                                    margin: EdgeInsets.all(
                                                      width * 0.0125,
                                                    ),
                                                    child: ListTile(
                                                      visualDensity:
                                                          VisualDensity
                                                              .standard,
                                                      leading: postData[
                                                                  'postImages'] !=
                                                              null
                                                          // ? CachedNetworkImage(
                                                          //     imageUrl:
                                                          //         postData['postImages']
                                                          //             [0],
                                                          //     imageBuilder:
                                                          //         (context, imageProvider) {
                                                          //       return ClipRRect(
                                                          //         borderRadius:
                                                          //             BorderRadius.circular(
                                                          //           2,
                                                          //         ),
                                                          //         child: Container(
                                                          //           width: width * 0.15,
                                                          //           height: width * 0.15,
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
                                                                  BorderRadius
                                                                      .circular(
                                                                2,
                                                              ),
                                                              child:
                                                                  Image.network(
                                                                postData[
                                                                    'postImages'][0],
                                                                width: width *
                                                                    0.15,
                                                                height: width *
                                                                    0.15,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              width:
                                                                  width * 0.15,
                                                              height:
                                                                  width * 0.15,
                                                              child:
                                                                  const Center(
                                                                child: Text(
                                                                  'No Image',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        primaryDark2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                      title: Text(
                                                        postData['postText'],
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.05,
                                                        ),
                                                      ),
                                                      trailing: IconButton(
                                                        onPressed: () async {
                                                          await confirmDelete(
                                                            postData['postId'],
                                                            postData[
                                                                'isTextPost'],
                                                          );
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.trash,
                                                          color: Colors.red,
                                                          size: width * 0.075,
                                                        ),
                                                        tooltip: 'Delete Post',
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        itemCount: currentPosts.length,
                                        itemBuilder: (context, index) {
                                          final postData = currentPosts[
                                              currentPosts.keys
                                                  .toList()[index]]!;

                                          return Container(
                                            decoration: BoxDecoration(
                                              color: primary2,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.all(
                                              width * 0.0225,
                                            ),
                                            margin: EdgeInsets.all(
                                              width * 0.0125,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: width * 0.785,
                                                  child: Text(
                                                    postData['postText'],
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.045,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () async {
                                                    await confirmDelete(
                                                      postData['postId'],
                                                      postData['isTextPost'],
                                                    );
                                                  },
                                                  icon: Icon(
                                                    FeatherIcons.trash,
                                                    color: Colors.red,
                                                    size: width * 0.08,
                                                  ),
                                                  tooltip: 'Delete Post',
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
