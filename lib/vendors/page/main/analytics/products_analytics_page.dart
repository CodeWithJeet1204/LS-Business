import 'dart:math';
import 'package:Localsearch/vendors/provider/main_page_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/info_color_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductAnalyticsPage extends StatefulWidget {
  const ProductAnalyticsPage({super.key});

  @override
  State<ProductAnalyticsPage> createState() => _ProductAnalyticsPageState();
}

class _ProductAnalyticsPageState extends State<ProductAnalyticsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  String? selectedStringDuration = '7 Days';
  DateTime? selectedDuration = DateTime.now().subtract(
    const Duration(days: 7),
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

  List<PieChartSectionData> productWiseData(Map<String, int> productWiseData) {
    List<PieChartSectionData> pieChartSections = [];

    int totalViews =
        productWiseData.values.reduce((summation, views) => summation + views);

    productWiseData.forEach((productName, data) {
      int dataCount = data;
      if (dataCount > 0) {
        double percentage = dataCount / totalViews;
        double value = totalViews * percentage;

        PieChartSectionData section = PieChartSectionData(
          value: value.toDouble(),
          title: productName.length > 8
              ? '${productName.substring(0, 8)}...'
              : productName,
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
    final mainPageProvider = Provider.of<MainPageProvider>(context);
    final productStream = store
        .collection('Business')
        .doc('Data')
        .collection('Products')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
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
                              'PRODUCT DATA',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryDark,
                                fontSize: width * 0.045,
                              ),
                            ),
                            // TIME
                            Container(
                              decoration: BoxDecoration(
                                color: primary2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.025,
                              ),
                              child: DropdownButton(
                                // hint: const Text(
                                //   'Select Duration',
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
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
                          ],
                        ),
                      ),

                      // PRODUCT STREAM
                      StreamBuilder(
                        stream: productStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                'Something went wrong',
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                'No Data',
                              ),
                            );
                          }

                          if (snapshot.hasData) {
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No Products Added',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }
                            final productSnap = snapshot.data!.docs;
                            Map<String, dynamic> productData = {
                              'productViewsTimestamp': [],
                              'productWishlistTimestamp': {},
                              'productLikesTimestamp': {},
                              'shares': 0,
                            };
                            int index = 0;
                            for (var element in productSnap) {
                              productData['productViewsTimestamp'] +=
                                  element['productViewsTimestamp'];

                              (productData['productWishlistTimestamp'] as Map)
                                  .addAll(
                                (element['productWishlistTimestamp'] as Map)
                                    .map(
                                  (key, value) => MapEntry(
                                    '$key$index',
                                    value,
                                  ),
                                ),
                              );

                              (productData['productLikesTimestamp'] as Map)
                                  .addAll(
                                (element['productLikesTimestamp'] as Map).map(
                                  (key, value) => MapEntry(
                                    '$key$index',
                                    value,
                                  ),
                                ),
                              );

                              productData['shares'] += element['productShares'];

                              index++;
                            }

                            List<DateTime> viewTimestamps = [];
                            List<DateTime> wishlistTimestamps = [];

                            for (Timestamp viewDate
                                in productData['productViewsTimestamp']) {
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

                            for (Timestamp wishlistTimestamp
                                in (productData['productWishlistTimestamp']
                                        as Map)
                                    .values) {
                              if (selectedDuration != null) {
                                if (wishlistTimestamp
                                    .toDate()
                                    .isAfter(selectedDuration!)) {
                                  wishlistTimestamps
                                      .add(wishlistTimestamp.toDate());
                                }
                              } else {
                                wishlistTimestamps
                                    .add(wishlistTimestamp.toDate());
                              }
                            }

                            Map<String, int> productWiseViews = {};

                            for (var element in productSnap) {
                              productWiseViews.addAll({
                                element['productName'].toString():
                                    ((element['productViewsTimestamp'] as List)
                                        .length),
                              });
                            }

                            Map<String, int> productWiseWishlist = {};

                            for (var element in productSnap) {
                              productWiseWishlist.addAll({
                                element['productName'].toString():
                                    (element['productWishlistTimestamp'] as Map)
                                        .length,
                              });
                            }

                            String maxProductViewsKey = '-';
                            int maxProductViewsValue = 0;
                            productWiseViews.forEach((key, value) {
                              if (value > maxProductViewsValue) {
                                maxProductViewsKey = key;
                                maxProductViewsValue = value;
                              }
                            });

                            String maxProductWishlistKey = '-';
                            int maxProductWishlistValue = 0;
                            productWiseWishlist.forEach((key, value) {
                              if (value > maxProductWishlistValue) {
                                maxProductWishlistKey = key;
                                maxProductWishlistValue = value;
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              'Product Views',
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
                                        width: width,
                                        height: width * 0.3625,
                                        child: BarChart(
                                          BarChartData(
                                            maxY: viewTimestamps.length
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
                                                            viewTimestamps,
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
                                                                viewTimestamps,
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
                                                                    viewTimestamps,
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
                                                                        viewTimestamps,
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
                                                                            viewTimestamps,
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

                                // TIMED WISHLIST
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
                                              'Product Wishlist',
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
                                              wishlistTimestamps.length >
                                                      1000000
                                                  ? '${wishlistTimestamps.length.toString().substring(0)}.${wishlistTimestamps.length.toString().substring(1, 3)}M'
                                                  : wishlistTimestamps.length >
                                                          1000
                                                      ? '${wishlistTimestamps.length.toString().substring(0)}.${wishlistTimestamps.length.toString().substring(1, 3)}k'
                                                      : wishlistTimestamps
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

                                      // GRAPH
                                      SizedBox(
                                        width: width,
                                        height: width * 0.3625,
                                        child: BarChart(
                                          BarChartData(
                                            maxY: wishlistTimestamps.length
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      value.toStringAsFixed(0),
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
                                                            wishlistTimestamps,
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
                                                                wishlistTimestamps,
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
                                                                    wishlistTimestamps,
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
                                                                        wishlistTimestamps,
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
                                                                            wishlistTimestamps,
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

                                // ALL TIME VIEWS AND WISHLIST
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ALL VIEWS
                                    InfoColorBox(
                                      text: 'VIEWS',
                                      width: width,
                                      property:
                                          (productData['productViewsTimestamp']
                                                  as List)
                                              .length,
                                      color: const Color.fromRGBO(
                                          163, 255, 166, 1),
                                    ),

                                    // ALL LIKES
                                    InfoColorBox(
                                      text: 'LIKES',
                                      width: width,
                                      property:
                                          (productData['productLikesTimestamp']
                                                  as Map)
                                              .length,
                                      color: const Color.fromRGBO(
                                          237, 255, 163, 1),
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
                                        property: (productData[
                                                    'productWishlistTimestamp']
                                                as Map)
                                            .length,
                                        width: width,
                                        color: const Color.fromRGBO(
                                          255,
                                          174,
                                          201,
                                          1,
                                        ),
                                      ),

                                      // ALL TIME SHARES
                                      InfoColorBox(
                                        text: 'SHARES',
                                        property: productData['shares'],
                                        width: width,
                                        color: const Color.fromRGBO(
                                            253, 182, 255, 1),
                                      ),
                                    ],
                                  ),
                                ),

                                // PRODUCT WISE VIEWS
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
                                            'Product Wise Views',
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
                                                  (productData['productViewsTimestamp']
                                                                  as List)
                                                              .length >
                                                          1000000
                                                      ? '${(productData['productViewsTimestamp'] as List).length.toString().substring(0, 1)}.${(productData['productViewsTimestamp'] as List).length.toString().substring(1, 4)}M'
                                                      : (productData['productViewsTimestamp']
                                                                      as List)
                                                                  .length >
                                                              1000
                                                          ? '${(productData['productViewsTimestamp'] as List).length.toString().substring(0, 1)}.${(productData['productViewsTimestamp'] as List).length.toString().substring(1, 4)}k'
                                                          : (productData[
                                                                      'productViewsTimestamp']
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

                                // PRODUCT WISE WISHLIST
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
                                            'Product Wise Wishlist',
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
                                                  (productData['productWishlistTimestamp']
                                                                  as Map)
                                                              .length >
                                                          1000000
                                                      ? '${(productData['productWishlistTimestamp'] as Map).length.toString().substring(0, 1)}.${(productData['productWishlistTimestamp'] as Map).length.toString().substring(1, 4)}M'
                                                      : (productData['productWishlistTimestamp']
                                                                      as Map)
                                                                  .length >
                                                              1000
                                                          ? '${(productData['productWishlistTimestamp'] as Map).length.toString().substring(0, 1)}.${(productData['productWishlistTimestamp'] as Map).length.toString().substring(1, 4)}k'
                                                          : (productData[
                                                                      'productWishlistTimestamp']
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
                                                    sections: productWiseData(
                                                      productWiseWishlist,
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

                                // VIEWS & WISHLIST
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // PRODUCT WITH MOST VIEWS
                                    InfoColorBox(
                                      text: 'Most Viewed',
                                      property: maxProductViewsKey,
                                      width: width,
                                      color: const Color.fromRGBO(
                                          255, 135, 175, 1),
                                    ),

                                    // PRODUCT WITH MOST WISHLIST
                                    InfoColorBox(
                                      text: 'Most Wishlisted',
                                      property: maxProductWishlistKey,
                                      width: width,
                                      color: const Color.fromRGBO(
                                          251, 135, 255, 1),
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
      ),
    );
  }
}
