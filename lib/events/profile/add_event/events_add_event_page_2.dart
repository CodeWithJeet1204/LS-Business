import 'package:feather_icons/feather_icons.dart';
import 'package:localy/events/profile/add_event/events_add_event_page_3.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/snack_bar.dart';
import 'package:localy/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventsAddEventPage2 extends StatefulWidget {
  const EventsAddEventPage2({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  State<EventsAddEventPage2> createState() => _EventsAddEventPage2State();
}

class _EventsAddEventPage2State extends State<EventsAddEventPage2> {
  DateTime? startDate;
  DateTime? endDate;
  String? startDateFormat;
  String? endDateFormat;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? startTimeFormat;
  String? endTimeFormat;
  bool isWeekedDifferent = false;
  TimeOfDay? weekendStartTime;
  TimeOfDay? weekendEndTime;
  String? weekendStartTimeFormat;
  String? weekendEndTimeFormat;
  bool isNext = false;

  // SELECT START DATE
  Future<void> selectStartDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
    );

    if (selected != null) {
      setState(() {
        startDate = selected;
        startDateFormat = DateFormat('d MMM yy').format(selected);
      });
    }
  }

  // SELECT END DATE
  Future<void> selectEndDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
    );

    if (selected != null) {
      setState(() {
        endDate = selected;
        endDateFormat = DateFormat('d MMM yy').format(selected);
      });
    }
  }

  // SELECT START TIME
  Future<void> selectStartTime() async {
    TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected != null) {
      setState(() {
        startTime = selected;
        startTimeFormat = startTime!.format(context);
      });
    }
  }

  // SELECT END TIME
  Future<void> selectEndTime() async {
    TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected != null) {
      setState(() {
        endTime = selected;
        endTimeFormat = endTime!.format(context);
      });
    }
  }

  // SELECT WEEKEND START TIME
  Future<void> selectWeekendStartTime() async {
    TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected != null) {
      setState(() {
        weekendStartTime = selected;
        weekendStartTimeFormat = weekendStartTime!.format(context);
      });
    }
  }

  // SELECT WEEKEND END TIME
  Future<void> selectWeekendEndTime() async {
    TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected != null) {
      setState(() {
        weekendEndTime = selected;
        weekendEndTimeFormat = weekendEndTime!.format(context);
      });
    }
  }

  // NEXT
  void next() {
    if (startDate == null) {
      return mySnackBar(context, 'Select Start Date');
    }
    if (endDate == null) {
      return mySnackBar(context, 'Select End Date');
    }
    if (startTime == null) {
      return mySnackBar(context, 'Select Start Time');
    }
    if (endTime == null) {
      return mySnackBar(context, 'Select End Time');
    }
    if (isWeekedDifferent && weekendStartTime == null) {
      return mySnackBar(context, 'Select Weekend Start Time');
    }
    if (isWeekedDifferent && weekendEndTime == null) {
      return mySnackBar(context, 'Select Weekend End Time');
    }

    Map<String, dynamic> data = {
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'weekendStartTime':
          isWeekedDifferent ? weekendStartTime.toString() : null,
      'weekendEndTime': isWeekedDifferent ? weekendEndTime.toString() : null,
    };

    data.addAll(widget.data);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => EventsAddEventPage3(
              data: data,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date & Timings'),
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
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.006125,
          ),
          child: LayoutBuilder(builder: ((context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.033),
                    child: const Text(
                      'Dates',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: width * 0.45,
                        decoration: BoxDecoration(
                          color: primary3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start Date',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryDark2,
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  startDateFormat != null
                                      ? IconButton(
                                          onPressed: () async {
                                            await selectStartDate();
                                          },
                                          icon: Icon(
                                            FeatherIcons.edit,
                                            size: width * 0.066,
                                          ),
                                          tooltip: 'Change Date',
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            startDateFormat == null
                                ? MyTextButton(
                                    onPressed: () async {
                                      await selectStartDate();
                                    },
                                    text: 'Select Date',
                                    textColor: primaryDark,
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: width * 0.036,
                                      bottom: width * 0.025,
                                    ),
                                    child: Text(
                                      startDateFormat!,
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
                      Container(
                        height: 100,
                        width: width * 0.45,
                        decoration: BoxDecoration(
                          color: primary3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'End Date',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryDark2,
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  endDateFormat != null
                                      ? IconButton(
                                          onPressed: () async {
                                            await selectEndDate();
                                          },
                                          icon: Icon(
                                            FeatherIcons.edit,
                                            size: width * 0.066,
                                          ),
                                          tooltip: 'Change Date',
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            endDateFormat == null
                                ? MyTextButton(
                                    onPressed: () async {
                                      await selectEndDate();
                                    },
                                    text: 'Select Date',
                                    textColor: primaryDark,
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: width * 0.0366,
                                      bottom: width * 0.025,
                                    ),
                                    child: Text(
                                      endDateFormat!,
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
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.033),
                    child: const Text(
                      'Timings',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timing',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryDark2,
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              startTime == null
                                  ? MyTextButton(
                                      onPressed: () async {
                                        await selectStartTime();
                                      },
                                      text: 'Select Start Time',
                                      textColor: primaryDark,
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        await selectStartTime();
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            startTimeFormat.toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.06,
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
                              endTime == null
                                  ? MyTextButton(
                                      onPressed: () async {
                                        await selectEndTime();
                                      },
                                      text: 'Select End Time',
                                      textColor: primaryDark,
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        await selectEndTime();
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            endTimeFormat.toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: width * 0.06,
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
                  const SizedBox(height: 12),
                  Center(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: width * 0.95,
                        decoration: BoxDecoration(
                          color: primary3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.025,
                          vertical: 8,
                        ),
                        child: !isWeekedDifferent
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Weekend Timing Different?',
                                    style: TextStyle(
                                      fontSize: width * 0.0466,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Checkbox(
                                      activeColor: primaryDark,
                                      checkColor: white,
                                      value: isWeekedDifferent,
                                      onChanged: (value) {
                                        setState(() {
                                          isWeekedDifferent =
                                              !isWeekedDifferent;
                                        });
                                      }),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Weekend Timing Different?',
                                        style: TextStyle(
                                          fontSize: width * 0.0466,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Checkbox(
                                          activeColor: primaryDark,
                                          checkColor: white,
                                          value: isWeekedDifferent,
                                          onChanged: (value) {
                                            setState(() {
                                              isWeekedDifferent =
                                                  !isWeekedDifferent;
                                            });
                                          })
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      weekendStartTime == null
                                          ? MyTextButton(
                                              onPressed: () async {
                                                await selectWeekendStartTime();
                                              },
                                              text: 'Select Start Time',
                                              textColor: primaryDark,
                                            )
                                          : GestureDetector(
                                              onTap: () async {
                                                await selectWeekendStartTime();
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    weekendStartTimeFormat
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.06,
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
                                      weekendEndTime == null
                                          ? MyTextButton(
                                              onPressed: () async {
                                                await selectWeekendEndTime();
                                              },
                                              text: 'Select End Time',
                                              textColor: primaryDark,
                                            )
                                          : GestureDetector(
                                              onTap: () async {
                                                await selectWeekendEndTime();
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    endTimeFormat.toString(),
                                                    style: TextStyle(
                                                      color: primaryDark,
                                                      fontSize: width * 0.06,
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
                  const SizedBox(height: 12),
                ],
              ),
            );
          })),
        ),
      ),
    );
  }
}
