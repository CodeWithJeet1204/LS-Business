import 'dart:convert';
import 'package:Localsearch/vendors/page/main/main_page.dart';
import 'package:Localsearch/widgets/show_loading_dialog.dart';
import 'package:Localsearch/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/pick_location.dart';
import 'package:Localsearch/widgets/snack_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

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
        mySnackBar(context, 'Some error occured');
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
    });

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
    });

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Location'),
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
          MyTextButton(
            onPressed: () async {
              if (displayDetectCity == null && cityPickLocation == null) {
                return mySnackBar(context, 'Detect / Pick Location');
              }
              await showLoadingDialog(
                context,
                () async {
                  await done();
                },
              );
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
                      ? CircularProgressIndicator()
                      : cityPickLocation != null
                          ? Icon(FeatherIcons.mapPin)
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
              Text('OR'),
              SizedBox(height: width * 0.025),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isPickingCity = true;
                  });
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => PickLocationPage(),
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
                      ? CircularProgressIndicator()
                      : cityDetectLocation != null
                          ? Icon(FeatherIcons.map)
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
    );
  }
}
