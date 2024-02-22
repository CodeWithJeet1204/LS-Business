import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_easy/utils/colors.dart';
import 'package:find_easy/widgets/info_color_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProductAnalyticsPage extends StatefulWidget {
  const ProductAnalyticsPage({Key? key}) : super(key: key);

  @override
  State<ProductAnalyticsPage> createState() => _ProductAnalyticsPageState();
}

class _ProductAnalyticsPageState extends State<ProductAnalyticsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  String? selectedStringDuration = '7 Days';
  DateTime? selectedDuration = DateTime.now().subtract(
    Duration(days: 7),
  );

  // SELECTING DURATION
  void selectDate(String date) {
    if (date == '24 Hours') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          Duration(days: 1),
        );
      });
    }
    if (date == '7 Days') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          Duration(days: 7),
        );
      });
    }
    if (date == '28 Days') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          Duration(days: 28),
        );
      });
    }
    if (date == '365 Days') {
      setState(() {
        selectedDuration = DateTime.now().subtract(
          Duration(days: 365),
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

  List<PieChartSectionData> productWiseData(Map<String, int> productWiseData) {
    List<PieChartSectionData> pieChartSections = [];

    int totalViews = productWiseData.values.reduce((sum, views) => sum + views);

    productWiseData.forEach((productName, data) {
      int dataCount = data;
      if (dataCount > 0) {
        double percentage = dataCount / totalViews;
        double value = totalViews * percentage;

        PieChartSectionData section = PieChartSectionData(
          value: value.toDouble(),
          title: productName,
          titleStyle: TextStyle(
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

    // Define the three base colors
    Color baseColor1 = Colors.red;
    Color baseColor2 = Colors.green;
    Color baseColor3 = Colors.blue;

    // Define the weights for each color (random)
    double weight1 = random.nextDouble();
    double weight2 = random.nextDouble();
    double weight3 = random.nextDouble();
    double sumWeights = weight1 + weight2 + weight3;

    // Normalize the weights to sum up to 1
    weight1 /= sumWeights;
    weight2 /= sumWeights;
    weight3 /= sumWeights;

    // Calculate the weighted average of the RGB components
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

    // Create the new color
    return Color.fromARGB(255, red, green, blue);
  }

  @override
  Widget build(BuildContext context) {
    final productStream = store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.035,
                vertical: width * 0.0125,
              ),
              child: SingleChildScrollView(
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
                            overflow: TextOverflow.ellipsis,
                            'PRODUCT DATA',
                            style: TextStyle(
                              color: primaryDark,
                              fontWeight: FontWeight.w500,
                              fontSize: width * 0.06,
                            ),
                          ),
                          // TIME
                          Container(
                            width: width * 0.4,
                            height: width * 0.125,
                            decoration: BoxDecoration(
                              color: primary2.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: width * 0.05),
                              child: DropdownButton(
                                hint: Text(
                                    overflow: TextOverflow.ellipsis,
                                    "Select Duration"),
                                value: selectedStringDuration,
                                underline: SizedBox(),
                                dropdownColor: primary2,
                                items: [
                                  '24 Hours',
                                  '7 Days',
                                  '28 Days',
                                  '365 Days',
                                  'Lifetime'
                                ]
                                    .map((e) => DropdownMenuItem(
                                          child: Text(
                                              overflow: TextOverflow.ellipsis,
                                              e),
                                          value: e,
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

                    // PRODUCT STREAM
                    StreamBuilder(
                      stream: productStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                overflow: TextOverflow.ellipsis,
                                'Something went wrong'),
                          );
                        }

                        if (snapshot.data != null) {
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'No Products Added'),
                            );
                          }
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: Text(
                                overflow: TextOverflow.ellipsis, 'No Data'),
                          );
                        }

                        if (snapshot.hasData) {
                          final productSnap = snapshot.data!.docs;
                          Map<String, dynamic> productData = {
                            'views': 0,
                            'viewsTimestamp': [],
                            'likes': 0,
                            'likesTimestamp': [],
                            'wishlists': 0,
                            'shares': 0,
                          };
                          productSnap.forEach((element) {
                            productData['views'] += element['productViews'];
                            productData['viewsTimestamp'] +=
                                element['productViewsTimestamp'];
                            productData['likes'] += element['productLikes'];
                            productData['likesTimestamp'] +=
                                element['productLikesTimestamp'];
                            productData['wishlists'] +=
                                element['productWishlist'];
                            productData['shares'] += element['productShares'];
                          });

                          List<DateTime> viewTimestamps = [];
                          List<DateTime> likeTimestamps = [];

                          for (Timestamp viewDate
                              in productData['viewsTimestamp']) {
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

                          for (Timestamp likeTimestamp
                              in productData['likesTimestamp']) {
                            if (selectedDuration != null) {
                              if (likeTimestamp
                                  .toDate()
                                  .isAfter(selectedDuration!)) {
                                likeTimestamps.add(likeTimestamp.toDate());
                              }
                            } else {
                              likeTimestamps.add(likeTimestamp.toDate());
                            }
                          }

                          Map<String, int> productWiseViews = {};

                          productSnap.forEach((element) {
                            productWiseViews.addAll({
                              element['productName'].toString():
                                  (element['productViews']),
                            });
                          });

                          Map<String, int> productWiseLikes = {};

                          productSnap.forEach((element) {
                            productWiseLikes.addAll({
                              element['productName'].toString():
                                  (element['productLikes']),
                            });
                          });

                          String maxProductViewsKey = '-';
                          int maxProductViewsValue = 0;
                          productWiseViews.forEach((key, value) {
                            if (value > maxProductViewsValue) {
                              maxProductViewsKey = key;
                              maxProductViewsValue = value;
                            }
                          });

                          String maxProductLikesKey = '-';
                          int maxProductLikesValue = 0;
                          productWiseLikes.forEach((key, value) {
                            if (value > maxProductLikesValue) {
                              maxProductLikesKey = key;
                              maxProductLikesValue = value;
                            }
                          });

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
                                            overflow: TextOverflow.ellipsis,
                                            'Product Views',
                                            style: TextStyle(
                                              color: primaryDark2,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.05,
                                            ),
                                          ),
                                          // VALUE
                                          Text(
                                            overflow: TextOverflow.ellipsis,
                                            viewTimestamps.length > 1000000
                                                ? '${viewTimestamps.length.toString().substring(0)}.${viewTimestamps.length.toString().substring(1, 3)}M'
                                                : viewTimestamps.length > 1000
                                                    ? '${viewTimestamps.length.toString().substring(0)}.${viewTimestamps.length.toString().substring(1, 3)}k'
                                                    : viewTimestamps.length
                                                        .toString(),
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
                                          gridData: FlGridData(
                                            drawVerticalLine: false,
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: width * 0.0685,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
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
                                                          Duration(days: 1),
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
                                                              Duration(days: 7),
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
                                                                  Duration(
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
                                                                      Duration(
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
                                                                          Duration(
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

                              // TIMED LIKES
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
                                            overflow: TextOverflow.ellipsis,
                                            'Product Likes',
                                            style: TextStyle(
                                              color: primaryDark2,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.05,
                                            ),
                                          ),
                                          // VALUE
                                          Text(
                                            overflow: TextOverflow.ellipsis,
                                            likeTimestamps.length > 1000000
                                                ? '${likeTimestamps.length.toString().substring(0)}.${likeTimestamps.length.toString().substring(1, 3)}M'
                                                : likeTimestamps.length > 1000
                                                    ? '${likeTimestamps.length.toString().substring(0)}.${likeTimestamps.length.toString().substring(1, 3)}k'
                                                    : likeTimestamps.length
                                                        .toString(),
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
                                          maxY: likeTimestamps.length * 2,
                                          gridData: FlGridData(
                                            drawVerticalLine: false,
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: width * 0.0685,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
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
                                                          Duration(days: 1),
                                                        ),
                                                        likeTimestamps,
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
                                                              Duration(days: 7),
                                                            ),
                                                            likeTimestamps,
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
                                                                  Duration(
                                                                    days: 28,
                                                                  ),
                                                                ),
                                                                likeTimestamps,
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
                                                                      Duration(
                                                                        days:
                                                                            365,
                                                                      ),
                                                                    ),
                                                                    likeTimestamps,
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
                                                                          Duration(
                                                                            days:
                                                                                10000,
                                                                          ),
                                                                        ),
                                                                        likeTimestamps,
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

                              // ALL TIME VIEWS AND LIKES
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ALL VIEWS
                                  InfoColorBox(
                                    text: 'VIEWS',
                                    width: width,
                                    property: productData['views'],
                                    color: Color.fromARGB(255, 163, 255, 166),
                                  ),

                                  // ALL LIKES
                                  InfoColorBox(
                                    text: 'LIKES',
                                    width: width,
                                    property: productData['likes'],
                                    color: Color.fromARGB(255, 237, 255, 163),
                                  ),
                                ],
                              ),

                              // WISHLIST & SHARES
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: width * 0.015,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ALL TIME WISHLIST
                                    InfoColorBox(
                                      text: 'WISHLISTS',
                                      property: productData['wishlists'],
                                      width: width,
                                      color: Color.fromRGBO(255, 174, 201, 1),
                                    ),

                                    // ALL TIME SHARES
                                    InfoColorBox(
                                      text: 'SHARES',
                                      property: productData['shares'],
                                      width: width,
                                      color: Color.fromRGBO(253, 182, 255, 1),
                                    ),
                                  ],
                                ),
                              ),

                              // PRODUCT WISE VIEWS
                              Container(
                                width: width,
                                height: width * 0.575,
                                margin: EdgeInsets.symmetric(
                                  vertical: width * 0.066,
                                  horizontal: width * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          overflow: TextOverflow.ellipsis,
                                          'Product Wise Views',
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
                                                overflow: TextOverflow.ellipsis,
                                                productData['views'] > 1000000
                                                    ? productData['views']
                                                            .toString()
                                                            .substring(0, 1) +
                                                        '.' +
                                                        productData['views']
                                                            .toString()
                                                            .substring(1, 4) +
                                                        'M'
                                                    : productData['views'] >
                                                            1000
                                                        ? productData['views']
                                                                .toString()
                                                                .substring(
                                                                    0, 1) +
                                                            '.' +
                                                            productData['views']
                                                                .toString()
                                                                .substring(
                                                                    1, 4) +
                                                            'k'
                                                        : productData['views']
                                                            .toString(),
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
                                                  pieTouchData: PieTouchData(),
                                                  sections: productWiseData(
                                                    productWiseViews,
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

                              // PRODUCT WISE LIKES
                              Container(
                                width: width,
                                height: width * 0.575,
                                margin: EdgeInsets.symmetric(
                                  vertical: width * 0.066,
                                  horizontal: width * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: primary2.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          overflow: TextOverflow.ellipsis,
                                          'Product Wise Likes',
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
                                                overflow: TextOverflow.ellipsis,
                                                productData['likes'] > 1000000
                                                    ? productData['likes']
                                                            .toString()
                                                            .substring(0, 1) +
                                                        '.' +
                                                        productData['likes']
                                                            .toString()
                                                            .substring(1, 4) +
                                                        'M'
                                                    : productData['likes'] >
                                                            1000
                                                        ? productData['likes']
                                                                .toString()
                                                                .substring(
                                                                    0, 1) +
                                                            '.' +
                                                            productData['likes']
                                                                .toString()
                                                                .substring(
                                                                    1, 4) +
                                                            'k'
                                                        : productData['likes']
                                                            .toString(),
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
                                                  pieTouchData: PieTouchData(),
                                                  sections: productWiseData(
                                                    productWiseLikes,
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

                              // VIEWS & LIKES
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // PRODUCT WITH MOST VIEWS
                                  InfoColorBox(
                                    text: 'Most Viewed',
                                    property: maxProductViewsKey,
                                    width: width,
                                    color: Color.fromRGBO(255, 135, 175, 1),
                                  ),

                                  // PRODUCT WITH MOST LIKES
                                  InfoColorBox(
                                    text: 'Most Liked',
                                    property: maxProductLikesKey,
                                    width: width,
                                    color: Color.fromRGBO(251, 135, 255, 1),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        return Center(
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
