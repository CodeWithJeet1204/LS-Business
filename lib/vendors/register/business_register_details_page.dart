import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:Localsearch/vendors/models/industry_segments.dart';
import 'package:Localsearch/vendors/register/business_verification_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/button.dart';
import 'package:Localsearch/widgets/image_pick_dialog.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:Localsearch/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BusinessRegisterDetailsPage extends StatefulWidget {
  const BusinessRegisterDetailsPage({
    super.key,
  });

  @override
  State<BusinessRegisterDetailsPage> createState() =>
      _BusinessRegisterDetailsPageState();
}

class _BusinessRegisterDetailsPageState
    extends State<BusinessRegisterDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final GlobalKey<FormState> businessFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isNext = false;
  String? selectedIndustrySegment;
  bool isImageSelected = false;
  bool isGettingAddress = false;
  File? _image;
  double? latitude;
  double? longitude;
  String? city;
  String? uploadImagePath;

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    // gstController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // SELECT IMAGE
  Future<void> selectImage() async {
    final images = await showImagePickDialog(context, true);
    final im = images[0];
    setState(() {
      _image = File(im.path);
      isImageSelected = true;
    });
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
            city = 'NONE';
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
  Future<void> getAddress(double lat, double long) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=AIzaSyA-CD3MgDBzAsjmp_FlDbofynMMmW6fPsU';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String? cityName;

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        for (var result in data['results']) {
          for (var component in result['address_components']) {
            if (component['types'].contains('locality')) {
              cityName = component['long_name'];
              break;
            } else if (component['types'].contains('sublocality')) {
              cityName = component['long_name'];
            } else if (component['types'].contains('neighborhood')) {
              cityName = component['long_name'];
            } else if (component['types'].contains('route')) {
              cityName = component['long_name'];
            } else if (component['types']
                .contains('administrative_area_level_3')) {
              cityName = component['long_name'];
            }
          }
          if (cityName != null) break;
        }

        setState(() {
          city = cityName;
        });
      } else {
        mySnackBar(context, 'Some error occured');
        setState(() {
          city = 'Get Location';
        });
      }
    }
  }

  // SAVE
  Future<void> save() async {
    if (businessFormKey.currentState!.validate()) {
      if (city == null) {
        return mySnackBar(context, 'Get Location');
      }
      try {
        String? businessPhotoUrl;

        setState(() {
          isNext = true;
        });

        if (_image != null) {
          uploadImagePath = _image!.path;
          Reference ref =
              storage.ref().child('VendorShops').child(auth.currentUser!.uid);
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
          'Name': nameController.text.toString(),
          'Latitude': latitude,
          'Longitude': longitude,
          'Open': true,
          'viewsTimestamp': [],
          'followersTimestamp': {},
          // 'GSTNumber': gstController.text.toString(),
          'Description': descriptionController.text.toString(),
          'Industry': selectedIndustrySegment,
          'Image': _image != null
              ? businessPhotoUrl
              : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1fDf705o-VZ3lVxTLh0jLPyFApbnwGoNHhSpwODOC0g&s',
          'City': city,
        });

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => const BusinessVerificationPage()),
            ),
          );
        }

        setState(() {
          isNext = false;
        });
      } catch (e) {
        setState(() {
          isNext = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Business Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const SizedBox(height: 100),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.875,
              //   child: const HeadText(
              //     text: 'BUSINESS\nDETAILS',
              //   ),
              // ),
              const SizedBox(height: 140),

              // IMAGE
              isImageSelected
                  ? Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.13885,
                          backgroundImage: FileImage(_image!),
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.camera_alt_outlined),
                          iconSize: MediaQuery.of(context).size.width * 0.1,
                          tooltip: 'Change Shop Picture',
                          onPressed: () async {
                            await selectImage();
                          },
                          color: primaryDark,
                        ),
                      ],
                    )
                  : CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.13885,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          size: MediaQuery.of(context).size.width * 0.166,
                        ),
                        onPressed: () async {
                          await selectImage();
                        },
                      ),
                    ),
              const SizedBox(height: 12),
              Form(
                key: businessFormKey,
                child: Column(
                  children: [
                    // SHOP NAME
                    MyTextFormField(
                      hintText: 'Shop Name',
                      controller: nameController,
                      borderRadius: 12,
                      horizontalPadding:
                          MediaQuery.of(context).size.width * 0.055,
                      verticalPadding:
                          MediaQuery.of(context).size.width * 0.01125,
                      autoFillHints: const [AutofillHints.streetAddressLevel1],
                    ),

                    // LOCATION
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isGettingAddress = true;
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
                          isGettingAddress = false;
                        });
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primary2,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(width * 0.025),
                          margin:
                              EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: isGettingAddress
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  city ?? 'Get Location',
                                  maxLines: city != null ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    color: primaryDark2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // INDUSTRY SEGMENT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primary2,
                              width: 1,
                            ),
                          ),
                        ),
                        elevation: 0,
                        isDense: false,
                        menuMaxHeight: 700,
                        itemHeight: 48,
                        dropdownColor: primary2,
                        hint: const Text(
                          'Select Industry Segment',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        items: industrySegments
                            .map((element) => DropdownMenuItem(
                                  value: element,
                                  child: Text(
                                    element,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIndustrySegment = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DESCRIPTION
                    MyTextFormField(
                      hintText: 'Description',
                      controller: descriptionController,
                      borderRadius: 12,
                      horizontalPadding:
                          MediaQuery.of(context).size.width * 0.055,
                      autoFillHints: null,
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 20),

                    // NEXT
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MyButton(
                        text: 'NEXT',
                        onTap: () async {
                          await save();
                        },
                        isLoading: isNext,
                        horizontalPadding:
                            MediaQuery.of(context).size.width * 0.055,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
