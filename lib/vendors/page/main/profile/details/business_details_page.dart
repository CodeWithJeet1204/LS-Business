import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
    XFile? im = await showImagePickDialog(context);
    String? businessPhotoUrl;
    if (im != null) {
      try {
        setState(() {
          isChangingImage = true;
        });

        await storage.refFromURL(previousUrl).delete();

        Map<String, dynamic> updatedUserImage = {
          'Image': im.path,
        };

        Reference ref =
            storage.ref().child('VendorShops').child(auth.currentUser!.uid);
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
            .doc(FirebaseAuth.instance.currentUser!.uid)
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

  // GET LOCATION
  Future<Position?> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) {
        mySnackBar(context, 'Turn ON Location Services to Continue');
      }
      return null;
    } else {
      LocationPermission permission = await Geolocator.checkPermission();

      // LOCATION PERMISSION GIVEN
      Future<Position> locationPermissionGiven() async {
        return await Geolocator.getCurrentPosition();
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            mySnackBar(context, 'Pls give Location Permission to Continue');
          }
        }
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            latitude = 0;
            longitude = 0;
          });

          setState(() {
            isGettingAddress = false;
          });
          if (mounted) {
            mySnackBar(context, 'Sorry, without location we can\'t Continue');
          }
        } else {
          return await locationPermissionGiven();
        }
      } else {
        return await locationPermissionGiven();
      }
    }
    return null;
  }

  // GET ADDRESS
  Future<String> getAddress(double lat, double long) async {
    const apiKey = 'AIzaSyA-CD3MgDBzAsjmp_FlDbofynMMmW6fPsU';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['results'][0]['formatted_address'];
        } else {
          throw Exception('Failed to get location');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception(e.toString());
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
            .doc(FirebaseAuth.instance.currentUser!.uid)
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final shopStream = store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(FirebaseAuth.instance.currentUser!.uid)
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

                            // NAME
                            Container(
                              width: width,
                              height: isChangingName
                                  ? width * 0.2775
                                  : width * 0.175,
                              alignment: Alignment.center,
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
                                            left: width * 0.055,
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
                            GestureDetector(
                              onTap: shopData['Latitude'] != 0 &&
                                      shopData['Longitude'] != 0
                                  ? null
                                  : () async {
                                      setState(() {
                                        isChangingAddress = true;
                                      });

                                      double? latitude;
                                      double? longitude;

                                      await getLocation().then((value) async {
                                        if (value != null) {
                                          setState(() {
                                            latitude = value.latitude;
                                            longitude = value.longitude;
                                          });

                                          await store
                                              .collection('Users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            'Latitude': latitude,
                                            'Longitude': longitude,
                                          });

                                          if (latitude != null &&
                                              longitude != null) {
                                            await getAddress(
                                              latitude!,
                                              longitude!,
                                            );
                                          }
                                        }
                                      });
                                      setState(() {
                                        isChangingAddress = false;
                                      });
                                    },
                              child: Container(
                                width: width,
                                height: width * 0.175,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: isChangingAddress
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.0125),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: width * 0.8,
                                                  child: const Text(
                                                      'Getting Location'),
                                                ),
                                                const Text('-- km'),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                  FeatherIcons.mapPin),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: width * 0.055,
                                            ),
                                            child: SizedBox(
                                              width: width * 0.725,
                                              child: FutureBuilder(
                                                  future: shopData[
                                                                  'Latitude'] ==
                                                              0 &&
                                                          shopData[
                                                                  'Longitude'] ==
                                                              0
                                                      ? null
                                                      : getAddress(
                                                          shopData['Latitude'],
                                                          shopData[
                                                              'Longitude']),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                        snapshot.error
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.045,
                                                          color: primaryDark2,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      );
                                                    }

                                                    if (snapshot.hasData) {
                                                      return Text(
                                                        shopData['Latitude'] ==
                                                                    0 &&
                                                                shopData[
                                                                        'Longitude'] ==
                                                                    0
                                                            ? 'NONE'
                                                            : snapshot.data!,
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.045,
                                                          color: primaryDark2,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      );
                                                    }

                                                    return Text(
                                                      'Click on icon to get Location',
                                                      style: TextStyle(
                                                        fontSize: width * 0.04,
                                                        color: primaryDark2
                                                            .withOpacity(0.75),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: width * 0.03,
                                            ),
                                            child: IconButton(
                                              onPressed: () async {
                                                setState(() {
                                                  isChangingAddress = true;
                                                });

                                                double? latitude;
                                                double? longitude;

                                                await getLocation()
                                                    .then((value) async {
                                                  if (value != null) {
                                                    setState(() {
                                                      latitude = value.latitude;
                                                      longitude =
                                                          value.longitude;
                                                    });

                                                    await store
                                                        .collection('Business')
                                                        .doc('Owners')
                                                        .collection('Shops')
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .update({
                                                      'Latitude': latitude,
                                                      'Longitude': longitude,
                                                    });

                                                    if (latitude != null &&
                                                        longitude != null) {
                                                      await getAddress(
                                                        latitude!,
                                                        longitude!,
                                                      );
                                                    }
                                                  }
                                                });
                                                setState(() {
                                                  isChangingAddress = false;
                                                });
                                              },
                                              icon: const Icon(
                                                FeatherIcons.refreshCw,
                                              ),
                                              tooltip: 'Relocate',
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // DESCRIPTION
                            Container(
                              width: width,
                              height: isChangingDescription
                                  ? width * 0.2775
                                  : width * 0.175,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
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
                                            left: width * 0.055,
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
                              height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.855,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.055,
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
                                            preSelected: shopData['Type'],
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
                              height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.855,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.055,
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
                              height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.855,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.055,
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
                              height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: width * 0.055,
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

                            // AADHAR
                            Container(
                              width: width,
                              height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: width * 0.055,
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
                            Container(
                              width: width,
                              height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: primary2.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.only(
                                left: width * 0.055,
                              ),
                              child: SizedBox(
                                width: width * 0.725,
                                child: Text(
                                  shopData['Industry'] ?? 'Industry: N/A',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.055,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // OPEN / CLOSED
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
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
                            ),
                            const SizedBox(height: 16),

                            // MEMBERSHIP
                            Container(
                              width: width,
                              height: width * 0.16,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: shopData['MembershipName'] == 'PREMIUM'
                                    ? const Color.fromRGBO(202, 226, 238, 1)
                                    : shopData['MembershipName'] == 'GOLD'
                                        ? const Color.fromRGBO(253, 243, 154, 1)
                                        : const Color.fromRGBO(
                                            167, 167, 167, 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: width * 0.05),
                                child: SizedBox(
                                  width: width * 0.725,
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
                            ),
                            const SizedBox(height: 14),

                            // MEMBERSHIP END DATETIME
                            Container(
                              width: width,
                              height: width * 0.2,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 130, 121),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.only(
                                left: width * 0.055,
                              ),
                              child: SizedBox(
                                width: width * 0.875,
                                child: Text(
                                  'Membership Expiry Date - ${DateFormat('dd/M/yy').format((shopData['MembershipEndDateTime'] as Timestamp).toDate())}',
                                  style: TextStyle(
                                    fontSize: width * 0.055,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // TIMINGS
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangeTimingsPage()),
                                );
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: width,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(width * 0.0125),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Timings',
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.05,
                                        fontWeight: FontWeight.w500,
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

                            SizedBox(height: 16),

                            // SAVE & CANCEL BUTTON
                            Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: isChangingName ||
                                      isChangingAddress ||
                                      isChangingDescription
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
                                                  } else if (isChangingAddress) {
                                                    await save(
                                                      addressController,
                                                      'Address',
                                                      isChangingAddress,
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
