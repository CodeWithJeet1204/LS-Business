import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localy/vendors/register/membership_page.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/button.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';

class SelectBusinessTimingsPage extends StatefulWidget {
  const SelectBusinessTimingsPage({super.key});

  @override
  State<SelectBusinessTimingsPage> createState() =>
      _SelectBusinessTimingsPageState();
}

class _SelectBusinessTimingsPageState extends State<SelectBusinessTimingsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  TimeOfDay? weekdayStartTime;
  TimeOfDay? weekdayEndTime;
  TimeOfDay? saturdayStartTime;
  TimeOfDay? saturdayEndTime;
  TimeOfDay? sundayStartTime;
  TimeOfDay? sundayEndTime;
  bool isSaturday = false;
  bool isSunday = false;
  bool isNext = false;

  // SELECT WEEKDAY START TIME
  Future<void> selectWeekdayStartTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
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
      initialTime: TimeOfDay(
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
      initialTime: TimeOfDay(
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
      initialTime: TimeOfDay(
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
      initialTime: TimeOfDay(
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
      initialTime: TimeOfDay(
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
    if (weekdayStartTime == null) {
      return mySnackBar(context, 'Select Mon - Fri Start Time');
    }
    if (weekdayEndTime == null) {
      return mySnackBar(context, 'Select Mon - Fri End Time');
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

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SelectMembershipPage()),
        );
      }
    } catch (e) {
      setState(() {
        isNext = false;
      });
      return mySnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Timings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.0125,
          ),
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
                    children: [
                      // TIMES
                      Padding(
                        padding: EdgeInsets.all(width * 0.0125),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // START TIME
                            Container(
                              height: 100,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                          'Start Time',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                            print(111);
                                            await selectWeekdayStartTime();
                                            print(222);
                                          },
                                          text: 'Select Time',
                                          textColor: primaryDark,
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.036,
                                            bottom: width * 0.025,
                                          ),
                                          child: Text(
                                            weekdayStartTime!.format(context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.07,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),

                            // END TIME
                            Container(
                              height: 100,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                          'End Time',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                          textColor: primaryDark,
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.0366,
                                            bottom: width * 0.025,
                                          ),
                                          child: Text(
                                            weekdayEndTime!.format(context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.07,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

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
                        onChanged: (value) {
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
                                  Container(
                                    height: 100,
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
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Start Time',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                textColor: primaryDark,
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.036,
                                                  bottom: width * 0.025,
                                                ),
                                                child: Text(
                                                  saturdayStartTime!
                                                      .format(context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.07,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),

                                  // END TIME
                                  Container(
                                    height: 100,
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
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'End Time',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                textColor: primaryDark,
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.0366,
                                                  bottom: width * 0.025,
                                                ),
                                                child: Text(
                                                  saturdayEndTime!
                                                      .format(context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.07,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),

                  SizedBox(height: 12),

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
                        onChanged: (value) {
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
                                  Container(
                                    height: 100,
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
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Start Time',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                textColor: primaryDark,
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.036,
                                                  bottom: width * 0.025,
                                                ),
                                                child: Text(
                                                  sundayStartTime!
                                                      .format(context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.07,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),

                                  // END TIME
                                  Container(
                                    height: 100,
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
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'End Time',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                textColor: primaryDark,
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.0366,
                                                  bottom: width * 0.025,
                                                ),
                                                child: Text(
                                                  sundayEndTime!
                                                      .format(context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark,
                                                    fontSize: width * 0.07,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // NEXT
                  MyButton(
                    text: 'NEXT',
                    onTap: () async {
                      await next();
                    },
                    isLoading: isNext,
                    horizontalPadding: 0,
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
