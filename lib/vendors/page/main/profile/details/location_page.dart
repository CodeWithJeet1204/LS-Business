import 'dart:convert';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/pick_location.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  late double latitude;
  late double longitude;
  String? displayDetectCity;
  String? cityDetectLocation;
  String? cityPickLocation;
  bool isDetectingCity = false;
  String? address;

  // INIT STATE
  @override
  void initState() {
    latitude = widget.latitude;
    longitude = widget.longitude;
    getAddress(true);
    super.initState();
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
  Future<void> getAddress(bool fromInitState, {bool? isDetect}) async {
    const apiKey = 'AIzaSyA-CD3MgDBzAsjmp_FlDbofynMMmW6fPsU';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final myAddress = data['results'][0]['address_components'];

          setState(() {
            address =
                '${myAddress[0]['long_name']}, ${myAddress[1]['long_name']}, ${myAddress[2]['long_name']}';
            if (!fromInitState && isDetect != null && isDetect) {
              displayDetectCity =
                  '${myAddress[0]['long_name']}, ${myAddress[1]['long_name']}, ${myAddress[2]['long_name']}';
            }
          });

          if (!fromInitState) {
            String? myCityName;

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

            await store
                .collection('Business')
                .doc('Owners')
                .collection('Shops')
                .doc(auth.currentUser!.uid)
                .update({
              'Latitude': latitude,
              'Longitude': longitude,
              'City': isDetect! ? cityDetectLocation : cityPickLocation,
            });
          }
        } else {
          if (mounted) {
            mySnackBar(context, 'Failed to get location');
          }
        }
      } else {
        if (mounted) {
          mySnackBar(context, 'Failed to load data');
        }
      }
    } catch (e) {
      setState(() {
        address = e.toString();
      });
      setState(() {
        address = 'Couldn\'t get Address';
      });
      if (mounted) {
        mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
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
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.0125),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: width,
                      decoration: BoxDecoration(
                        color: primary2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(width * 0.025),
                      child: address == null
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              address!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                    SizedBox(height: height * 0.0125),
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

                                await getAddress(false, isDetect: true);
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
                                          displayDetectCity != null
                                              ? 'Detected'
                                              : 'Detect Location',
                                          maxLines: cityDetectLocation != null
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
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PickLocationPage(),
                                ),
                              )
                                  .then(
                                (pickedData) async {
                                  final cityName = pickedData[0] as String;
                                  final coordinates = pickedData[1] as LatLong;

                                  setState(() {
                                    latitude = coordinates.latitude;
                                    longitude = coordinates.longitude;
                                    cityPickLocation = cityName;
                                  });

                                  await getAddress(false, isDetect: false);
                                  setState(() {
                                    cityDetectLocation = null;
                                  });
                                },
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primary2,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: EdgeInsets.all(width * 0.025),
                              child: cityDetectLocation != null
                                  ? const Icon(FeatherIcons.map)
                                  : AutoSizeText(
                                      cityPickLocation != null
                                          ? 'Picked'
                                          : 'Pick Location 🗺️',
                                      maxLines: 1,
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
