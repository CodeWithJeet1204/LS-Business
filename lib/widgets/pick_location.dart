import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:localy/events/event_page.dart';
import 'package:localy/events/provider/picked_location_provider.dart';
import 'package:localy/vendors/utils/colors.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:provider/provider.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({
    super.key,
    this.eventId,
  });

  final String? eventId;

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  final store = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final pickLocationProvider = Provider.of<PickLocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
      ),
      body: OpenStreetMapSearchAndPick(
        buttonColor: primaryDark,
        buttonText: 'Set Location',
        buttonHeight: 50,
        buttonWidth: MediaQuery.of(context).size.width * 0.8,
        buttonTextColor: white,
        onPicked: (pickedData) async {
          if (widget.eventId != null) {
            await store.collection('Events').doc(widget.eventId).update({
              'eventLatitude': pickLocationProvider.latitude,
              'eventLongitude': pickLocationProvider.longitude,
            });
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: ((context) => EventPage(eventId: widget.eventId!)),
                ),
              );
            }
          } else {
            pickLocationProvider.setLocation(
              pickedData.latLong.latitude,
              pickedData.latLong.longitude,
              pickedData.address,
            );
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
