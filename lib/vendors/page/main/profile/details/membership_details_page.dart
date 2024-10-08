import 'package:ls_business/vendors/page/register/membership_page.dart';
import 'package:ls_business/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ls_business/widgets/video_tutorial.dart';

class MembershipDetailsPage extends StatefulWidget {
  const MembershipDetailsPage({super.key});

  @override
  State<MembershipDetailsPage> createState() => _MembershipDetailsPageState();
}

class _MembershipDetailsPageState extends State<MembershipDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  Color? lightColor;
  Color? darkColor;
  Map<String, dynamic>? data;
  bool isData = false;

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

    setState(() {
      if (vendorData['MembershipName'] == 'Premium') {
        lightColor = const Color.fromRGBO(202, 226, 238, 1);
        darkColor = const Color.fromARGB(255, 12, 48, 66);
      } else if (vendorData['MembershipName'] == 'Gold') {
        lightColor = const Color.fromRGBO(253, 243, 154, 1);
        darkColor = const Color.fromARGB(255, 82, 76, 23);
      } else if (vendorData['MembershipName'] == 'Basic') {
        lightColor = const Color.fromRGBO(235, 235, 235, 1);
        darkColor = const Color.fromRGBO(20, 20, 20, 1);
      } else {
        lightColor = const Color.fromRGBO(200, 200, 200, 1);
        darkColor = const Color.fromRGBO(100, 100, 100, 1);
      }
    });

    setState(() {
      data = vendorData;
    });
  }

  // SHOW CHANGE MEMBERSHIP DIALOG
  Future<void> showChangeMembershipDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Membership'),
          content: const Text(
            'It will cancel this membership, and you have to get a new Membership by paying',
          ),
          actions: [
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'NO',
              textColor: darkColor!,
            ),
            MyTextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SelectMembershipPage(
                      hasAvailedLaunchOffer: true,
                    ),
                  ),
                );
              },
              text: 'YES',
              textColor: darkColor!,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Details'),
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
        child: data == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  return Padding(
                    padding: EdgeInsets.all(
                      width * 0.0125,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: width,
                            height: height * 0.2,
                            decoration: BoxDecoration(
                              color: lightColor,
                              border: Border.all(
                                color: darkColor!,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                data!['MembershipName'].toString().trim(),
                                style: TextStyle(
                                  color: darkColor,
                                  fontSize: width * 0.1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          // START
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: lightColor,
                              border: Border.all(
                                color: darkColor!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0125,
                              vertical: height * 0.01,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.006125,
                              vertical: height * 0.01,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Membership Start Time',
                                  style: TextStyle(
                                    color: darkColor!.withOpacity(0.75),
                                    fontSize: width * 0.03,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMMM yyyy')
                                      .format((data!['MembershipStartDateTime']
                                              as Timestamp)
                                          .toDate())
                                      .toString()
                                      .trim(),
                                  style: TextStyle(
                                    color: darkColor!,
                                    fontSize: width * 0.05,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // END
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: lightColor,
                              border: Border.all(
                                color: darkColor!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0125,
                              vertical: height * 0.01,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.006125,
                              vertical: height * 0.01,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Membership End Time',
                                  style: TextStyle(
                                    color: darkColor!.withOpacity(0.75),
                                    fontSize: width * 0.03,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMMM yyyy')
                                      .format((data!['MembershipEndDateTime']
                                              as Timestamp)
                                          .toDate())
                                      .toString()
                                      .trim(),
                                  style: TextStyle(
                                    color: darkColor,
                                    fontSize: width * 0.05,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // REMAINING
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: lightColor,
                              border: Border.all(
                                color: darkColor!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.0125,
                              vertical: height * 0.01,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.006125,
                              vertical: height * 0.01,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Days Remaining',
                                  style: TextStyle(
                                    color: darkColor!.withOpacity(0.75),
                                    fontSize: width * 0.03,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    Map<String, int> calculateMonthsAndDays(
                                        DateTime startDate, DateTime endDate) {
                                      int years = endDate.year - startDate.year;
                                      int months = endDate.month -
                                          startDate.month +
                                          (years * 12);
                                      int days = endDate.day - startDate.day;

                                      if (days < 0) {
                                        months -= 1;
                                        DateTime prevMonthDate = DateTime(
                                          endDate.year,
                                          endDate.month,
                                          0,
                                        );
                                        days += prevMonthDate.day;
                                      }

                                      return {'months': months, 'days': days};
                                    }

                                    final DateTime startDate = DateTime.now();
                                    final DateTime endDate =
                                        (data!['MembershipEndDateTime']
                                                as Timestamp)
                                            .toDate();

                                    final Map<String, int> duration =
                                        calculateMonthsAndDays(
                                      startDate,
                                      endDate,
                                    );

                                    final int months = duration['months']!;
                                    final int days = duration['days']!;

                                    return Text(
                                      '${months > 0 ? '$months ${months == 1 ? 'month' : 'months'}' : ''}'
                                      '${months > 0 && days > 0 ? ' and ' : ''}'
                                      '${days > 0 ? '$days ${days == 1 ? 'day' : 'days'}' : ''}'
                                      ' remaining',
                                      style: TextStyle(
                                        color: darkColor,
                                        fontSize: width * 0.05,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          MyTextButton(
                            onPressed: () async {
                              await showChangeMembershipDialog();
                            },
                            text: 'CHANGE MEMBERSHIP',
                            textColor: Colors.red,
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
