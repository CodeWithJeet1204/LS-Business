import 'dart:math';
import 'package:ls_business/vendors/provider/main_page_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ls_business/vendors/utils/colors.dart';
import 'package:ls_business/widgets/info_color_box.dart';
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
  Map<String, Map<String, dynamic>> shorts = {};
  String? selectedStringDuration = '7 Days';
  DateTime? selectedDuration = DateTime.now().subtract(
    const Duration(
      days: 7,
    ),
  );

  // INIT STATE
  @override
  void initState() {
    getShortsData();
    super.initState();
  }

  // GET SHORTS DATA
  Future<void> getShortsData() async {
    Map<String, Map<String, dynamic>> myShorts = {};
    final shortsSnap = await store
        .collection('Business')
        .doc('Data')
        .collection('Shorts')
        .where('vendorId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (var shorts in shortsSnap.docs) {
      final shortsData = shorts.data();

      final shortsKey = shorts.id;
      myShorts[shortsKey] = shortsData;
    }

    setState(() {
      shorts = myShorts;
    });
  }

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PRODUCT DATA',
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
                      SizedBox(height: 12),
                      StreamBuilder(
                        stream: productStream,
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
                                    'No Products Added',
                                    textAlign: TextAlign.center,
                                  ),
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
                            Map<String, dynamic> shortsData = {
                              'shortsViewsTimestamp': [],
                            };
                            int index = 0;
                            for (var product in productSnap) {
                              productData['productViewsTimestamp'] +=
                                  product['productViewsTimestamp'];

                              (productData['productWishlistTimestamp'] as Map)
                                  .addAll(
                                (product['productWishlistTimestamp'] as Map)
                                    .map(
                                  (key, value) => MapEntry(
                                    '$key$index',
                                    value,
                                  ),
                                ),
                              );

                              (productData['productLikesTimestamp'] as Map)
                                  .addAll(
                                (product['productLikesTimestamp'] as Map).map(
                                  (key, value) => MapEntry(
                                    '$key$index',
                                    value,
                                  ),
                                ),
                              );

                              productData['shares'] += product['productShares'];

                              index++;
                            }

                            for (var short in shorts.entries) {
                              shortsData['shortsViewsTimestamp'] +=
                                  short.value['shortsViewsTimestamp'];
                            }

                            List<DateTime> productViewTimestamps = [];
                            List<DateTime> productWishlistTimestamps = [];
                            List<DateTime> shortsViewsTimestamps = [];

                            for (Timestamp viewDate
                                in productData['productViewsTimestamp']) {
                              if (selectedDuration != null) {
                                if (viewDate
                                    .toDate()
                                    .isAfter(selectedDuration!)) {
                                  productViewTimestamps.add(viewDate.toDate());
                                }
                              } else {
                                productViewTimestamps.add(viewDate.toDate());
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
                                  productWishlistTimestamps
                                      .add(wishlistTimestamp.toDate());
                                }
                              } else {
                                productWishlistTimestamps
                                    .add(wishlistTimestamp.toDate());
                              }
                            }

                            for (Timestamp viewDate
                                in shortsData['shortsViewsTimestamp']) {
                              if (selectedDuration != null) {
                                if (viewDate
                                    .toDate()
                                    .isAfter(selectedDuration!)) {
                                  shortsViewsTimestamps.add(viewDate.toDate());
                                }
                              } else {
                                shortsViewsTimestamps.add(viewDate.toDate());
                              }
                            }

                            Map<String, int> productWiseViews = {};
                            Map<String, int> productWiseWishlist = {};
                            Map<String, int> shortsWiseViews = {};

                            for (var product in productSnap) {
                              productWiseViews[product['productName']] =
                                  (product['productViewsTimestamp'] as List)
                                      .length;
                            }

                            for (var product in productSnap) {
                              productWiseWishlist[product['productName']] =
                                  (product['productWishlistTimestamp'] as Map)
                                      .length;
                            }

                            for (var short in shorts.entries) {
                              print('short.value: ${short.value}');
                              shortsWiseViews[short.value['productName'] ??
                                      short.value['caption']] =
                                  (short.value['shortsViewsTimestamp'] as List)
                                      .length;
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

                            String maxShortsViewsKey = '-';
                            int maxShortsViewsValue = 0;
                            shortsWiseViews.forEach((key, value) {
                              if (value > maxShortsViewsValue) {
                                maxShortsViewsKey = key;
                                maxShortsViewsValue = value;
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
                                              'Product Views',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * 0.05,
                                              ),
                                            ),
                                            Text(
                                              productViewTimestamps.length >
                                                      1000000
                                                  ? '${productViewTimestamps.length.toString().substring(0)}.${productViewTimestamps.length.toString().substring(1, 3)}M'
                                                  : productViewTimestamps
                                                              .length >
                                                          1000
                                                      ? '${productViewTimestamps.length.toString().substring(0)}.${productViewTimestamps.length.toString().substring(1, 3)}k'
                                                      : productViewTimestamps
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
                                            maxY: productViewTimestamps.length
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
                                                            productViewTimestamps,
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
                                                                productViewTimestamps,
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
                                                                    productViewTimestamps,
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
                                                                        productViewTimestamps,
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
                                                                            productViewTimestamps,
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
                                              'Product Wishlist',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * 0.05,
                                              ),
                                            ),
                                            Text(
                                              productWishlistTimestamps.length >
                                                      1000000
                                                  ? '${productWishlistTimestamps.length.toString().substring(0)}.${productWishlistTimestamps.length.toString().substring(1, 3)}M'
                                                  : productWishlistTimestamps
                                                              .length >
                                                          1000
                                                      ? '${productWishlistTimestamps.length.toString().substring(0)}.${productWishlistTimestamps.length.toString().substring(1, 3)}k'
                                                      : productWishlistTimestamps
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
                                            maxY: productWishlistTimestamps
                                                .length
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
                                                            productWishlistTimestamps,
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
                                                                productWishlistTimestamps,
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
                                                                    productWishlistTimestamps,
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
                                                                        productWishlistTimestamps,
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
                                                                            productWishlistTimestamps,
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
                                              'Shorts Views',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: primaryDark2,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * 0.05,
                                              ),
                                            ),
                                            Text(
                                              shortsViewsTimestamps.length >
                                                      1000000
                                                  ? '${shortsViewsTimestamps.length.toString().substring(0)}.${shortsViewsTimestamps.length.toString().substring(1, 3)}M'
                                                  : shortsViewsTimestamps
                                                              .length >
                                                          1000
                                                      ? '${shortsViewsTimestamps.length.toString().substring(0)}.${shortsViewsTimestamps.length.toString().substring(1, 3)}k'
                                                      : shortsViewsTimestamps
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
                                            maxY: shortsViewsTimestamps.length
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
                                                            shortsViewsTimestamps,
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
                                                                shortsViewsTimestamps,
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
                                                                    shortsViewsTimestamps,
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
                                                                        shortsViewsTimestamps,
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
                                                                            shortsViewsTimestamps,
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
                                      property:
                                          (productData['productViewsTimestamp']
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
                                      text: 'LIKES',
                                      width: width,
                                      property:
                                          (productData['productLikesTimestamp']
                                                  as Map)
                                              .length,
                                      color: const Color.fromRGBO(
                                        237,
                                        255,
                                        163,
                                        1,
                                      ),
                                      isHalf: true,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: width * 0.015,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
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
                                        isHalf: true,
                                      ),
                                      InfoColorBox(
                                        text: 'SHARES',
                                        property: productData['shares'],
                                        width: width,
                                        color: const Color.fromRGBO(
                                          253,
                                          182,
                                          255,
                                          1,
                                        ),
                                        isHalf: true,
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
                                            'Shorts Wise Views',
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
                                                  (shortsData['shortsViewsTimestamp']
                                                                  as List)
                                                              .length >
                                                          1000000
                                                      ? '${(shortsData['shortsViewsTimestamp'] as List).length.toString().substring(0, 1)}.${(shortsData['shortsViewsTimestamp'] as List).length.toString().substring(1, 4)}M'
                                                      : (shortsData['shortsViewsTimestamp']
                                                                      as List)
                                                                  .length >
                                                              1000
                                                          ? '${(shortsData['shortsViewsTimestamp'] as List).length.toString().substring(0, 1)}.${(shortsData['shortsViewsTimestamp'] as List).length.toString().substring(1, 4)}k'
                                                          : (shortsData[
                                                                      'shortsViewsTimestamp']
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
                                                      shortsWiseViews,
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
                                      property: maxProductViewsKey,
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
                                      property: maxProductWishlistKey,
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
                                SizedBox(
                                  height: width * 0.375,
                                  child: InfoColorBox(
                                    text: 'Most Viewed Shorts',
                                    property: maxShortsViewsKey,
                                    width: width,
                                    color: const Color.fromRGBO(
                                      251,
                                      135,
                                      255,
                                      1,
                                    ),
                                    isHalf: false,
                                  ),
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
