import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:Localsearch/events/event_page.dart';
import 'package:Localsearch/vendors/utils/colors.dart';
import 'package:Localsearch/widgets/shimmer_skeleton_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsAllEventsPage extends StatefulWidget {
  const EventsAllEventsPage({super.key});

  @override
  State<EventsAllEventsPage> createState() => EventsAllEventsPageState();
}

class EventsAllEventsPageState extends State<EventsAllEventsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final searchController = TextEditingController();
  Map<String, dynamic> events = {};
  bool isGridView = true;
  bool isData = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    Map<String, dynamic> myEvents = {};
    final eventSnap = await store
        .collection('Events')
        .where('organizerId', isEqualTo: auth.currentUser!.uid)
        .get();

    for (var event in eventSnap.docs) {
      final eventData = event.data();

      final String eventId = eventData['eventId'];
      final String eventName = eventData['eventName'];
      final String eventImageUrl = eventData['imageUrl'][0];

      myEvents[eventId] = [eventName, eventImageUrl];
    }

    setState(() {
      events = myEvents;
      isData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'All Events',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            80,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.0166,
              vertical: MediaQuery.of(context).size.width * 0.0225,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autocorrect: false,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search ...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                  icon: Icon(
                    isGridView ? FeatherIcons.list : FeatherIcons.grid,
                  ),
                  tooltip: isGridView ? 'List View' : 'Grid View',
                ),
              ],
            ),
          ),
        ),
      ),
      body: isData
          ? Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.0125,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        isGridView
                            ? SizedBox(
                                width: width,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: events.length,
                                  itemBuilder: ((context, index) {
                                    final id = events.keys.toList()[index];
                                    final name =
                                        events.values.toList()[index][0];
                                    final imageUrl =
                                        events.values.toList()[index][1];

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: ((context) => EventPage(
                                                  eventId: id,
                                                )),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: primary2.withOpacity(0.125),
                                          border: Border.all(
                                            width: 0.25,
                                            color: primaryDark,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(width * 0.00625),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(
                                                width * 0.0125,
                                              ),
                                              child: Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    2,
                                                  ),
                                                  child: Container(
                                                    width: width * 0.5,
                                                    height: width * 0.5,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          imageUrl,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: width * 0.0125,
                                              ),
                                              child: SizedBox(
                                                width: width * 0.5,
                                                child: Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: width * 0.06,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              )
                            : isData
                                ? SizedBox(
                                    width: width,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: events.length,
                                      itemBuilder: ((context, index) {
                                        final id = events.keys.toList()[index];
                                        final name =
                                            events.keys.toList()[index];
                                        final imageUrl =
                                            events.values.toList()[index];

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) =>
                                                    EventPage(
                                                      eventId: id,
                                                    )),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: white,
                                              border: Border.all(
                                                width: 0.5,
                                                color: primaryDark,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            margin: EdgeInsets.all(
                                              width * 0.0125,
                                            ),
                                            child: ListTile(
                                              visualDensity:
                                                  VisualDensity.standard,
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  2,
                                                ),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: width * 0.15,
                                                  height: width * 0.15,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              title: Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: width * 0.05,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                                : SafeArea(
                                    child: isGridView
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 0,
                                              mainAxisSpacing: 0,
                                              childAspectRatio:
                                                  width * 0.5 / width * 1.6,
                                            ),
                                            itemCount: 4,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.all(
                                                  width * 0.02,
                                                ),
                                                child: GridViewSkeleton(
                                                  width: width,
                                                  isPrice: false,
                                                  isDelete: true,
                                                ),
                                              );
                                            },
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: 4,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.all(
                                                  width * 0.02,
                                                ),
                                                child: ListViewSkeleton(
                                                  width: width,
                                                  isPrice: false,
                                                  height: 30,
                                                  isDelete: true,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                      ],
                    ),
                  );
                },
              ),
            )
          : SafeArea(
              child: isGridView
                  ? GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: width * 0.5 / width * 1.6,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: GridViewSkeleton(
                            width: width,
                            isPrice: false,
                            isDelete: true,
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(
                            width * 0.02,
                          ),
                          child: ListViewSkeleton(
                            width: width,
                            isPrice: false,
                            height: 30,
                            isDelete: true,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
