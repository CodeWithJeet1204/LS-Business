import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityNotificationWidget extends StatefulWidget {
  const ConnectivityNotificationWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnectivityNotificationWidgetState createState() =>
      _ConnectivityNotificationWidgetState();
}

class _ConnectivityNotificationWidgetState
    extends State<ConnectivityNotificationWidget> {
  ConnectivityResult _connectionStatus =
      ConnectivityResult.none; // Initialize with a value
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    connectivityInitialize();
  }

  void connectivityInitialize() async {
    // Get initial connection status and listen for changes
    _connectivitySubscription = await Connectivity()
        .onConnectivityChanged
        .first
        .then((initialResult) => _updateConnectionStatus(initialResult))
        .then((_) => Connectivity()
            .onConnectivityChanged
            .listen(_updateConnectionStatus));
  }

  @override
  void dispose() {
    // Cancel the subscription to avoid memory leaks
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _connectionStatus = result;
    });

    // Show the dialog if internet is lost
    if (result == ConnectivityResult.none) {
      _showConnectivityDialog(context);
    }
  }

  void _showConnectivityDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissal unless reconnected
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              overflow: TextOverflow.ellipsis, 'No Internet Connection'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    overflow: TextOverflow.ellipsis,
                    'You are currently offline.'),
                Text(
                    overflow: TextOverflow.ellipsis,
                    'Connect to network to continue using the app'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(overflow: TextOverflow.ellipsis, 'Retry'),
              onPressed: () async {
                final currentStatus = await Connectivity().checkConnectivity();
                if (currentStatus != ConnectivityResult.none) {
                  // Internet is back, dismiss dialog
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _connectionStatus == ConnectivityResult.none,
      child: const Align(
        alignment: Alignment.topCenter,
        // child: Container(
        //   // Customize container color, padding, etc. based on your design
        //   color: Colors.red.withOpacity(0.8),
        //   padding: EdgeInsets.all(16.0),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.signal_cellular_off, color: Colors.white),
        //       SizedBox(width: 8.0),
        //       Text(
        //         'No internet connection.',
        //         style:
        //             TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
