import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ls_business/vendors/page/main/add/post/add_post_page.dart';
import 'package:ls_business/vendors/page/main/add/status/add_status_page.dart';
import 'package:ls_business/widgets/add_box.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SharePage extends StatefulWidget {
  const SharePage({
    super.key,
    required this.imagePaths,
  });

  final List<String> imagePaths;

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  List<String> localFilePaths = [];
  bool? isRegistration;
  bool isData = false;

  @override
  void initState() {
    getVendorData();
    handleReceivedImages(widget.imagePaths);
    super.initState();
  }

  // GET VENDOR DATA
  Future<void> getVendorData() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;
    final membershipName = vendorData['MembershipName'];

    setState(() {
      isRegistration = membershipName == 'Registration';
    });
  }

  // CHECK AND SAVE FILE
  Future<String?> checkAndSaveFile(String contentUri, int index) async {
    const platform = MethodChannel('com.ls_business.share');

    if (await Permission.photos.request().isGranted) {
      try {
        final dir = await getExternalStorageDirectory();

        final filePath = await platform.invokeMethod(
          'copyFileFromUri',
          {
            "uri": contentUri,
            "destinationPath": '${dir!.path}/shared_image$index.jpg'
          },
        );

        if (filePath != null) {
          return filePath;
        }
      } catch (e) {}
    }
    return null;
  }

  // HANDLE RECEIVED IMAGES
  Future<void> handleReceivedImages(List<String> imagePaths) async {
    for (String path in imagePaths) {
      String? localFilePath = await checkAndSaveFile(
        path,
        imagePaths.indexOf(path),
      );

      if (localFilePath != null) {
        if (!localFilePaths.contains(localFilePath)) {
          localFilePaths.add(localFilePath);
        }
      } else {}
    }

    setState(() {
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share To'),
      ),
      body: SafeArea(
        child: !isData || isRegistration == null
            ? Center(
                child: LoadingIndicator(),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  return SingleChildScrollView(
                    child: isRegistration != null && isRegistration!
                        ? Center(
                            child: SizedBox(
                              height: 80,
                              child: Text(
                                'Your current membership does not support adding Posts',
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              // POST
                              AddBox(
                                context: context,
                                width: width,
                                icon: FeatherIcons.compass,
                                label: 'POST',
                                page: AddPostPage(
                                  imagePaths: localFilePaths,
                                ),
                              ),
                              // STATUS
                              AddBox(
                                context: context,
                                width: width,
                                icon: FeatherIcons.upload,
                                label: 'STATUS',
                                page: AddStatusPage(
                                  imagePaths: localFilePaths,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
      ),
    );
  }
}
