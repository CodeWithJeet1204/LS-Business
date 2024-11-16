import 'dart:convert';
import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/pick_location.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class GetLocationPage extends StatefulWidget {
  const GetLocationPage({super.key});

  @override
  State<GetLocationPage> createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  double? latitude;
  double? longitude;
  String? displayDetectCity;
  String? cityDetectLocation;
  String? cityPickLocation;
  bool isDetectingCity = false;
  bool isPickingCity = false;
  bool isSaving = false;
  bool isDialog = false;

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
            cityDetectLocation = 'NONE';
          });

          setState(() {
            isDetectingCity = false;
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
          cityDetectLocation = 'Detect Location';
        });
      }
    }
  }

  // DONE
  Future<void> done() async {
    setState(() {
      isSaving = true;
      isDialog = true;
    });

    try {
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'Latitude': latitude,
        'Longitude': longitude,
        'City': cityDetectLocation ?? cityPickLocation,
      });

      setState(() {
        isSaving = false;
        isDialog = false;
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        isDialog = false;
      });
      if (mounted) {
        mySnackBar(context, 'Error occured: ${e.toString()}');
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 0.5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Get Location'),
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
              MyTextButton(
                onTap: () async {
                  if (displayDetectCity == null && cityPickLocation == null) {
                    return mySnackBar(context, 'Detect / Pick Location');
                  }
                  await done();
                },
                text: 'DONE',
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
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
                          ? const CircularProgressIndicator()
                          : cityPickLocation != null
                              ? const Icon(FeatherIcons.mapPin)
                              : AutoSizeText(
                                  displayDetectCity ?? 'Detect Location',
                                  maxLines: cityDetectLocation != null ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    color: primaryDark2,
                                  ),
                                ),
                    ),
                  ),
                  SizedBox(height: width * 0.025),
                  const Text('OR'),
                  SizedBox(height: width * 0.025),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isPickingCity = true;
                      });
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => const PickLocationPage(),
                        ),
                      )
                          .then(
                        (pickedData) {
                          final cityName = pickedData[0] as String;
                          final coordinates = pickedData[1] as LatLong;

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
                          ? const CircularProgressIndicator()
                          : cityDetectLocation != null
                              ? const Icon(FeatherIcons.map)
                              : AutoSizeText(
                                  cityPickLocation ?? 'Pick Location 🗺️',
                                  maxLines: cityPickLocation != null ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    color: primaryDark2,
                                  ),
                                ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
