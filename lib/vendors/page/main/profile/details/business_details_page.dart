import 'dart:io';
import 'package:Localsearch/auth/login_page.dart';
import 'package:Localsearch/vendors/page/main/profile/details/location_page.dart';
import 'package:Localsearch/vendors/page/main/profile/details/membership_details_page.dart';
import 'package:Localsearch/vendors/register/business_social_media_page.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/vendors/page/main/profile/details/change_timings_page.dart';
import 'package:Localsearch/vendors/register/business_choose_category_page_1.dart';
import 'package:Localsearch/vendors/register/business_choose_category_page_2.dart';
import 'package:Localsearch/vendors/register/business_choose_category_page_3.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  double? latitude;
  double? longitude;
  bool isChangingName = false;
  bool isChangingAddress = false;
  bool isChangingDescription = false;
  bool isChangingImage = false;
  bool isGettingAddress = false;
  bool isSaving = false;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // CHANGE BUSINESS IMAGE
  Future<void> changeImage(String previousUrl) async {
    final images = await showImagePickDialog(context, true);
    String? businessPhotoUrl;
    if (images.isNotEmpty) {
      final im = images[0];
      try {
        setState(() {
          isChangingImage = true;
        });

        await storage.refFromURL(previousUrl).delete();

        Map<String, dynamic> updatedUserImage = {
          'Image': im.path,
        };

        Reference ref = storage
            .ref()
            .child('Vendor/Shops/Profile')
            .child(auth.currentUser!.uid);
        await ref
            .putFile(File(updatedUserImage['Image']!))
            .whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            businessPhotoUrl = value;
          });
        });
        updatedUserImage = {
          'Image': businessPhotoUrl,
        };
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .update(updatedUserImage);
        setState(() {
          isChangingImage = false;
        });
      } catch (e) {
        setState(() {
          isChangingImage = false;
          mySnackBar(context, e.toString());
        });
      }
    } else {
      if (mounted) {
        mySnackBar(context, 'Image not selected');
      }
    }
  }

  // SAVE
  Future<void> save(
    TextEditingController controller,
    String propertyName,
    bool isChanging,
  ) async {
    setState(() {
      isSaving = true;
      isChanging = true;
    });
    try {
      if (controller.text.isEmpty) {
        setState(() {
          isSaving = false;
          isChanging = false;
        });
        return mySnackBar(context, 'Enter $propertyName');
      } else {
        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .update({
          propertyName: controller.text.toString(),
        });

        setState(() {
          isSaving = false;
          isChanging = false;
        });
        if (mounted) {
          Navigator.of(context).popAndPushNamed('/businessDetails');
        }
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        isChanging = false;
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  // SHOW IMAGE
  Future<void> showImage(String imageUrl) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: ((context) {
        return Dialog(
          elevation: 20,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
            ),
          ),
        );
      }),
    );
  }

  // GET LIST
  String getList(List shopList) {
    String type = '';
    int i = 0;
    int length = shopList.length;
    for (var shopType in shopList) {
      if (i == length - 1) {
        type = type + shopType;
      } else {
        type = '$type$shopType, ';
      }

      i++;
    }

    return type;
  }

  // SIGN OUT
  Future<void> signOut() async {
    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text(
            'Sign Out?',
          ),
          content: const Text(
            'Are you sure,\nYou want to Sign Out?',
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
                try {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: ((context) => const LoginPage()),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  mySnackBar(context, e.toString());
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final shopStream = store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Business Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.025,
            vertical: width * 0.006125,
          ),
          child: LayoutBuilder(
            builder: ((context, constraints) {
              double width = constraints.maxWidth;
              double height = constraints.maxHeight;

              return StreamBuilder(
                  stream: shopStream,
                  builder: (context, snapshot) {
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
                      final shopData = snapshot.data!;

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // IMAGE
                            isChangingImage
                                ? Container(
                                    width: width * 0.3,
                                    height: width * 0.3,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: primaryDark,
                                      ),
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      GestureDetector(
                                        onTap: isSaving
                                            ? null
                                            : () async {
                                                await showImage(
                                                  shopData['Image'] ??
                                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                                );
                                              },
                                        child: CircleAvatar(
                                          radius: width * 0.15,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            shopData['Image'] ??
                                                'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/ProhibitionSign2.svg/800px-ProhibitionSign2.svg.png',
                                          ),
                                          backgroundColor: primary2,
                                        ),
                                      ),
                                      Positioned(
                                        right: -(width * 0.0015),
                                        bottom: -(width * 0.0015),
                                        child: IconButton.filledTonal(
                                          onPressed: () async {
                                            await changeImage(
                                                shopData['Image']);
                                          },
                                          icon: Icon(
                                            FeatherIcons.camera,
                                            size: width * 0.1,
                                          ),
                                          tooltip: 'Change Photo',
                                        ),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 32),

                            // OPEN / CLOSED
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: shopData['Open']
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.025,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: DropdownButton(
                                  value: shopData['Open'] ? "Open" : "Closed",
                                  hint: const Text(
                                    'Open / Closed',
                                    style: TextStyle(
                                      color: primaryDark2,
                                    ),
                                  ),
                                  underline: const SizedBox(),
                                  iconEnabledColor: primaryDark,
                                  dropdownColor: primary2,
                                  items: ['Open', 'Closed']
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList(),
                                  onChanged: (value) async {
                                    await store
                                        .collection('Business')
                                        .doc('Owners')
                                        .collection('Shops')
                                        .doc(auth.currentUser!.uid)
                                        .update({
                                      'Open': value == "Open" ? true : false,
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // NAME
                            Container(
                              width: width,
                              // height: isChangingName
                              //     ? width * 0.2775
                              //     : width * 0.175,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isChangingName
                                  ? TextField(
                                      controller: nameController,
                                      maxLength: 32,
                                      autofocus: true,
                                      onTapOutside: (event) =>
                                          FocusScope.of(context).unfocus(),
                                      decoration: InputDecoration(
                                        hintText: 'Change Name',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.0335,
                                          ),
                                          child: SizedBox(
                                            width: width * 0.725,
                                            child: AutoSizeText(
                                              shopData['Name'] ?? 'Name: N/A',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.06,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: width * 0.03,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isChangingName = true;
                                                isChangingAddress = false;
                                                isChangingDescription = false;
                                              });
                                            },
                                            icon: const Icon(FeatherIcons.edit),
                                            tooltip: 'Edit Name',
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 14),

                            // LOCATION
                            Container(
                              width: width,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => LocationPage(
                                        latitude: shopData['Latitude'],
                                        longitude: shopData['Longitude'],
                                      ),
                                    ),
                                  );
                                },
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  width: width,
                                  // height: 50,
                                  decoration: BoxDecoration(
                                    color: primary2.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    // horizontal: width * 0.006125,
                                    vertical: height * 0.0125,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.0335,
                                        ),
                                        child: Text(
                                          'Location',
                                          style: TextStyle(
                                            color: primaryDark,
                                            fontSize: width * 0.05,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        FeatherIcons.chevronRight,
                                        color: primaryDark,
                                        size: width * 0.09,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // DESCRIPTION
                            Container(
                              width: width,
                              // height: isChangingDescription
                              //     ? width * 0.2775
                              //     : width * 0.175,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: isChangingDescription
                                  ? TextField(
                                      controller: descriptionController,
                                      maxLength: 32,
                                      autofocus: true,
                                      onTapOutside: (event) =>
                                          FocusScope.of(context).unfocus(),
                                      decoration: InputDecoration(
                                        hintText: 'Change Description',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.0335,
                                          ),
                                          child: SizedBox(
                                            width: width * 0.725,
                                            child: AutoSizeText(
                                              shopData['Description'] ??
                                                  'Description: N/A',
                                              maxLines: 10,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.055,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: width * 0.03,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isChangingName = false;
                                                isChangingAddress = false;
                                                isChangingDescription = true;
                                              });
                                            },
                                            icon: const Icon(FeatherIcons.edit),
                                            tooltip: 'Edit Description',
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 14),

                            // TYPE
                            Container(
                              width: width,
                              // height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.855,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0335,
                                      ),
                                      child: SizedBox(
                                        width: width * 0.8,
                                        child: AutoSizeText(
                                          getList(shopData['Type']),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.055,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BusinessChooseCategoryPage1(
                                            isEditing: true,
                                            selectedShopTypes: shopData['Type'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(FeatherIcons.edit),
                                    tooltip: 'Edit Types',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // CATEGORIES
                            Container(
                              width: width,
                              // height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.855,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0335,
                                      ),
                                      child: SizedBox(
                                        width: width * 0.8,
                                        child: AutoSizeText(
                                          getList(shopData['Categories']),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.055,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BusinessChooseCategoryPage2(
                                            selectedTypes: shopData['Type'],
                                            isEditing: true,
                                            selectedCategories:
                                                shopData['Categories'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(FeatherIcons.edit),
                                    tooltip: 'Edit Categories',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // PRODUCTS
                            Container(
                              width: width,
                              // height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.855,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0335,
                                      ),
                                      child: SizedBox(
                                        width: width * 0.8,
                                        child: AutoSizeText(
                                          getList(shopData['Products']),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width * 0.055,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BusinessChooseCategoryPage3(
                                            selectedTypes: shopData['Type'],
                                            isEditing: true,
                                            selectedCategories:
                                                shopData['Categories'],
                                            selectedProducts:
                                                shopData['Products'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(FeatherIcons.edit),
                                    tooltip: 'Edit Products',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // GST
                            Container(
                              width: width,
                              // height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: width * 0.0335,
                                ),
                                child: SizedBox(
                                  width: width * 0.875,
                                  child: AutoSizeText(
                                    shopData['GSTNumber'] == '' ||
                                            shopData['GSTNumber'] == null
                                        ? 'GST Number: N/A'
                                        : 'GST: ${shopData['GSTNumber']}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // AADHAAR
                            Container(
                              width: width,
                              // height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: width * 0.0335,
                                ),
                                child: SizedBox(
                                  width: width * 0.875,
                                  child: AutoSizeText(
                                    shopData['AadhaarNumber'] == '' ||
                                            shopData['AadhaarNumber'] == null
                                        ? 'Aadhaar Number: N/A'
                                        : 'Aadhaar: ${shopData['AadhaarNumber']}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // INDUSTRY
                            // Container(
                            //   width: width,
                            //   // height: width * 0.16,
                            //   alignment: Alignment.centerLeft,
                            //   decoration: BoxDecoration(
                            //     color: primary2.withOpacity(0.9),
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   padding: EdgeInsets.only(
                            //     left: width * 0.0335,
                            //     top: height * 0.006125,
                            //     bottom: height * 0.006125,
                            //   ),
                            //   child: SizedBox(
                            //     width: width * 0.725,
                            //     child: Text(
                            //       shopData['Industry'] ?? 'Industry: N/A',
                            //       maxLines: 1,
                            //       overflow: TextOverflow.ellipsis,
                            //       style: TextStyle(
                            //         fontSize: width * 0.055,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 14),

                            // MEMBERSHIP
                            Container(
                              width: width,
                              // height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: shopData['MembershipName'] == 'Premium'
                                    ? const Color.fromRGBO(
                                        202,
                                        226,
                                        238,
                                        1,
                                      )
                                    : shopData['MembershipName'] == 'Gold'
                                        ? const Color.fromRGBO(
                                            253,
                                            243,
                                            154,
                                            1,
                                          )
                                        : shopData['MembershipName'] == 'Basic'
                                            ? const Color.fromRGBO(
                                                225,
                                                225,
                                                225,
                                                1,
                                              )
                                            : const Color.fromRGBO(
                                                200,
                                                200,
                                                200,
                                                1,
                                              ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: width * 0.033),
                                    child: SizedBox(
                                      width: width * 0.5975,
                                      child: AutoSizeText(
                                        shopData['MembershipName'] ?? 'N/A',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.055,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  MyTextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MembershipDetailsPage(),
                                        ),
                                      );
                                    },
                                    text: 'See Details',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // MEMBERSHIP END DATETIME
                            // Container(
                            //   width: width,
                            //   // height: width * 0.2,
                            //   alignment: Alignment.centerLeft,
                            //   decoration: BoxDecoration(
                            //     color: const Color.fromARGB(255, 255, 130, 121),
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   padding: EdgeInsets.only(
                            //     left: width * 0.0335,
                            //     top: height * 0.006125,
                            //     bottom: height * 0.006125,
                            //   ),
                            //   child: SizedBox(
                            //     width: width * 0.875,
                            //     child: Text(
                            //       'Membership Expiry Date - ${DateFormat('dd/M/yy').format((shopData['MembershipEndDateTime'] as Timestamp).toDate())}',
                            //       style: TextStyle(
                            //         fontSize: width * 0.055,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 14),

                            // TIMINGS
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChangeTimingsPage(),
                                  ),
                                );
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: width,
                                // height: 50,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  // horizontal: width * 0.006125,
                                  vertical: height * 0.0125,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0335,
                                      ),
                                      child: Text(
                                        'Timings',
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.05,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      FeatherIcons.chevronRight,
                                      color: primaryDark,
                                      size: width * 0.09,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 14),

                            // SOCIAL MEDIA
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BusinessSocialMediaPage(
                                      isChanging: true,
                                      instagram: shopData['Instagram'],
                                      facebook: shopData['Facebook'],
                                      website: shopData['Website'],
                                    ),
                                  ),
                                );
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: width,
                                // height: 50,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  // horizontal: width * 0.006125,
                                  vertical: height * 0.0125,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0335,
                                      ),
                                      child: Text(
                                        'Social Media Links',
                                        style: TextStyle(
                                          color: primaryDark,
                                          fontSize: width * 0.05,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      FeatherIcons.chevronRight,
                                      color: primaryDark,
                                      size: width * 0.09,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 14),

                            // DESCRIPTION
                            Container(
                              width: width,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                // horizontal: width * 0.006125,
                                vertical: height * 0.0125,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: width * 0.0335,
                                    ),
                                    child: SizedBox(
                                      width: width * 0.725,
                                      child: AutoSizeText(
                                        'Sign Out',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.055,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: width * 0.03,
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        await signOut();
                                      },
                                      icon: const Icon(
                                        FeatherIcons.logOut,
                                        color: Colors.red,
                                      ),
                                      color: Colors.red,
                                      tooltip: 'Sign Out',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isChangingName ||
                                    isChangingAddress ||
                                    isChangingDescription
                                ? SizedBox(height: 14)
                                : Container(),

                            // SAVE & CANCEL BUTTON
                            Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: isChangingName || isChangingDescription
                                  ? Column(
                                      children: [
                                        isSaving
                                            ? Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 0,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: buttonColor,
                                                ),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: white,
                                                  ),
                                                ))
                                            : MyButton(
                                                text: 'SAVE',
                                                onTap: () async {
                                                  if (isChangingName) {
                                                    await save(
                                                      nameController,
                                                      'Name',
                                                      isChangingName,
                                                    );
                                                  } else if (isChangingDescription) {
                                                    await save(
                                                      descriptionController,
                                                      'Description',
                                                      isChangingDescription,
                                                    );
                                                  }
                                                },
                                                isLoading: false,
                                                horizontalPadding: 0,
                                              ),
                                        const SizedBox(height: 12),
                                        MyButton(
                                          text: 'CANCEL',
                                          onTap: () {
                                            setState(() {
                                              isChangingName = false;
                                              isChangingAddress = false;
                                              isChangingAddress = false;
                                            });
                                          },
                                          isLoading: false,
                                          horizontalPadding: 0,
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryDark,
                      ),
                    );
                  });
            }),
          ),
        ),
      ),
    );
  }
}
