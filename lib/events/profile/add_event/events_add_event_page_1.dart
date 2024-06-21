import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:localy/events/profile/add_event/events_add_event_page_2.dart';
import 'package:localy/events/provider/picked_location_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/pick_location.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:localy/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EventsAddEventPage1 extends StatefulWidget {
  const EventsAddEventPage1({super.key});

  @override
  State<EventsAddEventPage1> createState() => _EventsAddEventPage1State();
}

class _EventsAddEventPage1State extends State<EventsAddEventPage1> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final List<File> _image = [];
  int currentImageIndex = 0;
  bool isFit = false;
  double? latitude;
  double? longitude;
  Map<String, dynamic>? address;
  bool gettingLocation = false;
  String? type;
  bool isNext = false;

  final List<String> suggestions = [
    'Conference',
    'Competitions',
    'Seminars',
    'Workshops',
    'Trade Shows/Exhibitions',
    'Networking Events',
    'Product Launches',
    'Corporate Meetings',
    'Party',
    'Weddings',
    'Receptions',
    'Galas',
    'Concerts',
    'Festivals',
    'Movie Screenings',
    'Live Performances',
    'Comedy Shows',
    'Classes',
    'Lectures',
    'Educational Workshops',
    'Training Sessions',
    'Webinars',
    'Academic Conferences',
    'Sports Tournaments',
    'Marathons',
    'Fitness Classes',
    'Yoga Retreats',
    'Cycling Events',
    'Fitness Competitions',
    'Art Exhibitions',
    'Museum Tours',
    'Cultural Festivals',
    'Heritage Events',
    'Food and Drink Festivals',
    'Music and Dance Performances',
    'Charity Galas',
    'Fundraising Dinners',
    'Auctions',
    'Charity Runs/Walks',
    'Benefit Concerts',
    'Parades',
    'Street Fairs',
    'Farmers Markets',
    'Community Clean-up Events',
    'Neighborhood Block Parties',
    'Volunteer Events',
    'Worship Services',
    'Religious Festivals',
    'Spiritual Retreats',
    'Meditation Sessions',
    'Religious Conferences',
  ];

  // ADD EVENT IMAGE
  Future<void> addEventImages() async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      setState(() {
        _image.add(File(im.path));
        currentImageIndex = _image.length - 1;
      });
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // REMOVE EVENT IMAGE
  void removeEventImages(int index) {
    setState(() {
      _image.removeAt(index);
    });
  }

  // CHANGE IMAGE FIT
  void changeFit() {
    setState(() {
      isFit = !isFit;
    });
  }

  // CHANGE TYPE
  Future<void> changeType(String currentType) async {
    setState(() {
      type = currentType;
    });
  }

  // NEXT
  void next() {
    if (_image.isEmpty) {
      return mySnackBar(context, 'Select an Image');
    }
    if (nameController.text.isEmpty) {
      return mySnackBar(context, 'Enter Event Name');
    }
    if (typeController.text.isEmpty) {
      return mySnackBar(context, 'Enter Event Type');
    }
    if (latitude == null || longitude == null) {
      return mySnackBar(context, 'Select Location');
    }

    setState(() {
      isNext = true;
    });

    Map<String, dynamic> data = {
      'eventName': nameController.text,
      'eventType': typeController.text,
      'eventLatitude': latitude,
      'eventLongitude': longitude,
      'imageUrl': _image,
      'eventComments': {},
    };

    setState(() {
      isNext = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => EventsAddEventPage2(
              data: data,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pickLocationProvider = Provider.of<PickLocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          overflow: TextOverflow.ellipsis,
          'Basic Info',
        ),
        actions: [
          MyTextButton(
            onPressed: next,
            text: 'NEXT',
            textColor: primaryDark2,
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              isNext ? const Size(double.infinity, 10) : const Size(0, 0),
          child: isNext ? const LinearProgressIndicator() : Container(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.0125,
            vertical: MediaQuery.of(context).size.width * 0.006125,
          ),
          child: LayoutBuilder(
            builder: ((context, constraints) {
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // IMAGE
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.006125,
                      ),
                      child: _image.isNotEmpty
                          ? Column(
                              children: [
                                Center(
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      GestureDetector(
                                        onTap: changeFit,
                                        child: Container(
                                          height: width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: primaryDark,
                                              width: 3,
                                            ),
                                            image: DecorationImage(
                                              fit: isFit ? null : BoxFit.cover,
                                              image: FileImage(
                                                _image[currentImageIndex],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: width * 0.015,
                                          right: width * 0.015,
                                        ),
                                        child: IconButton.filledTonal(
                                          onPressed: currentImageIndex !=
                                                  _image.length - 1
                                              ? () {
                                                  removeEventImages(
                                                    currentImageIndex,
                                                  );
                                                }
                                              : null,
                                          icon: Icon(
                                            FeatherIcons.x,
                                            size: width * 0.1,
                                          ),
                                          tooltip: 'Remove Image',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: primaryDark,
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      height: width * 0.225,
                                      width: width * 0.775,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _image.length,
                                        itemBuilder: ((context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                currentImageIndex = index;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Container(
                                                height: width * 0.18,
                                                width: width * 0.18,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 0.3,
                                                    color: primaryDark,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: FileImage(
                                                      _image[index],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.0275),
                                    Container(
                                      height: width * 0.19,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: primaryDark,
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        splashRadius: width * 0.095,
                                        onPressed: () async {
                                          await addEventImages();
                                        },
                                        icon: Icon(
                                          FeatherIcons.plus,
                                          size: width * 0.115,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : SizedOverflowBox(
                              size: Size(width, width),
                              child: InkWell(
                                onTap: () async {
                                  await addEventImages();
                                },
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Container(
                                  width: width,
                                  height: width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryDark,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FeatherIcons.upload,
                                        size: width * 0.4,
                                      ),
                                      SizedBox(height: width * 0.09),
                                      Text(
                                        'Select Image',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.09,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 28),

                    Column(
                      children: [
                        // NAME
                        MyTextFormField(
                          hintText: 'Event Name',
                          controller: nameController,
                          borderRadius: 8,
                          horizontalPadding: 0,
                        ),

                        const SizedBox(height: 16),

                        // TYPE
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: primary3,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: DropdownButton(
                                value: type,
                                hint: const Text(
                                  'Select Type',
                                  style: TextStyle(
                                    color: primaryDark2,
                                  ),
                                ),
                                underline: const SizedBox(),
                                iconEnabledColor: primaryDark,
                                dropdownColor: primary2,
                                items: suggestions
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    type = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // LOCATION
                        GestureDetector(
                          onTap: () async {
                            setState(() {});
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: ((context) => PickLocationPage()),
                              ),
                            );
                            setState(() {
                              latitude = pickLocationProvider.latitude;
                              longitude = pickLocationProvider.longitude;
                              address = pickLocationProvider.address;
                            });
                            setState(() {});
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
                              margin: EdgeInsets.symmetric(
                                horizontal: width * 0.025,
                              ),
                              child: gettingLocation
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text(
                                      address == null
                                          ? 'Pick Location'
                                          : '${address!['road'] != null ? address!['road'] : ''}${address!['road'] != null ? ',' : ''} ${address!['neighbourhood'] != null ? address!['neighbourhood'] : ''}${address!['neighbourhood'] != null ? ',' : ''} ${address!['city'] != null ? address!['city'] : ''}',
                                      maxLines: 3,
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
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
