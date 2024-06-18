import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:localy/events/profile/events_all_events_page.dart';
import 'package:localy/vendors/page/main/profile/view%20page/product/image_view.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/image_pick_dialog.dart';
import 'package:localy/widgets/pick_location.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EventPage extends StatefulWidget {
  const EventPage({
    super.key,
    required this.eventId,
  });

  final String eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final editKey = GlobalKey<FormState>();
  final editController = TextEditingController();
  final typeController = TextEditingController();
  bool isEditing = false;
  int _currentIndex = 0;
  bool isImageChanging = false;
  bool isChangingType = false;
  bool isFirstImageRemoved = false;

  // ADD IMAGE
  Future<void> addImage(List images) async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      try {
        setState(() {
          isImageChanging = true;
        });
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('Events/${widget.eventId}')
            .child(const Uuid().v4());
        await ref.putFile(File(im.path)).whenComplete(() async {
          await ref.getDownloadURL().then((value) async {
            images.add(value);
            await store.collection('Events').doc(widget.eventId).update({
              'imageUrl': images,
            });
          });
        });

        setState(() {
          isImageChanging = false;
        });

        if (mounted) {
          // Navigator.of(context).pop();
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: ((context) => EventPage(
          //           eventId: widget.eventId,
          //         )),
          //   ),
          // );
        }
      } catch (e) {
        setState(() {
          isImageChanging = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // CHANGE IMAGE
  Future<void> changeImage(String e, int index, List images) async {
    final XFile? im = await showImagePickDialog(context);
    if (im != null) {
      try {
        setState(() {
          isImageChanging = true;
        });
        Reference ref = FirebaseStorage.instance.refFromURL(images[index]);
        await images.removeAt(index);
        await ref.putFile(File(im.path));
        setState(() {
          isImageChanging = false;
        });
      } catch (e) {
        setState(() {
          isImageChanging = false;
        });
        if (mounted) {
          mySnackBar(context, e.toString());
        }
      }
    } else {
      if (mounted) {
        mySnackBar(context, 'Select an Image');
      }
    }
  }

  // REMOVE IMAGE
  Future<void> removeImage(String e, List images) async {
    if (images.indexOf(e) == 0) {
      setState(() {
        isFirstImageRemoved = true;
      });
    }
    await FirebaseStorage.instance
        .refFromURL(images[images.indexOf(e)])
        .delete();
    images.remove(e);
    await store.collection('Events').doc(widget.eventId).update({
      'imageUrl': images,
    });
  }

  // EDIT
  Future<void> edit(
    String propertyValue,
    bool inputType,
  ) async {
    await showDialog(
        context: context,
        builder: (context) {
          final eventStream =
              store.collection('Events').doc(widget.eventId).snapshots();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              height: 180,
              child: StreamBuilder(
                  stream: eventStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Something went wrong',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Form(
                          key: editKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 80,
                                child: TextFormField(
                                  controller: editController,
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  keyboardType: inputType
                                      ? TextInputType.text
                                      : TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Enter $propertyValue',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (propertyValue != 'productPrice') {
                                      if (value != null && value.length >= 2) {
                                        return null;
                                      } else {
                                        return 'Min 2 chars required';
                                      }
                                    } else {
                                      if (value == null ||
                                          value == '0' ||
                                          value == '') {
                                        editController.text = '';
                                        return null;
                                      } else {
                                        if (double.parse(value) > 0) {
                                          return null;
                                        } else {
                                          return 'Min price is Rs. 1';
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                              MyButton(
                                text: 'SAVE',
                                onTap: () async {
                                  if (editKey.currentState!.validate()) {
                                    setState(() {
                                      isEditing = true;
                                    });
                                    try {
                                      await store
                                          .collection('Events')
                                          .doc(widget.eventId)
                                          .update({
                                        propertyValue:
                                            editController.text.toString(),
                                      });

                                      editController.clear();

                                      setState(() {
                                        isEditing = false;
                                      });
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isEditing = false;
                                      });
                                      if (context.mounted) {
                                        mySnackBar(
                                          context,
                                          e.toString(),
                                        );
                                      }
                                    }
                                  }
                                },
                                isLoading: isEditing,
                                horizontalPadding: 0,
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          );
        });
  }

  // GET ADDRESS
  Future<String> getAddress(double lat, double long) async {
    print('started');
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return '${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';
  }

  // CHANGE DATE
  Future<void> changeDate(DateTime startDate, String date) async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
    );

    if (selected != null) {
      if (selected.isBefore(startDate) && date == 'endDate') {
        if (mounted) {
          return mySnackBar(context, 'End Date should be after Start Date');
        }
      }
      await store.collection('Events').doc(widget.eventId).update({
        date: selected,
      });
    }
  }

  // GET TIME OF DAY
  String getTimeString(String timeString) {
    String cleanedString =
        timeString.replaceAll('TimeOfDay(', '').replaceAll(')', '');

    List<String> parts = cleanedString.split(':');

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);

    final now = DateTime.now();
    final time = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(time);
  }

  // CHANGE TIME
  Future<void> changeTime(String time) async {
    TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected != null) {
      await store.collection('Events').doc(widget.eventId).update({
        time: selected.toString(),
      });
    }
  }

  // GET SUGGESTIONS
  List<String> getSuggestions(String pattern) {
    final List<String> suggestions = [
      'Conference',
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

    return suggestions
        .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
        .toList();
  }

  // CHANGE TYPE
  Future<void> changeType() async {
    if (typeController.text.isNotEmpty) {
      await store.collection('Events').doc(widget.eventId).update({
        'eventType': typeController.text,
      });
      setState(() {
        isChangingType = false;
      });
    } else {
      return mySnackBar(context, 'Select Type');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventStream =
        store.collection('Events').doc(widget.eventId).snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isFirstImageRemoved
              ? () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: ((context) => const EventsAllEventsPage()),
                    ),
                  );
                }
              : () {
                  Navigator.of(context).pop();
                },
          icon: const Icon(
            FeatherIcons.arrowLeft,
          ),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.0125,
          ),
          child: LayoutBuilder(
            builder: ((context, constraints) {
              final width = constraints.maxWidth;

              return StreamBuilder(
                  stream: eventStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }

                    if (snapshot.hasData) {
                      final data = snapshot.data!;

                      final List images = data['imageUrl'];

                      final String name = data['eventName'];

                      final String type = data['eventType'];

                      final double eventLatitude = data['eventLatitude'];
                      final double eventLongitude = data['eventLongitude'];

                      final String contactHelp = data['contactHelp'];

                      final String organizerName = data['organizerName'];

                      final Timestamp startDate = data['startDate'];
                      final Timestamp endDate = data['endDate'];

                      final String startTime = data['startTime'];
                      final String endTime = data['endTime'];

                      final String? weekendStartTime = data['weekendStartTime'];
                      final String? weekendEndTime = data['weekendEndTime'];

                      final String? ticketPrice = data['ticketPrice'];
                      final String? ticketEarlyBirdPrice =
                          data['ticketEarlyBirdPrice'];
                      final String? ticketVIPPrice = data['ticketVIPPrice'];
                      final String? ticketGroupPrice = data['ticketGroupPrice'];

                      final String description = data['eventDescription'];

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IMAGES
                            CarouselSlider(
                              items: images
                                  .map(
                                    (e) => Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: primaryDark2,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: isImageChanging
                                              ? const CircularProgressIndicator()
                                              : GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: ((context) =>
                                                            ImageView(
                                                              imagesUrl: images,
                                                            )),
                                                      ),
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image:
                                                              NetworkImage(e),
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        isImageChanging
                                            ? Container()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: width * 0.0125,
                                                      top: width * 0.0125,
                                                    ),
                                                    child:
                                                        IconButton.filledTonal(
                                                      onPressed: () async {
                                                        await changeImage(
                                                          e,
                                                          images.indexOf(e),
                                                          images,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        FeatherIcons.camera,
                                                        size: width * 0.1,
                                                      ),
                                                      tooltip: 'Change Image',
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right: width * 0.0125,
                                                      top: width * 0.0125,
                                                    ),
                                                    child:
                                                        IconButton.filledTonal(
                                                      onPressed:
                                                          images.last != e
                                                              ? () async {
                                                                  await removeImage(
                                                                    e,
                                                                    images,
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
                                      ],
                                    ),
                                  )
                                  .toList(),
                              options: CarouselOptions(
                                enableInfiniteScroll:
                                    images.length > 1 ? true : false,
                                aspectRatio: 1.2,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                            ),

                            // DOTS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                images.length > 1
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: width * 0.033,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: (images).map((e) {
                                            int index = images.indexOf(e);

                                            return Container(
                                              width: _currentIndex == index
                                                  ? 12
                                                  : 8,
                                              height: _currentIndex == index
                                                  ? 12
                                                  : 8,
                                              margin: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _currentIndex == index
                                                    ? primaryDark
                                                    : primary2,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : const SizedBox(height: 40),
                                GestureDetector(
                                  onTap: () async {
                                    await addImage(images);
                                  },
                                  child: Container(
                                    width: width * 0.275,
                                    height: width * 0.1,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Add Image',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Icon(FeatherIcons.plus),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(),

                            // NAME
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.785,
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await edit(
                                      'eventName',
                                      true,
                                    );
                                  },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit Name',
                                ),
                              ],
                            ),

                            const Divider(),

                            // TYPE
                            isChangingType
                                ? SizedBox(
                                    width: width,
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: width * 0.75,
                                          child: TypeAheadField(
                                            controller: typeController,
                                            onSelected: (value) {
                                              typeController.text =
                                                  value.toString();
                                            },
                                            suggestionsCallback: (pattern) {
                                              return getSuggestions(pattern);
                                            },
                                            builder: (context, controller,
                                                focusNode) {
                                              return TextField(
                                                controller: controller,
                                                focusNode: focusNode,
                                                onTapOutside: (event) =>
                                                    FocusScope.of(context)
                                                        .unfocus(),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color:
                                                          Colors.cyan.shade700,
                                                    ),
                                                  ),
                                                  hintText: 'Type',
                                                ),
                                              );
                                            },
                                            itemBuilder: (context, value) {
                                              return ListTile(
                                                title: Text(value.toString()),
                                              );
                                            },
                                          ),
                                        ),
                                        MyTextButton(
                                          onPressed: () async {
                                            await changeType();
                                          },
                                          text: 'Save',
                                          textColor: primaryDark,
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.0225,
                                        ),
                                        child: SizedBox(
                                          width: width * 0.785,
                                          child: Text(
                                            type,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.055,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            isChangingType = true;
                                          });
                                        },
                                        icon: Icon(
                                          FeatherIcons.edit,
                                          size: width * 0.066,
                                        ),
                                        tooltip: 'Edit Type',
                                      ),
                                    ],
                                  ),

                            const Divider(),

                            // ADDRESS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.785,
                                    child: FutureBuilder(
                                        future: getAddress(
                                          eventLatitude,
                                          eventLongitude,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                              'Something went wrong with address',
                                            );
                                          }

                                          if (snapshot.hasData) {
                                            return Text(
                                              snapshot.data!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: primaryDark,
                                                fontSize: width * 0.055,
                                              ),
                                            );
                                          }

                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: ((context) => PickLocationPage(
                                              eventId: widget.eventId,
                                            )),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit Name',
                                ),
                              ],
                            ),

                            const Divider(),

                            // CONTACT HELP
                            contactHelp == ''
                                ? Container()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.0225,
                                        ),
                                        child: SizedBox(
                                          width: width * 0.785,
                                          child: Text(
                                            contactHelp,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.055,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await edit(
                                            'contactHelp',
                                            true,
                                          );
                                        },
                                        icon: Icon(
                                          FeatherIcons.edit,
                                          size: width * 0.066,
                                        ),
                                        tooltip: 'Edit Name',
                                      ),
                                    ],
                                  ),

                            contactHelp == '' ? Container() : const Divider(),

                            // ORGANIZER NAME
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.785,
                                    child: Text(
                                      organizerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await edit(
                                      'organizerName',
                                      true,
                                    );
                                  },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit Name',
                                ),
                              ],
                            ),

                            const Divider(),

                            // DATE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: width * 0.45,
                                  decoration: BoxDecoration(
                                    color: primary3,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.0225,
                                          right: width * 0.0225,
                                          top: 8,
                                        ),
                                        child: Text(
                                          'Start Date',
                                          style: TextStyle(
                                            fontSize: width * 0.0425,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              overflow: TextOverflow.ellipsis,
                                              DateFormat('d MMM yy')
                                                  .format(startDate.toDate())
                                                  .toString(),
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontSize: width * 0.05,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await changeDate(
                                                  startDate.toDate(),
                                                  'startDate',
                                                );
                                              },
                                              icon: Icon(
                                                FeatherIcons.edit,
                                                size: width * 0.066,
                                              ),
                                              tooltip: 'Change Date',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: width * 0.45,
                                  decoration: BoxDecoration(
                                    color: primary3,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.0225,
                                          right: width * 0.0225,
                                          top: 8,
                                        ),
                                        child: Text(
                                          'End Date',
                                          style: TextStyle(
                                            fontSize: width * 0.0425,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              overflow: TextOverflow.ellipsis,
                                              DateFormat('d MMM yy')
                                                  .format(endDate.toDate())
                                                  .toString(),
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontSize: width * 0.05,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await changeDate(
                                                  startDate.toDate(),
                                                  'endDate',
                                                );
                                              },
                                              icon: Icon(
                                                FeatherIcons.edit,
                                                size: width * 0.066,
                                              ),
                                              tooltip: 'Change Date',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // TIMING
                            Center(
                              child: Container(
                                width: width * 0.95,
                                decoration: BoxDecoration(
                                  color: primary3,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      'Timing',
                                      style: TextStyle(
                                        color: primaryDark2,
                                        fontSize: width * 0.04,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await changeTime('startTime');
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                overflow: TextOverflow.ellipsis,
                                                getTimeString(startTime)
                                                    .toString(),
                                                style: TextStyle(
                                                  color: primaryDark,
                                                  fontSize: width * 0.055,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.05),
                                              const Icon(
                                                FeatherIcons.edit,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: width * 0.05,
                                          height: 1,
                                          color: darkGrey,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await changeTime('endTime');
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                overflow: TextOverflow.ellipsis,
                                                getTimeString(endTime)
                                                    .toString(),
                                                style: TextStyle(
                                                  color: primaryDark,
                                                  fontSize: width * 0.055,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.05),
                                              const Icon(
                                                FeatherIcons.edit,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            weekendStartTime == null || weekendEndTime == null
                                ? Container()
                                : const SizedBox(height: 8),

                            // WEEKEND TIMING
                            weekendStartTime == null || weekendEndTime == null
                                ? Container()
                                : Center(
                                    child: AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Container(
                                        width: width * 0.95,
                                        decoration: BoxDecoration(
                                          color: primary3,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.025,
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              overflow: TextOverflow.ellipsis,
                                              'Weekend Timing',
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontSize: width * 0.04,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    await changeTime(
                                                        'weekendStartTime');
                                                  },
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getTimeString(
                                                            weekendStartTime),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark,
                                                          fontSize:
                                                              width * 0.06,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.05,
                                                      ),
                                                      const Icon(
                                                        FeatherIcons.edit,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    await changeTime(
                                                        'weekendEndTime');
                                                  },
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getTimeString(
                                                            weekendEndTime),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark,
                                                          fontSize:
                                                              width * 0.06,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.05,
                                                      ),
                                                      const Icon(
                                                        FeatherIcons.edit,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                            const Divider(),

                            // TICKETS
                            Padding(
                              padding: EdgeInsets.only(left: width * 0.0225),
                              child: const Text(
                                'Tickets',
                                style: TextStyle(),
                              ),
                            ),

                            // BASE PRICE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.66,
                                    child: Text(
                                      ticketPrice == null
                                          ? 'Base Price - X'
                                          : 'Base Price - Rs. $ticketPrice',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: ticketPrice == null
                                            ? darkGrey
                                            : primaryDark,
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: ticketPrice == null
                                      ? null
                                      : () async {
                                          await edit(
                                            'ticketPrice',
                                            true,
                                          );
                                        },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit Base Price',
                                ),
                                Checkbox(
                                    activeColor: primaryDark,
                                    checkColor: white,
                                    value: ticketPrice != null,
                                    onChanged: (value) async {
                                      if (ticketPrice != null) {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketPrice': null,
                                        });
                                      } else {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketPrice': '0',
                                        });
                                      }
                                    }),
                              ],
                            ),

                            const Divider(),

                            // EARLY BIRD PRICE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.66,
                                    child: Text(
                                      ticketEarlyBirdPrice == null
                                          ? 'Early Bird Price - X'
                                          : 'Early Bird Price - Rs. $ticketEarlyBirdPrice',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: ticketEarlyBirdPrice == null
                                            ? darkGrey
                                            : primaryDark,
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: ticketEarlyBirdPrice == null
                                      ? null
                                      : () async {
                                          await edit(
                                            'ticketEarlyBirdPrice',
                                            true,
                                          );
                                        },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit Early Bird Price',
                                ),
                                Checkbox(
                                    activeColor: primaryDark,
                                    checkColor: white,
                                    value: ticketEarlyBirdPrice != null,
                                    onChanged: (value) async {
                                      if (ticketEarlyBirdPrice != null) {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketEarlyBirdPrice': null,
                                        });
                                      } else {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketEarlyBirdPrice': '0',
                                        });
                                      }
                                    }),
                              ],
                            ),

                            const Divider(),

                            // VIP PRICE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.66,
                                    child: Text(
                                      ticketVIPPrice == null
                                          ? 'VIP Price - X'
                                          : 'VIP Price - Rs. $ticketVIPPrice',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: ticketVIPPrice == null
                                            ? darkGrey
                                            : primaryDark,
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: ticketVIPPrice == null
                                      ? null
                                      : () async {
                                          await edit(
                                            'ticketVIPPrice',
                                            true,
                                          );
                                        },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit VIP Price',
                                ),
                                Checkbox(
                                    activeColor: primaryDark,
                                    checkColor: white,
                                    value: ticketVIPPrice != null,
                                    onChanged: (value) async {
                                      if (ticketVIPPrice != null) {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketVIPPrice': null,
                                        });
                                      } else {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketVIPPrice': '0',
                                        });
                                      }
                                    }),
                              ],
                            ),

                            const Divider(),

                            // GROUP PRICE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.66,
                                    child: Text(
                                      ticketGroupPrice == null
                                          ? 'Group Price - X'
                                          : 'Group Price - Rs. $ticketGroupPrice',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: ticketGroupPrice == null
                                            ? darkGrey
                                            : primaryDark,
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: ticketGroupPrice == null
                                      ? null
                                      : () async {
                                          await edit(
                                            'ticketGroupPrice',
                                            true,
                                          );
                                        },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit Group Price',
                                ),
                                Checkbox(
                                    activeColor: primaryDark,
                                    checkColor: white,
                                    value: ticketGroupPrice != null,
                                    onChanged: (value) async {
                                      if (ticketGroupPrice != null) {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketGroupPrice': null,
                                        });
                                      } else {
                                        await store
                                            .collection('Events')
                                            .doc(widget.eventId)
                                            .update({
                                          'ticketGroupPrice': '0',
                                        });
                                      }
                                    }),
                              ],
                            ),

                            const Divider(),

                            // DESCRIPTION
                            Padding(
                              padding: EdgeInsets.only(left: width * 0.0225),
                              child: const Text(
                                'Description',
                                style: TextStyle(),
                              ),
                            ),

                            // DESCRIPTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0225,
                                  ),
                                  child: SizedBox(
                                    width: width * 0.785,
                                    child: Text(
                                      description == ''
                                          ? '<Empty>'
                                          : description,
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontSize: width * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await edit(
                                      'eventDescription',
                                      true,
                                    );
                                  },
                                  icon: Icon(
                                    FeatherIcons.edit,
                                    size: width * 0.066,
                                  ),
                                  tooltip: 'Edit Name',
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  });
            }),
          ),
        ),
      ),
    );
  }
}
