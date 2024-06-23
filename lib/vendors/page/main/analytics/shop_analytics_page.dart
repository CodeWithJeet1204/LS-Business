import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:localy/widgets/info_color_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ShopAnalyticsPage extends StatefulWidget {
  const ShopAnalyticsPage({super.key});

  @override
  State<ShopAnalyticsPage> createState() => _ShopAnalyticsPageState();
}

class _ShopAnalyticsPageState extends State<ShopAnalyticsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  String? selectedStringDuration = '7 Days';
  DateTime? selectedDuration = DateTime.now().subtract(
    const Duration(days: 7),
  );

  void selectDate(String date) {
    if (date == '24 Hours') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          const Duration(days: 1),
        );
      });
    }
    if (date == '7 Days') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          const Duration(days: 7),
        );
      });
    }
    if (date == '28 Days') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          const Duration(days: 28),
        );
      });
    }
    if (date == '365 Days') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          const Duration(days: 365),
        );
      });
    }
    if (date == 'Lifetime') {
      setState(() {
        selectedDuration = null;
      });
    }
  }

  Map<int, List<DateTime>> groupDateTimeIntervals(
    DateTime startDateTime,
    List<DateTime> dateTimeList,
    int numberOfGroups,
  ) {
    Duration duration = DateTime.now().difference(startDateTime);
    Duration intervalDuration = duration ~/ numberOfGroups;

    Map<int, List<DateTime>> groupedTimes = {};

    for (int i = 0; i < numberOfGroups; i++) {
      DateTime intervalStart =
          DateTime.now().subtract(intervalDuration * (numberOfGroups - i));
      DateTime intervalEnd =
          DateTime.now().subtract(intervalDuration * (numberOfGroups - i - 1));

      groupedTimes[i + 1] = [];

      for (DateTime dateTime in dateTimeList) {
        if (dateTime.isAfter(intervalStart) && dateTime.isBefore(intervalEnd)) {
          groupedTimes[i + 1]!.add(dateTime);
        }
      }
    }

    return groupedTimes;
  }

  List<BarChartRodData> convertMapToBarChartRodData(
    Map<int, List<DateTime>> timeMap,
    int groupNumber,
  ) {
    // Get the list of DateTime objects for the specified groupNumber
    List<DateTime> dateTimeList = timeMap[groupNumber] ?? [];

    // Calculate the count of DateTime objects in the group
    int count = dateTimeList.length;

    // Create a single BarChartRodData object representing the count
    return [BarChartRodData(toY: count.toDouble())];
  }

  @override
  Widget build(BuildContext context) {
    final shopStream = store
        .collection('Business')
        .doc('Owners')
        .collection('Shops')
        .doc(auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.035,
                  vertical: width * 0.0125,
                ),
                child: Column(
                  children: [
                    // TITLE & TIME
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: width * 0.033,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // TITLE
                          Text(
                            'SHOP DATA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryDark,
                              fontWeight: FontWeight.w500,
                              fontSize: width * 0.06,
                            ),
                          ),
                          // TIME
                          Container(
                            width: width * 0.4275,
                            height: width * 0.125,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: width * 0.05),
                              child: DropdownButton(
                                hint: const Text(
                                  'Select Duration',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                value: selectedStringDuration,
                                underline: const SizedBox(),
                                dropdownColor: primary2,
                                items: [
                                  '24 Hours',
                                  '7 Days',
                                  '28 Days',
                                  '365 Days',
                                  'Lifetime'
                                ]
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStringDuration = value;
                                  });
                                  selectDate(selectedStringDuration!);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SHOP STREAM
                    StreamBuilder(
                      stream: shopStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Something went wrong',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text(
                              'No Data',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          final shopData = snapshot.data!;
                          List<DateTime> viewTimestamps = [];
                          List<DateTime> followerTimestamps = [];
                          for (Timestamp viewDate
                              in shopData['viewsTimestamp']) {
                            if (selectedDuration != null) {
                              if (viewDate
                                  .toDate()
                                  .isAfter(selectedDuration!)) {
                                viewTimestamps.add(viewDate.toDate());
                              }
                            } else {
                              viewTimestamps.add(viewDate.toDate());
                            }
                          }

                          for (Timestamp followerTimestamp
                              in shopData['followersDateTime']) {
                            if (selectedDuration != null) {
                              if (followerTimestamp
                                  .toDate()
                                  .isAfter(selectedDuration!)) {
                                followerTimestamps
                                    .add(followerTimestamp.toDate());
                              }
                            } else {
                              followerTimestamps
                                  .add(followerTimestamp.toDate());
                            }
                          }

                          return Column(
                            children: [
                              // TIMED VIEWS
                              Container(
                                width: width,
                                height: width * 0.5,
                                margin: EdgeInsets.symmetric(
                                  vertical: width * 0.0125,
                                ),
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // PROPERTY & VALUE
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.0225,
                                        vertical: width * 0.0125,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // PROPERTY
                                          Text(
                                            'Shop Views',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark2,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.05,
                                            ),
                                          ),
                                          // VALUE
                                          Text(
                                            viewTimestamps.length > 1000000
                                                ? '${viewTimestamps.length.toString().substring(0)}.${viewTimestamps.length.toString().substring(1, 3)}M'
                                                : viewTimestamps.length > 1000
                                                    ? '${viewTimestamps.length.toString().substring(0)}.${viewTimestamps.length.toString().substring(1, 3)}k'
                                                    : viewTimestamps.length
                                                        .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontWeight: FontWeight.w600,
                                              fontSize: width * 0.06,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // GRAPH
                                    SizedBox(
                                      width: width * 1,
                                      height: width * 0.375,
                                      child: BarChart(
                                        BarChartData(
                                          maxY: viewTimestamps.length * 2,
                                          gridData: const FlGridData(
                                            drawVerticalLine: false,
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: width * 0.0685,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: width * 0.065,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    value.toStringAsFixed(0),
                                                    style: TextStyle(
                                                      fontSize:
                                                          selectedStringDuration ==
                                                                  '24 Hours'
                                                              ? width * 0.0266
                                                              : width * 0.0375,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                          ),
                                          barGroups: selectedStringDuration ==
                                                  '24 Hours'
                                              ? List.generate(24, (index) {
                                                  int groupNumber = index + 1;
                                                  return BarChartGroupData(
                                                    x: groupNumber,
                                                    barRods:
                                                        convertMapToBarChartRodData(
                                                      groupDateTimeIntervals(
                                                        DateTime.now().subtract(
                                                          const Duration(
                                                              days: 1),
                                                        ),
                                                        viewTimestamps,
                                                        24,
                                                      ),
                                                      groupNumber,
                                                    ),
                                                  );
                                                }).toList()
                                              : selectedStringDuration ==
                                                      '7 Days'
                                                  ? List.generate(7, (index) {
                                                      int groupNumber =
                                                          index + 1;
                                                      return BarChartGroupData(
                                                        x: groupNumber,
                                                        barRods:
                                                            convertMapToBarChartRodData(
                                                          groupDateTimeIntervals(
                                                            DateTime.now()
                                                                .subtract(
                                                              const Duration(
                                                                  days: 7),
                                                            ),
                                                            viewTimestamps,
                                                            7,
                                                          ),
                                                          groupNumber,
                                                        ),
                                                      );
                                                    }).toList()
                                                  : selectedStringDuration ==
                                                          '28 Days'
                                                      ? List.generate(4,
                                                          (index) {
                                                          int groupNumber =
                                                              index + 1;
                                                          return BarChartGroupData(
                                                            x: groupNumber,
                                                            barRods:
                                                                convertMapToBarChartRodData(
                                                              groupDateTimeIntervals(
                                                                DateTime.now()
                                                                    .subtract(
                                                                  const Duration(
                                                                    days: 28,
                                                                  ),
                                                                ),
                                                                viewTimestamps,
                                                                4,
                                                              ),
                                                              groupNumber,
                                                            ),
                                                          );
                                                        }).toList()
                                                      : selectedStringDuration ==
                                                              '365 Days'
                                                          ? List.generate(12,
                                                              (index) {
                                                              int groupNumber =
                                                                  index + 1;
                                                              return BarChartGroupData(
                                                                x: groupNumber,
                                                                barRods:
                                                                    convertMapToBarChartRodData(
                                                                  groupDateTimeIntervals(
                                                                    DateTime.now()
                                                                        .subtract(
                                                                      const Duration(
                                                                        days:
                                                                            365,
                                                                      ),
                                                                    ),
                                                                    viewTimestamps,
                                                                    12,
                                                                  ),
                                                                  groupNumber,
                                                                ),
                                                              );
                                                            }).toList()
                                                          : selectedStringDuration ==
                                                                  'Lifetime'
                                                              ? List.generate(
                                                                  10, (index) {
                                                                  int groupNumber =
                                                                      index + 1;
                                                                  return BarChartGroupData(
                                                                    x: groupNumber,
                                                                    barRods:
                                                                        convertMapToBarChartRodData(
                                                                      groupDateTimeIntervals(
                                                                        DateTime.now()
                                                                            .subtract(
                                                                          const Duration(
                                                                            days:
                                                                                10000,
                                                                          ),
                                                                        ),
                                                                        viewTimestamps,
                                                                        10,
                                                                      ),
                                                                      groupNumber,
                                                                    ),
                                                                  );
                                                                }).toList()
                                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // TIMED FOLLOWERS
                              Container(
                                width: width,
                                height: width * 0.5,
                                margin: EdgeInsets.symmetric(
                                  vertical: width * 0.0125,
                                ),
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // PROPERTY & VALUE
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.0225,
                                        vertical: width * 0.0125,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // PROPERTY
                                          Text(
                                            'Shop Followers',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark2,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.05,
                                            ),
                                          ),
                                          // VALUE
                                          Text(
                                            followerTimestamps.length > 1000000
                                                ? '${followerTimestamps.length.toString().substring(0)}.${followerTimestamps.length.toString().substring(1, 3)}M'
                                                : followerTimestamps.length >
                                                        1000
                                                    ? '${followerTimestamps.length.toString().substring(0)}.${followerTimestamps.length.toString().substring(1, 3)}k'
                                                    : followerTimestamps.length
                                                        .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontWeight: FontWeight.w600,
                                              fontSize: width * 0.06,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // GRAPH
                                    SizedBox(
                                      width: width * 1,
                                      height: width * 0.375,
                                      child: BarChart(
                                        BarChartData(
                                          maxY: followerTimestamps.length * 2,
                                          gridData: const FlGridData(
                                            drawVerticalLine: false,
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: width * 0.0685,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: width * 0.065,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    value.toStringAsFixed(0),
                                                    style: TextStyle(
                                                      fontSize:
                                                          selectedStringDuration ==
                                                                  '24 Hours'
                                                              ? width * 0.0266
                                                              : width * 0.0375,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                          ),
                                          barGroups: selectedStringDuration ==
                                                  '24 Hours'
                                              ? List.generate(24, (index) {
                                                  int groupNumber = index + 1;
                                                  return BarChartGroupData(
                                                    x: groupNumber,
                                                    barRods:
                                                        convertMapToBarChartRodData(
                                                      groupDateTimeIntervals(
                                                        DateTime.now().subtract(
                                                          const Duration(
                                                              days: 1),
                                                        ),
                                                        followerTimestamps,
                                                        24,
                                                      ),
                                                      groupNumber,
                                                    ),
                                                  );
                                                }).toList()
                                              : selectedStringDuration ==
                                                      '7 Days'
                                                  ? List.generate(7, (index) {
                                                      int groupNumber =
                                                          index + 1;
                                                      return BarChartGroupData(
                                                        x: groupNumber,
                                                        barRods:
                                                            convertMapToBarChartRodData(
                                                          groupDateTimeIntervals(
                                                            DateTime.now()
                                                                .subtract(
                                                              const Duration(
                                                                  days: 7),
                                                            ),
                                                            followerTimestamps,
                                                            7,
                                                          ),
                                                          groupNumber,
                                                        ),
                                                      );
                                                    }).toList()
                                                  : selectedStringDuration ==
                                                          '28 Days'
                                                      ? List.generate(4,
                                                          (index) {
                                                          int groupNumber =
                                                              index + 1;
                                                          return BarChartGroupData(
                                                            x: groupNumber,
                                                            barRods:
                                                                convertMapToBarChartRodData(
                                                              groupDateTimeIntervals(
                                                                DateTime.now()
                                                                    .subtract(
                                                                  const Duration(
                                                                    days: 28,
                                                                  ),
                                                                ),
                                                                followerTimestamps,
                                                                4,
                                                              ),
                                                              groupNumber,
                                                            ),
                                                          );
                                                        }).toList()
                                                      : selectedStringDuration ==
                                                              '365 Days'
                                                          ? List.generate(12,
                                                              (index) {
                                                              int groupNumber =
                                                                  index + 1;
                                                              return BarChartGroupData(
                                                                x: groupNumber,
                                                                barRods:
                                                                    convertMapToBarChartRodData(
                                                                  groupDateTimeIntervals(
                                                                    DateTime.now()
                                                                        .subtract(
                                                                      const Duration(
                                                                        days:
                                                                            365,
                                                                      ),
                                                                    ),
                                                                    followerTimestamps,
                                                                    12,
                                                                  ),
                                                                  groupNumber,
                                                                ),
                                                              );
                                                            }).toList()
                                                          : selectedStringDuration ==
                                                                  'Lifetime'
                                                              ? List.generate(
                                                                  10, (index) {
                                                                  int groupNumber =
                                                                      index + 1;
                                                                  return BarChartGroupData(
                                                                    x: groupNumber,
                                                                    barRods:
                                                                        convertMapToBarChartRodData(
                                                                      groupDateTimeIntervals(
                                                                        DateTime.now()
                                                                            .subtract(
                                                                          const Duration(
                                                                            days:
                                                                                10000,
                                                                          ),
                                                                        ),
                                                                        followerTimestamps,
                                                                        10,
                                                                      ),
                                                                      groupNumber,
                                                                    ),
                                                                  );
                                                                }).toList()
                                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ALL TIME VIEWS AND FOLLOWERS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ALL VIEWS
                                  InfoColorBox(
                                    text: 'VIEWS',
                                    width: width,
                                    property: shopData['viewsTimestamp'].length,
                                    color: const Color.fromARGB(
                                      255,
                                      163,
                                      255,
                                      166,
                                    ),
                                  ),

                                  // ALL FOLLOWERS
                                  InfoColorBox(
                                    text: 'FOLLOWERS',
                                    width: width,
                                    property:
                                        (shopData['Followers'] as List).length,
                                    color: const Color.fromARGB(
                                        255, 237, 255, 163),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
