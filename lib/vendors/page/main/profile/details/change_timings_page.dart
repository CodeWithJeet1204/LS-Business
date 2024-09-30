import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class ChangeTimingsPage extends StatefulWidget {
  const ChangeTimingsPage({super.key});

  @override
  State<ChangeTimingsPage> createState() => _ChangeTimingsPageState();
}

class _ChangeTimingsPageState extends State<ChangeTimingsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  TimeOfDay? weekdayStartTime;
  TimeOfDay? weekdayEndTime;
  TimeOfDay? saturdayStartTime;
  TimeOfDay? saturdayEndTime;
  TimeOfDay? sundayStartTime;
  TimeOfDay? sundayEndTime;
  bool isWeekday = false;
  bool isSaturday = false;
  bool isSunday = false;
  bool isNext = false;
  bool isChanging = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final vendorSnap = await store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .get();

    final vendorData = vendorSnap.data()!;

    final firebaseWeekdayStartTime = vendorData['weekdayStartTime'];
    final firebaseWeekdayEndTime = vendorData['weekdayEndTime'];
    final firebaseSaturdayStartTime = vendorData['saturdayStartTime'];
    final firebaseSaturdayEndTime = vendorData['saturdayEndTime'];
    final firebaseSundayStartTime = vendorData['sundayStartTime'];
    final firebaseSundayEndTime = vendorData['sundayEndTime'];

    setState(() {
      if (firebaseWeekdayStartTime != null && firebaseWeekdayEndTime != null) {
        isWeekday = true;
      }
      if (firebaseSaturdayStartTime != null &&
          firebaseSaturdayEndTime != null) {
        isSaturday = true;
      }
      if (firebaseSundayStartTime != null && firebaseSundayEndTime != null) {
        isSunday = true;
      }
    });

    setState(() {
      if (firebaseWeekdayStartTime != null && firebaseWeekdayEndTime != null) {
        weekdayStartTime = getTimeOfDay(firebaseWeekdayStartTime);
        weekdayEndTime = getTimeOfDay(firebaseWeekdayEndTime);
      }
      if (firebaseSaturdayStartTime != null &&
          firebaseSaturdayEndTime != null) {
        saturdayStartTime = getTimeOfDay(firebaseSaturdayStartTime);
        saturdayEndTime = getTimeOfDay(firebaseSaturdayEndTime);
      }
      if (firebaseSundayStartTime != null && firebaseSundayEndTime != null) {
        sundayStartTime = getTimeOfDay(firebaseSundayStartTime);
        sundayEndTime = getTimeOfDay(firebaseSundayEndTime);
      }
    });
  }

  // GET TIMEOFDAY
  TimeOfDay getTimeOfDay(String time) {
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  // SELECT WEEKDAY START TIME
  Future<void> selectWeekdayStartTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 8,
        minute: 0,
      ),
    );

    if (selectedTime != null) {
      setState(() {
        weekdayStartTime = selectedTime;
      });
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'weekdayStartTime': convertWeekdayTimeOfDay()[0],
      });
    }
  }

  // SELECT WEEKDAY END TIME
  Future<void> selectWeekdayEndTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 20,
        minute: 0,
      ),
    );

    if (selectedTime != null) {
      setState(() {
        weekdayEndTime = selectedTime;
      });
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'weekdayEndTime': convertWeekdayTimeOfDay()[1],
      });
    }
  }

  // SELECT SATURDAY START TIME
  Future<void> selectSaturdayStartTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 8,
        minute: 0,
      ),
    );

    if (selectedTime != null) {
      setState(() {
        saturdayStartTime = selectedTime;
      });
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'saturdayStartTime': convertSaturdayTimeOfDay()[0],
      });
    }
  }

  // SELECT SATURDAY END TIME
  Future<void> selectSaturdayEndTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 20,
        minute: 0,
      ),
    );

    if (selectedTime != null) {
      setState(() {
        saturdayEndTime = selectedTime;
      });
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'saturdayEndTime': convertSaturdayTimeOfDay()[1],
      });
    }
  }

  // SELECT SUNDAY START TIME
  Future<void> selectSundayStartTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 8,
        minute: 0,
      ),
    );

    if (selectedTime != null) {
      setState(() {
        sundayStartTime = selectedTime;
      });
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'sundayStartTime': convertSundayTimeOfDay()[0],
      });
    }
  }

  // SELECT SUNDAY END TIME
  Future<void> selectSundayEndTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 20,
        minute: 0,
      ),
    );

    if (selectedTime != null) {
      setState(() {
        sundayEndTime = selectedTime;
      });
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'sundayEndTime': convertSundayTimeOfDay()[1],
      });
    }
  }

  // CONVERT WEEKDAY TIMEOFDAY
  List<String?> convertWeekdayTimeOfDay() {
    String weekdayStartTimeString =
        '${weekdayStartTime!.hour.toString().padLeft(2, '0')}:${weekdayStartTime!.minute.toString().padLeft(2, '0')}';

    String weekdayEndTimeString =
        '${weekdayEndTime!.hour.toString().padLeft(2, '0')}:${weekdayEndTime!.minute.toString().padLeft(2, '0')}';

    return [weekdayStartTimeString, weekdayEndTimeString];
  }

  // CONVERT SATURDAY TIMEOFDAY
  List<String?> convertSaturdayTimeOfDay() {
    String? saturdayStartTimeString = saturdayStartTime != null
        ? '${saturdayStartTime!.hour.toString().padLeft(2, '0')}:${saturdayStartTime!.minute.toString().padLeft(2, '0')}'
        : null;

    String? saturdayEndTimeString = saturdayEndTime != null
        ? '${saturdayEndTime!.hour.toString().padLeft(2, '0')}:${saturdayEndTime!.minute.toString().padLeft(2, '0')}'
        : null;

    return [saturdayStartTimeString, saturdayEndTimeString];
  }

  // CONVERT SUNDAY TIMEOFDAY
  List<String?> convertSundayTimeOfDay() {
    String? sundayStartTimeString = sundayStartTime != null
        ? '${sundayStartTime!.hour.toString().padLeft(2, '0')}:${sundayStartTime!.minute.toString().padLeft(2, '0')}'
        : null;

    String? sundayEndTimeString = sundayEndTime != null
        ? '${sundayEndTime!.hour.toString().padLeft(2, '0')}:${sundayEndTime!.minute.toString().padLeft(2, '0')}'
        : null;

    return [sundayStartTimeString, sundayEndTimeString];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Timings'),
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
          padding: EdgeInsets.all(width * 0.0125),
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // WEEKDAY
                  ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                    backgroundColor: primary2.withOpacity(0.25),
                    collapsedBackgroundColor: primary2.withOpacity(0.33),
                    textColor: primaryDark.withOpacity(0.9),
                    collapsedTextColor: primaryDark,
                    iconColor: primaryDark2.withOpacity(0.9),
                    collapsedIconColor: primaryDark2,
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide(
                        color: primaryDark.withOpacity(0.1),
                      ),
                    ),
                    collapsedShape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide(
                        color: primaryDark.withOpacity(0.33),
                      ),
                    ),
                    title: Text(
                      'Mon - Fri',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Checkbox(
                        activeColor: primaryDark,
                        checkColor: white,
                        value: isWeekday,
                        onChanged: (value) async {
                          if (value == false) {
                            weekdayStartTime = null;
                            weekdayEndTime = null;
                            await store
                                .collection('Business')
                                .doc('Owners')
                                .collection('Shops')
                                .doc(auth.currentUser!.uid)
                                .update({
                              'weekdayStartTime': null,
                              'weekdayEndTime': null,
                            });
                          }
                          setState(() {
                            isWeekday = value!;
                          });
                        }),
                    children: [
                      // TIMES
                      !isWeekday
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.all(width * 0.0125),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // START TIME
                                  GestureDetector(
                                    onTap: () async {
                                      await selectWeekdayStartTime();
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      decoration: BoxDecoration(
                                        color: primary3,
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Start Time',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                weekdayStartTime != null
                                                    ? IconButton(
                                                        onPressed: () async {
                                                          await selectWeekdayStartTime();
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.edit,
                                                          size: width * 0.066,
                                                        ),
                                                        tooltip: 'Change Time',
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          weekdayStartTime == null
                                              ? MyTextButton(
                                                  onPressed: () async {
                                                    await selectWeekdayStartTime();
                                                  },
                                                  text: 'Select Time',
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * 0.036,
                                                    bottom: width * 0.025,
                                                  ),
                                                  child: Text(
                                                    weekdayStartTime!
                                                        .format(context)
                                                        .toString()
                                                        .trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.066,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // END TIME
                                  GestureDetector(
                                    onTap: () async {
                                      await selectWeekdayEndTime();
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      decoration: BoxDecoration(
                                        color: primary3,
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'End Time',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                weekdayEndTime != null
                                                    ? IconButton(
                                                        onPressed: () async {
                                                          await selectWeekdayEndTime();
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.edit,
                                                          size: width * 0.066,
                                                        ),
                                                        tooltip: 'Change Time',
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          weekdayEndTime == null
                                              ? MyTextButton(
                                                  onPressed: () async {
                                                    await selectWeekdayEndTime();
                                                  },
                                                  text: 'Select Time',
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * 0.0366,
                                                    bottom: width * 0.025,
                                                  ),
                                                  child: Text(
                                                    weekdayEndTime!
                                                        .format(context)
                                                        .toString()
                                                        .trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.066,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // SATURDAY
                  ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                    backgroundColor: primary2.withOpacity(0.25),
                    collapsedBackgroundColor: primary2.withOpacity(0.33),
                    textColor: primaryDark.withOpacity(0.9),
                    collapsedTextColor: primaryDark,
                    iconColor: primaryDark2.withOpacity(0.9),
                    collapsedIconColor: primaryDark2,
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide(
                        color: primaryDark.withOpacity(0.1),
                      ),
                    ),
                    collapsedShape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide(
                        color: primaryDark.withOpacity(0.33),
                      ),
                    ),
                    title: Text(
                      'Saturday',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Checkbox(
                        activeColor: primaryDark,
                        checkColor: white,
                        value: isSaturday,
                        onChanged: (value) async {
                          if (value == false) {
                            saturdayStartTime = null;
                            saturdayEndTime = null;
                            await store
                                .collection('Business')
                                .doc('Owners')
                                .collection('Shops')
                                .doc(auth.currentUser!.uid)
                                .update({
                              'saturdayStartTime': null,
                              'saturdayEndTime': null,
                            });
                          }
                          setState(() {
                            isSaturday = value!;
                          });
                        }),
                    children: [
                      // TIMES
                      !isSaturday
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.all(width * 0.0125),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // START TIME
                                  GestureDetector(
                                    onTap: () async {
                                      await selectSaturdayStartTime();
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      decoration: BoxDecoration(
                                        color: primary3,
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Start Time',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                saturdayStartTime != null
                                                    ? IconButton(
                                                        onPressed: () async {
                                                          await selectSaturdayStartTime();
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.edit,
                                                          size: width * 0.066,
                                                        ),
                                                        tooltip: 'Change Time',
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          saturdayStartTime == null
                                              ? MyTextButton(
                                                  onPressed: () async {
                                                    await selectSaturdayStartTime();
                                                  },
                                                  text: 'Select Time',
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * 0.036,
                                                    bottom: width * 0.025,
                                                  ),
                                                  child: Text(
                                                    saturdayStartTime!
                                                        .format(context)
                                                        .toString()
                                                        .trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.066,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // END TIME
                                  GestureDetector(
                                    onTap: () async {
                                      await selectSaturdayEndTime();
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      decoration: BoxDecoration(
                                        color: primary3,
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'End Time',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                saturdayEndTime != null
                                                    ? IconButton(
                                                        onPressed: () async {
                                                          await selectSaturdayEndTime();
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.edit,
                                                          size: width * 0.066,
                                                        ),
                                                        tooltip: 'Change Time',
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          saturdayEndTime == null
                                              ? MyTextButton(
                                                  onPressed: () async {
                                                    await selectSaturdayEndTime();
                                                  },
                                                  text: 'Select Time',
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * 0.0366,
                                                    bottom: width * 0.025,
                                                  ),
                                                  child: Text(
                                                    saturdayEndTime!
                                                        .format(context)
                                                        .toString()
                                                        .trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.066,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // SUNDAY
                  ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                    backgroundColor: primary2.withOpacity(0.25),
                    collapsedBackgroundColor: primary2.withOpacity(0.33),
                    textColor: primaryDark.withOpacity(0.9),
                    collapsedTextColor: primaryDark,
                    iconColor: primaryDark2.withOpacity(0.9),
                    collapsedIconColor: primaryDark2,
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide(
                        color: primaryDark.withOpacity(0.1),
                      ),
                    ),
                    collapsedShape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide(
                        color: primaryDark.withOpacity(0.33),
                      ),
                    ),
                    title: Text(
                      'Sunday',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Checkbox(
                        activeColor: primaryDark,
                        checkColor: white,
                        value: isSunday,
                        onChanged: (value) async {
                          if (value == false) {
                            sundayStartTime = null;
                            sundayEndTime = null;
                            await store
                                .collection('Business')
                                .doc('Owners')
                                .collection('Shops')
                                .doc(auth.currentUser!.uid)
                                .update({
                              'saturdayStartTime': null,
                              'saturdayEndTime': null,
                            });
                          }
                          setState(() {
                            isSunday = value!;
                          });
                        }),
                    children: [
                      // TIMES
                      !isSunday
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.all(width * 0.0125),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // START TIME
                                  GestureDetector(
                                    onTap: () async {
                                      await selectSundayStartTime();
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      decoration: BoxDecoration(
                                        color: primary3,
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Start Time',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                sundayStartTime != null
                                                    ? IconButton(
                                                        onPressed: () async {
                                                          await selectSundayStartTime();
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.edit,
                                                          size: width * 0.066,
                                                        ),
                                                        tooltip: 'Change Time',
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          sundayStartTime == null
                                              ? MyTextButton(
                                                  onPressed: () async {
                                                    await selectSundayStartTime();
                                                  },
                                                  text: 'Select Time',
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * 0.036,
                                                    bottom: width * 0.025,
                                                  ),
                                                  child: Text(
                                                    sundayStartTime!
                                                        .format(context)
                                                        .toString()
                                                        .trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.066,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // END TIME
                                  GestureDetector(
                                    onTap: () async {
                                      await selectSundayEndTime();
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      decoration: BoxDecoration(
                                        color: primary3,
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'End Time',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                sundayEndTime != null
                                                    ? IconButton(
                                                        onPressed: () async {
                                                          await selectSundayEndTime();
                                                        },
                                                        icon: Icon(
                                                          FeatherIcons.edit,
                                                          size: width * 0.066,
                                                        ),
                                                        tooltip: 'Change Time',
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          sundayEndTime == null
                                              ? MyTextButton(
                                                  onPressed: () async {
                                                    await selectSundayEndTime();
                                                  },
                                                  text: 'Select Time',
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * 0.0366,
                                                    bottom: width * 0.025,
                                                  ),
                                                  child: Text(
                                                    sundayEndTime!
                                                        .format(context)
                                                        .toString()
                                                        .trim(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.066,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
