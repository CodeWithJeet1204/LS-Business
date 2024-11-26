import 'package:ls_business/vendors/page/main/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/vendors/page/register/membership_page.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/my_button.dart';
import 'package:ls_business/widgets/snack_bar.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class BusinessTimingsPage extends StatefulWidget {
  const BusinessTimingsPage({
    super.key,
    required this.fromMainPage,
  });

  final bool fromMainPage;

  @override
  State<BusinessTimingsPage> createState() => _BusinessTimingsPageState();
}

class _BusinessTimingsPageState extends State<BusinessTimingsPage> {
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
  bool isDialog = false;

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

  // NEXT
  Future<void> next() async {
    if (isWeekday) {
      if (weekdayStartTime == null) {
        return mySnackBar(context, 'Select Mon - Fri Start Time');
      }
      if (weekdayEndTime == null) {
        return mySnackBar(context, 'Select Mon - Fri End Time');
      }
    }

    if (isSaturday) {
      if (saturdayStartTime == null) {
        return mySnackBar(context, 'Select Saturday Start Time');
      }
      if (saturdayEndTime == null) {
        return mySnackBar(context, 'Select Saturday End Time');
      }
    }

    if (isSunday) {
      if (sundayStartTime == null) {
        return mySnackBar(context, 'Select Sunday Start Time');
      }
      if (sundayEndTime == null) {
        return mySnackBar(context, 'Select Sunday End Time');
      }
    }

    setState(() {
      isNext = true;
      isDialog = true;
    });

    try {
      await store
          .collection('Business')
          .doc('Owners')
          .collection('Shops')
          .doc(auth.currentUser!.uid)
          .update({
        'weekdayStartTime': convertWeekdayTimeOfDay()[0],
        'weekdayEndTime': convertWeekdayTimeOfDay()[1],
        'saturdayStartTime': convertSaturdayTimeOfDay()[0],
        'saturdayEndTime': convertSaturdayTimeOfDay()[1],
        'sundayStartTime': convertSundayTimeOfDay()[0],
        'sundayEndTime': convertSundayTimeOfDay()[1],
      });

      setState(() {
        isNext = false;
        isDialog = false;
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
              builder: (context) => const SelectMembershipPage(
                hasAvailedLaunchOffer: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isNext = false;
        isDialog = false;
      });
      if (mounted) {
        return mySnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Shop Timings'),
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
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width * 0.0125,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // WEEKDAY
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isWeekday = !isWeekday;
                          });
                        },
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 8),
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
                              fontSize: width * 0.05,
                            ),
                          ),
                          trailing: Checkbox(
                              activeColor: primaryDark,
                              checkColor: white,
                              value: isWeekday,
                              onChanged: (value) {
                                setState(() {
                                  isWeekday = value!;
                                });
                              }),
                          onExpansionChanged: (value) {
                            setState(() {
                              isWeekday = value;
                            });
                          },
                          children: [
                            // TIMES
                            !isWeekday
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.all(width * 0.0125),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Start Time',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontSize:
                                                              width * 0.04,
                                                        ),
                                                      ),
                                                      weekdayStartTime != null
                                                          ? IconButton(
                                                              onPressed:
                                                                  () async {
                                                                await selectWeekdayStartTime();
                                                              },
                                                              icon: Icon(
                                                                FeatherIcons
                                                                    .edit,
                                                                size: width *
                                                                    0.055,
                                                              ),
                                                              tooltip: 'Change',
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                weekdayStartTime == null
                                                    ? MyTextButton(
                                                        onTap: () async {
                                                          await selectWeekdayStartTime();
                                                        },
                                                        text: 'Select Time',
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.036,
                                                          bottom: width * 0.025,
                                                        ),
                                                        child: Text(
                                                          weekdayStartTime!
                                                              .format(context)
                                                              .toString()
                                                              .trim(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: primaryDark,
                                                            fontSize:
                                                                width * 0.07,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'End Time',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontSize:
                                                              width * 0.04,
                                                        ),
                                                      ),
                                                      weekdayEndTime != null
                                                          ? IconButton(
                                                              onPressed:
                                                                  () async {
                                                                await selectWeekdayEndTime();
                                                              },
                                                              icon: Icon(
                                                                FeatherIcons
                                                                    .edit,
                                                                size: width *
                                                                    0.055,
                                                              ),
                                                              tooltip: 'Change',
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                weekdayEndTime == null
                                                    ? MyTextButton(
                                                        onTap: () async {
                                                          await selectWeekdayEndTime();
                                                        },
                                                        text: 'Select Time',
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.0366,
                                                          bottom: width * 0.025,
                                                        ),
                                                        child: Text(
                                                          weekdayEndTime!
                                                              .format(context)
                                                              .toString()
                                                              .trim(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: primaryDark,
                                                            fontSize:
                                                                width * 0.07,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                      ),

                      const SizedBox(height: 12),

                      // SATURDAY
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSaturday = !isSaturday;
                          });
                        },
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 8),
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
                              fontSize: width * 0.05,
                            ),
                          ),
                          trailing: Checkbox(
                              activeColor: primaryDark,
                              checkColor: white,
                              value: isSaturday,
                              onChanged: (value) {
                                setState(() {
                                  isSaturday = value!;
                                });
                              }),
                          onExpansionChanged: (value) {
                            setState(() {
                              isSaturday = value;
                            });
                          },
                          children: [
                            // TIMES
                            !isSaturday
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.all(width * 0.0125),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Start Time',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontSize:
                                                              width * 0.04,
                                                        ),
                                                      ),
                                                      saturdayStartTime != null
                                                          ? IconButton(
                                                              onPressed:
                                                                  () async {
                                                                await selectSaturdayStartTime();
                                                              },
                                                              icon: Icon(
                                                                FeatherIcons
                                                                    .edit,
                                                                size: width *
                                                                    0.055,
                                                              ),
                                                              tooltip: 'Change',
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                saturdayStartTime == null
                                                    ? MyTextButton(
                                                        onTap: () async {
                                                          await selectSaturdayStartTime();
                                                        },
                                                        text: 'Select Time',
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.036,
                                                          bottom: width * 0.025,
                                                        ),
                                                        child: Text(
                                                          saturdayStartTime!
                                                              .format(context)
                                                              .toString()
                                                              .trim(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: primaryDark,
                                                            fontSize:
                                                                width * 0.07,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'End Time',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontSize:
                                                              width * 0.04,
                                                        ),
                                                      ),
                                                      saturdayEndTime != null
                                                          ? IconButton(
                                                              onPressed:
                                                                  () async {
                                                                await selectSaturdayEndTime();
                                                              },
                                                              icon: Icon(
                                                                FeatherIcons
                                                                    .edit,
                                                                size: width *
                                                                    0.055,
                                                              ),
                                                              tooltip: 'Change',
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                saturdayEndTime == null
                                                    ? MyTextButton(
                                                        onTap: () async {
                                                          await selectSaturdayEndTime();
                                                        },
                                                        text: 'Select Time',
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.0366,
                                                          bottom: width * 0.025,
                                                        ),
                                                        child: Text(
                                                          saturdayEndTime!
                                                              .format(context)
                                                              .toString()
                                                              .trim(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: primaryDark,
                                                            fontSize:
                                                                width * 0.07,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                      ),

                      const SizedBox(height: 12),

                      // SUNDAY
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSunday = !isSunday;
                          });
                        },
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 8),
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
                              fontSize: width * 0.05,
                            ),
                          ),
                          trailing: Checkbox(
                              activeColor: primaryDark,
                              checkColor: white,
                              value: isSunday,
                              onChanged: (value) {
                                setState(() {
                                  isSunday = value!;
                                });
                              }),
                          onExpansionChanged: (value) {
                            setState(() {
                              isSunday = value;
                            });
                          },
                          children: [
                            // TIMES
                            !isSunday
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.all(width * 0.0125),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Start Time',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontSize:
                                                              width * 0.04,
                                                        ),
                                                      ),
                                                      sundayStartTime != null
                                                          ? IconButton(
                                                              onPressed:
                                                                  () async {
                                                                await selectSundayStartTime();
                                                              },
                                                              icon: Icon(
                                                                FeatherIcons
                                                                    .edit,
                                                                size: width *
                                                                    0.055,
                                                              ),
                                                              tooltip: 'Change',
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                sundayStartTime == null
                                                    ? MyTextButton(
                                                        onTap: () async {
                                                          await selectSundayStartTime();
                                                        },
                                                        text: 'Select Time',
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.036,
                                                          bottom: width * 0.025,
                                                        ),
                                                        child: Text(
                                                          sundayStartTime!
                                                              .format(context)
                                                              .toString()
                                                              .trim(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: primaryDark,
                                                            fontSize:
                                                                width * 0.07,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'End Time',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: primaryDark2,
                                                          fontSize:
                                                              width * 0.04,
                                                        ),
                                                      ),
                                                      sundayEndTime != null
                                                          ? IconButton(
                                                              onPressed:
                                                                  () async {
                                                                await selectSundayEndTime();
                                                              },
                                                              icon: Icon(
                                                                FeatherIcons
                                                                    .edit,
                                                                size: width *
                                                                    0.055,
                                                              ),
                                                              tooltip: 'Change',
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                sundayEndTime == null
                                                    ? MyTextButton(
                                                        onTap: () async {
                                                          await selectSundayEndTime();
                                                        },
                                                        text: 'Select Time',
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: width * 0.0366,
                                                          bottom: width * 0.025,
                                                        ),
                                                        child: Text(
                                                          sundayEndTime!
                                                              .format(context)
                                                              .toString()
                                                              .trim(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: primaryDark,
                                                            fontSize:
                                                                width * 0.07,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                      ),

                      const SizedBox(height: 24),

                      // NEXT
                      MyButton(
                        text: widget.fromMainPage ? 'DONE' : 'NEXT',
                        onTap: () async {
                          await next();
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
