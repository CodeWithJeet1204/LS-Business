import 'dart:convert';
import 'dart:io';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:ls_business/widgets/pick_location.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ls_business/vendors/page/register/business_verification_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/image_pick_dialog.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class BusinessRegisterDetailsPage extends StatefulWidget {
  const BusinessRegisterDetailsPage({
    super.key,
    required this.fromMainPage,
  });

  final bool fromMainPage;

  @override
  State<BusinessRegisterDetailsPage> createState() =>
      _BusinessRegisterDetailsPageState();
}

class _BusinessRegisterDetailsPageState
    extends State<BusinessRegisterDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final businessFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  File? image;
  double? latitude;
  double? longitude;
  String? displayDetectCity;
  String? cityDetectLocation;
  String? cityPickLocation;
  String? uploadImagePath;
  bool isImageSelected = false;
  bool isDetectingCity = false;
  bool isPickingCity = false;
  bool isNext = false;
  bool isDialog = false;
  // String? selectedIndustrySegment;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    // gstController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // SELECT IMAGE
  Future<void> selectImage() async {
    final images = await showImagePickDialog(context, true);
    final im = images[0];
    setState(() {
      image = File(im.path);
      isImageSelected = true;
    });
  }

  // GET LOCATION
  Future<Position?> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          isDetectingCity = false;
        });
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
            cityDetectLocation = 'NONE';
            isDetectingCity = false;
          });
          if (mounted) {
            mySnackBar(context, 'Sorry, without location we can\'t Continue');
            return null;
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
  Future<void> getAddress(double lat, double long) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=AIzaSyA-CD3MgDBzAsjmp_FlDbofynMMmW6fPsU';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String? myCityName;

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        setState(() {
          displayDetectCity = data['results'][0]['formatted_address'];
        });

        for (var result in data['results']) {
          for (var component in result['address_components']) {
            if (component['types'].contains('locality')) {
              myCityName = component['long_name'];
              break;
            } else if (component['types'].contains('sublocality')) {
              myCityName = component['long_name'];
            } else if (component['types'].contains('neighborhood')) {
              myCityName = component['long_name'];
            } else if (component['types'].contains('route')) {
              myCityName = component['long_name'];
            } else if (component['types']
                .contains('administrative_area_level_3')) {
              myCityName = component['long_name'];
            }
          }
          if (myCityName != null) break;
        }

        setState(() {
          cityDetectLocation = myCityName;
        });
      } else {
        if (mounted) {
          mySnackBar(context, 'Some error occured');
        }
        setState(() {
          isDetectingCity = false;
          cityDetectLocation = 'Detect Location';
        });
      }
    }
  }

  // NEXT
  Future<void> next() async {
    if (businessFormKey.currentState!.validate()) {
      if (cityDetectLocation == null && cityPickLocation == null) {
        return mySnackBar(context, 'Get Location');
      }
      try {
        String? businessPhotoUrl;

        setState(() {
          isNext = true;
          isDialog = true;
        });
        if (image != null) {
          uploadImagePath = image!.path;
          Reference ref = storage
              .ref()
              .child('Vendor/Shops/Profile')
              .child(auth.currentUser!.uid);
          await ref.putFile(File(uploadImagePath!)).whenComplete(() async {
            await ref.getDownloadURL().then((value) {
              businessPhotoUrl = value;
            });
          });
        }

        await store
            .collection('Business')
            .doc('Owners')
            .collection('Shops')
            .doc(auth.currentUser!.uid)
            .update({
          'Name': nameController.text.toString().trim(),
          'Image': businessPhotoUrl ??
              'https://img.freepik.com/premium-vector/shop-clipart-cartoon-style-vector-illustration_761413-4813.jpg?semt=ais_hybrid',
          'Latitude': latitude,
          'Longitude': longitude,
          'City': cityDetectLocation ?? cityPickLocation,
          'Address': addressController.text.toString().trim(),
          'Open': true,
          'viewsTimestamp': [],
          'followersTimestamp': {},
          'Description': descriptionController.text.toString().trim(),
          // 'GSTNumber': gstController.text.toString().trim(),
          // 'Industry': selectedIndustrySegment,
        });

        if (mounted) {
          if (widget.fromMainPage) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainPage(),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BusinessVerificationPage(),
              ),
            );
          }
        }

        setState(() {
          isNext = false;
          isDialog = false;
        });
      } catch (e) {
        setState(() {
          isNext = false;
          isDialog = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        progressIndicator: const LoadingIndicator(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Business Details'),
            actions: [
              IconButton(
                onPressed: () async {
                  await showYouTubePlayerDialog(
                    context,
                    'business_register_details_page',
                  );
                },
                icon: const Icon(
                  Icons.question_mark_outlined,
                ),
                tooltip: 'Help',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // const SizedBox(height: 100),
                  // SizedBox(
                  //   width: width * 0.875,
                  //   child: const HeadText(
                  //     text: 'BUSINESS\nDETAILS',
                  //   ),
                  // ),
                  // const SizedBox(height: 140),

                  // IMAGE
                  isImageSelected
                      ? Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: width * 0.13885,
                              backgroundImage: FileImage(image!),
                            ),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.camera_alt_outlined),
                              iconSize: width * 0.1,
                              tooltip: 'Change Shop Image',
                              onPressed: () async {
                                await selectImage();
                              },
                              color: primaryDark,
                            ),
                          ],
                        )
                      : CircleAvatar(
                          radius: width * 0.13885,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              size: width * 0.166,
                            ),
                            onPressed: () async {
                              await selectImage();
                            },
                          ),
                        ),

                  const SizedBox(height: 16),

                  Form(
                    key: businessFormKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.025),
                      child: Column(
                        children: [
                          // SHOP NAME
                          MyTextFormField(
                            hintText: 'Shop Name*',
                            controller: nameController,
                            borderRadius: 12,
                            autoFillHints: const [],
                          ),
                          const SizedBox(height: 12),

                          // ADDRESS
                          MyTextFormField(
                            hintText: 'Address*',
                            controller: addressController,
                            borderRadius: 12,
                            autoFillHints: const [],
                          ),
                          const SizedBox(height: 12),

                          // LOCATION
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: cityDetectLocation != null ? 3 : 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      isDetectingCity = true;
                                    });

                                    await getLocation().then((value) async {
                                      if (value != null) {
                                        setState(() {
                                          latitude = value.latitude;
                                          longitude = value.longitude;
                                        });
                                      }

                                      await getAddress(latitude!, longitude!);
                                    });

                                    setState(() {
                                      cityPickLocation = null;
                                      isDetectingCity = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: primary2,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: EdgeInsets.all(width * 0.025),
                                    child: isDetectingCity
                                        ? const LoadingIndicator()
                                        : cityPickLocation != null
                                            ? const Icon(FeatherIcons.mapPin)
                                            : AutoSizeText(
                                                displayDetectCity ??
                                                    'Detect Location',
                                                maxLines:
                                                    cityDetectLocation != null
                                                        ? 1
                                                        : 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: width * 0.045,
                                                  color: primaryDark2,
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.0125),
                              Expanded(
                                flex: cityPickLocation != null ? 3 : 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      isPickingCity = true;
                                    });
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PickLocationPage(),
                                      ),
                                    )
                                        .then(
                                      (pickedData) {
                                        final cityName =
                                            pickedData[0] as String;
                                        final coordinates =
                                            pickedData[1] as LatLong;

                                        setState(() {
                                          latitude = coordinates.latitude;
                                          longitude = coordinates.longitude;
                                          cityPickLocation = cityName;
                                        });
                                      },
                                    );
                                    setState(() {
                                      cityDetectLocation = null;
                                      isPickingCity = false;
                                      isDetectingCity = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: primary2,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: EdgeInsets.all(width * 0.025),
                                    child: isPickingCity
                                        ? const LoadingIndicator()
                                        : cityDetectLocation != null
                                            ? const Icon(FeatherIcons.map)
                                            : AutoSizeText(
                                                cityPickLocation ??
                                                    'Pick Location 🗺️',
                                                maxLines:
                                                    cityPickLocation != null
                                                        ? 1
                                                        : 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: width * 0.045,
                                                  color: primaryDark2,
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // INDUSTRY SEGMENT
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   child: DropdownButtonFormField(
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //         borderSide: BorderSide(
                          //           color: primary2,
                          //           width: 1,
                          //         ),
                          //       ),
                          //     ),
                          //     elevation: 0,
                          //     isDense: false,
                          //     menuMaxHeight: 700,
                          //     itemHeight: 48,
                          //     dropdownColor: primary2,
                          //     hint: const Text(
                          //       'Select Industry Segment',
                          //       maxLines: 1,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //     items: industrySegments
                          //         .map((element) => DropdownMenuItem(
                          //               value: element,
                          //               child: Text(
                          //                 element,
                          //                 maxLines: 1,
                          //                 overflow: TextOverflow.ellipsis,
                          //               ),
                          //             ))
                          //         .toList(),
                          //     onChanged: (value) {
                          //       setState(() {
                          //         selectedIndustrySegment = value;
                          //       });
                          //     },
                          //   ),
                          // ),
                          // const SizedBox(height: 20),

                          // DESCRIPTION
                          TextFormField(
                            autofocus: false,
                            controller: descriptionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 50,
                            minLines: 1,
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.cyan.shade700,
                                ),
                              ),
                              hintText: 'Description',
                            ),
                            maxLength: 500,
                          ),
                          const SizedBox(height: 12),

                          // NEXT
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: MyButton(
                              text: widget.fromMainPage ? 'DONE' : 'NEXT',
                              onTap: () async {
                                await next();
                              },
                              horizontalPadding: width * 0.055,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
