import 'dart:math';
import 'package:ls_business/vendors/provider/main_page_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/info_color_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class PostsAnalyticsPage extends StatefulWidget {
  const PostsAnalyticsPage({super.key});

  @override
  State<PostsAnalyticsPage> createState() => _PostsAnalyticsPageState();
}

class _PostsAnalyticsPageState extends State<PostsAnalyticsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  String? selectedStringDuration = '7 Days';
  DateTime? selectedDuration = DateTime.now().subtract(
    const Duration(
      days: 7,
    ),
  );

  // SELECTING DURATION
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
    if (date == '4 Weeks') {
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

  // BAR GRAPH DATA TIMED
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

  // BAR CHART ROD DATA
  List<BarChartRodData> convertMapToBarChartRodData(
    Map<int, List<DateTime>> timeMap,
    int groupNumber,
  ) {
    List<DateTime> dateTimeList = timeMap[groupNumber] ?? [];

    int count = dateTimeList.length;

    return [BarChartRodData(toY: count.toDouble())];
  }

  // POST WISE DATA
  List<PieChartSectionData> postWiseData(Map<String, List> postWiseData) {
    List<PieChartSectionData> pieChartSections = [];
    print('postWiseData: $postWiseData');

    int totalViews = postWiseData.isEmpty
        ? 0
        : postWiseData.values
            .reduce((summation, views) => summation + views)[0];

    postWiseData.forEach((postId, data) {
      print('data: $data');

      int dataCount = data[0];
      print('dataCount: $dataCount');
      if (dataCount > 0) {
        double percentage = dataCount / totalViews;
        double value = totalViews * percentage;

        PieChartSectionData section = PieChartSectionData(
          value: value.toDouble(),
          title: data[1].length > 8 ? '${data[1].substring(0, 8)}...' : data[1],
          titleStyle: const TextStyle(
            color: primaryDark2,
            fontWeight: FontWeight.w500,
          ),
          color: getRandomColor(),
          radius: 60,
        );
        pieChartSections.add(section);
      }
    });

    return pieChartSections;
  }

  // PIE RANDOM COLOR
  Color getRandomColor() {
    Random random = Random();

    Color baseColor1 = Colors.red;
    Color baseColor2 = Colors.green;
    Color baseColor3 = Colors.blue;

    double weight1 = random.nextDouble();
    double weight2 = random.nextDouble();
    double weight3 = random.nextDouble();
    double sumWeights = weight1 + weight2 + weight3;

    weight1 /= sumWeights;
    weight2 /= sumWeights;
    weight3 /= sumWeights;

    int red = (weight1 * baseColor1.red +
            weight2 * baseColor2.red +
            weight3 * baseColor3.red)
        .toInt();
    int green = (weight1 * baseColor1.green +
            weight2 * baseColor2.green +
            weight3 * baseColor3.green)
        .toInt();
    int blue = (weight1 * baseColor1.blue +
            weight2 * baseColor2.blue +
            weight3 * baseColor3.blue)
        .toInt();

    return Color.fromARGB(255, red, green, blue);
  }

  @override
  Widget build(BuildContext context) {
    final mainPageProvider = Provider.of<MainPageProvider>(context);
    final postsStream = store
        .collection('Business')
        .doc('Data')
        .collection('Post')
        .where('postVendorId', isEqualTo: auth.currentUser!.uid)
        .snapshots();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        mainPageProvider.goToHomePage();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.0225,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'POST DATA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryDark,
                              fontSize: width * 0.045,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: primary2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.025,
                            ),
                            child: DropdownButton(
                              value:
                                  selectedStringDuration ?? 'Select Duration',
                              underline: const SizedBox(),
                              dropdownColor: primary2,
                              items: [
                                '24 Hours',
                                '7 Days',
                                '4 Weeks',
                                '365 Days',
                                'Lifetime'
                              ]
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e.toString().trim(),
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder(
                        stream: postsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Something went wrong',
                              ),
                            );
                          }

                          if (snapshot.hasData) {
                            if (snapshot.data!.docs.isEmpty) {
                              return const SizedBox(
                                height: 80,
                                child: Center(
                                  child: Text(
                                    'No Posts Added',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            final postsSnap = snapshot.data!.docs;
                            Map<String, dynamic> postsData = {
                              'postViewsTimestamp': [],
                              'postWishlistTimestamp': {},
                            };

                            int index = 0;
                            for (var post in postsSnap) {
                              postsData['postViewsTimestamp'] +=
                                  post['postViewsTimestamp'];

                              (postsData['postWishlistTimestamp'] as Map)
                                  .addAll(
                                (post['postWishlistTimestamp'] as Map).map(
                                  (key, value) => MapEntry(
                                    '$key$index',
                                    value,
                                  ),
                                ),
                              );

                              index++;
                            }

                            List<DateTime> postViewTimestamps = [];
                            List<DateTime> postWishlistTimestamps = [];

                            for (Timestamp viewDate
                                in postsData['postViewsTimestamp']) {
                              if (selectedDuration != null) {
                                if (viewDate
                                    .toDate()
                                    .isAfter(selectedDuration!)) {
                                  postViewTimestamps.add(viewDate.toDate());
                                }
                              } else {
                                postViewTimestamps.add(viewDate.toDate());
                              }
                            }

                            for (Timestamp wishlistTimestamp
                                in (postsData['postWishlistTimestamp'] as Map)
                                    .values) {
                              if (selectedDuration != null) {
                                if (wishlistTimestamp
                                    .toDate()
                                    .isAfter(selectedDuration!)) {
                                  postWishlistTimestamps
                                      .add(wishlistTimestamp.toDate());
                                }
                              } else {
                                postWishlistTimestamps
                                    .add(wishlistTimestamp.toDate());
                              }
                            }

                            Map<String, List> postWiseViews = {};
                            Map<String, List> postWiseWishlist = {};

                            for (var post in postsSnap) {
                              postWiseViews[post['postId']] = [
                                (post['postViewsTimestamp'] as List).length,
                                post['postText']
                              ];
                            }

                            for (var post in postsSnap) {
                              postWiseWishlist[post['postId']] = [
                                (post['postWishlistTimestamp'] as Map).length,
                                post['postText']
                              ];
                            }

                            String maxpostViewsName = 'No Post Name';
                            int maxpostViewsValue = 0;
                            postWiseViews.forEach((key, list) {
                              if (list[0] > maxpostViewsValue) {
                                maxpostViewsValue = list[0];
                                maxpostViewsName = list[1];
                              }
                            });

                            String maxpostWishlistName = 'No Post Name';
                            int maxpostWishlistValue = 0;
                            postWiseWishlist.forEach((key, list) {
                              if (list[0] > maxpostWishlistValue) {
                                maxpostWishlistValue = list[0];
                                maxpostWishlistName = list[1];
                              }
                            });

                            return Column(
                              children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.0225,
                                          vertical: width * 0.0125,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Post Views',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * 0.05,
                                              ),
                                            ),
                                            Text(
                                              postViewTimestamps.length >
                                                      1000000
                                                  ? '${postViewTimestamps.length.toString().substring(0)}.${postViewTimestamps.length.toString().substring(1, 3)}M'
                                                  : postViewTimestamps.length >
                                                          1000
                                                      ? '${postViewTimestamps.length.toString().substring(0)}.${postViewTimestamps.length.toString().substring(1, 3)}k'
                                                      : postViewTimestamps
                                                          .length
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
                                      SizedBox(
                                        width: width,
                                        height: width * 0.3625,
                                        child: BarChart(
                                          BarChartData(
                                            maxY: postViewTimestamps.length
                                                .toDouble(),
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
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Text(
                                                      value.toStringAsFixed(0),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize:
                                                            selectedStringDuration ==
                                                                    '24 Hours'
                                                                ? width * 0.0266
                                                                : width *
                                                                    0.0375,
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
                                                ? List.generate(
                                                    24,
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
                                                                  days: 1),
                                                            ),
                                                            postViewTimestamps,
                                                            24,
                                                          ),
                                                          groupNumber,
                                                        ),
                                                      );
                                                    },
                                                  ).toList()
                                                : selectedStringDuration ==
                                                        '7 Days'
                                                    ? List.generate(
                                                        7,
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
                                                                      days: 7),
                                                                ),
                                                                postViewTimestamps,
                                                                7,
                                                              ),
                                                              groupNumber,
                                                            ),
                                                          );
                                                        },
                                                      ).toList()
                                                    : selectedStringDuration ==
                                                            '4 Weeks'
                                                        ? List.generate(
                                                            4,
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
                                                                            28,
                                                                      ),
                                                                    ),
                                                                    postViewTimestamps,
                                                                    4,
                                                                  ),
                                                                  groupNumber,
                                                                ),
                                                              );
                                                            },
                                                          ).toList()
                                                        : selectedStringDuration ==
                                                                '365 Days'
                                                            ? List.generate(
                                                                12,
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
                                                                        postViewTimestamps,
                                                                        12,
                                                                      ),
                                                                      groupNumber,
                                                                    ),
                                                                  );
                                                                },
                                                              ).toList()
                                                            : selectedStringDuration ==
                                                                    'Lifetime'
                                                                ? List.generate(
                                                                    10,
                                                                    (index) {
                                                                      int groupNumber =
                                                                          index +
                                                                              1;
                                                                      return BarChartGroupData(
                                                                        x: groupNumber,
                                                                        barRods:
                                                                            convertMapToBarChartRodData(
                                                                          groupDateTimeIntervals(
                                                                            DateTime.now().subtract(
                                                                              const Duration(
                                                                                days: 10000,
                                                                              ),
                                                                            ),
                                                                            postViewTimestamps,
                                                                            10,
                                                                          ),
                                                                          groupNumber,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ).toList()
                                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.0225,
                                          vertical: width * 0.0125,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Post Wishlist',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * 0.05,
                                              ),
                                            ),
                                            Text(
                                              postWishlistTimestamps.length >
                                                      1000000
                                                  ? '${postWishlistTimestamps.length.toString().substring(0)}.${postWishlistTimestamps.length.toString().substring(1, 3)}M'
                                                  : postWishlistTimestamps
                                                              .length >
                                                          1000
                                                      ? '${postWishlistTimestamps.length.toString().substring(0)}.${postWishlistTimestamps.length.toString().substring(1, 3)}k'
                                                      : postWishlistTimestamps
                                                          .length
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
                                      SizedBox(
                                        width: width,
                                        height: width * 0.3625,
                                        child: BarChart(
                                          BarChartData(
                                            maxY: postWishlistTimestamps.length
                                                .toDouble(),
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
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Text(
                                                      value.toStringAsFixed(0),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize:
                                                            selectedStringDuration ==
                                                                    '24 Hours'
                                                                ? width * 0.0266
                                                                : width *
                                                                    0.0375,
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
                                                ? List.generate(
                                                    24,
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
                                                                days: 1,
                                                              ),
                                                            ),
                                                            postWishlistTimestamps,
                                                            24,
                                                          ),
                                                          groupNumber,
                                                        ),
                                                      );
                                                    },
                                                  ).toList()
                                                : selectedStringDuration ==
                                                        '7 Days'
                                                    ? List.generate(
                                                        7,
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
                                                                    days: 7,
                                                                  ),
                                                                ),
                                                                postWishlistTimestamps,
                                                                7,
                                                              ),
                                                              groupNumber,
                                                            ),
                                                          );
                                                        },
                                                      ).toList()
                                                    : selectedStringDuration ==
                                                            '4 Weeks'
                                                        ? List.generate(
                                                            4,
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
                                                                            28,
                                                                      ),
                                                                    ),
                                                                    postWishlistTimestamps,
                                                                    4,
                                                                  ),
                                                                  groupNumber,
                                                                ),
                                                              );
                                                            },
                                                          ).toList()
                                                        : selectedStringDuration ==
                                                                '365 Days'
                                                            ? List.generate(
                                                                12,
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
                                                                        postWishlistTimestamps,
                                                                        12,
                                                                      ),
                                                                      groupNumber,
                                                                    ),
                                                                  );
                                                                },
                                                              ).toList()
                                                            : selectedStringDuration ==
                                                                    'Lifetime'
                                                                ? List.generate(
                                                                    10,
                                                                    (index) {
                                                                      int groupNumber =
                                                                          index +
                                                                              1;
                                                                      return BarChartGroupData(
                                                                        x: groupNumber,
                                                                        barRods:
                                                                            convertMapToBarChartRodData(
                                                                          groupDateTimeIntervals(
                                                                            DateTime.now().subtract(
                                                                              const Duration(
                                                                                days: 10000,
                                                                              ),
                                                                            ),
                                                                            postWishlistTimestamps,
                                                                            10,
                                                                          ),
                                                                          groupNumber,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ).toList()
                                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InfoColorBox(
                                      text: 'VIEWS',
                                      width: width,
                                      property: (postsData['postViewsTimestamp']
                                              as List)
                                          .length,
                                      color: const Color.fromRGBO(
                                        163,
                                        255,
                                        166,
                                        1,
                                      ),
                                      isHalf: true,
                                    ),
                                    InfoColorBox(
                                      text: 'WISHLISTS',
                                      property:
                                          (postsData['postWishlistTimestamp']
                                                  as Map)
                                              .length,
                                      width: width,
                                      color: const Color.fromRGBO(
                                        255,
                                        174,
                                        201,
                                        1,
                                      ),
                                      isHalf: true,
                                    ),
                                  ],
                                ),
                                Container(
                                  width: width,
                                  decoration: BoxDecoration(
                                    color: primary2.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: width * 0.0066,
                                    horizontal: width * 0.0066,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    vertical: width * 0.0125,
                                    horizontal: width * 0.01,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Post Wise Views',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark2,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.05,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.05,
                                                ),
                                                child: Text(
                                                  (postsData['postViewsTimestamp']
                                                                  as List)
                                                              .length >
                                                          1000000
                                                      ? '${(postsData['postViewsTimestamp'] as List).length.toString().substring(0, 1)}.${(postsData['postViewsTimestamp'] as List).length.toString().substring(1, 4)}M'
                                                      : (postsData['postViewsTimestamp']
                                                                      as List)
                                                                  .length >
                                                              1000
                                                          ? '${(postsData['postViewsTimestamp'] as List).length.toString().substring(0, 1)}.${(postsData['postViewsTimestamp'] as List).length.toString().substring(1, 4)}k'
                                                          : (postsData[
                                                                      'postViewsTimestamp']
                                                                  as List)
                                                              .length
                                                              .toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: width * 0.15,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width * 0.5,
                                                height: width * 0.5,
                                                child: PieChart(
                                                  PieChartData(
                                                    sections: postWiseData(
                                                      postWiseViews,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: width,
                                  decoration: BoxDecoration(
                                    color: primary2.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: width * 0.0066,
                                    horizontal: width * 0.0066,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    vertical: width * 0.0125,
                                    horizontal: width * 0.01,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Post Wise Wishlist',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark2,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.05,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.05,
                                                ),
                                                child: Text(
                                                  (postsData['postWishlistTimestamp']
                                                                  as Map)
                                                              .length >
                                                          1000000
                                                      ? '${(postsData['postWishlistTimestamp'] as Map).length.toString().substring(0, 1)}.${(postsData['postWishlistTimestamp'] as Map).length.toString().substring(1, 4)}M'
                                                      : (postsData['postWishlistTimestamp']
                                                                      as Map)
                                                                  .length >
                                                              1000
                                                          ? '${(postsData['postWishlistTimestamp'] as Map).length.toString().substring(0, 1)}.${(postsData['postWishlistTimestamp'] as Map).length.toString().substring(1, 4)}k'
                                                          : (postsData[
                                                                      'postWishlistTimestamp']
                                                                  as Map)
                                                              .length
                                                              .toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: primaryDark2,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: width * 0.15,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width * 0.5,
                                                height: width * 0.5,
                                                child: PieChart(
                                                  PieChartData(
                                                    pieTouchData:
                                                        PieTouchData(),
                                                    sections: postWiseData(
                                                      postWiseWishlist,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InfoColorBox(
                                      text: 'Most Viewed',
                                      property: maxpostViewsValue > 0
                                          ? maxpostViewsName
                                          : 'None',
                                      width: width,
                                      color: const Color.fromRGBO(
                                        255,
                                        135,
                                        175,
                                        1,
                                      ),
                                      isHalf: true,
                                    ),
                                    InfoColorBox(
                                      text: 'Most Wishlisted',
                                      property: maxpostWishlistName,
                                      width: width,
                                      color: const Color.fromRGBO(
                                        251,
                                        135,
                                        255,
                                        1,
                                      ),
                                      isHalf: true,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          return const Center(
                            child: LoadingIndicator(),
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
      ),
    );
  }
}
