import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:ls_business/widgets/text_button.dart';

class ConnectivityNotificationWidget extends StatefulWidget {
  const ConnectivityNotificationWidget({super.key});

  @override
  State<ConnectivityNotificationWidget> createState() {
    return _ConnectivityNotificationWidgetState();
  }
}

class _ConnectivityNotificationWidgetState
    extends State<ConnectivityNotificationWidget> {
  // ignore: unused_field
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // INIT STATE
  @override
  void initState() {
    super.initState();
    connectivityInitialize();
  }

  // DISPOSE
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // CONNECTIVITY INTIALIZE
  Future<void> connectivityInitialize() async {
    try {
      List<ConnectivityResult> initialStatus =
          await Connectivity().checkConnectivity().then(
                (value) => value,
              );

      if (initialStatus.isNotEmpty) {
        await updateConnectionStatus(initialStatus);
      }

      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> results) {
        updateConnectionStatus(results);
      });
    } catch (e) {
      debugPrint("Error initializing connectivity: $e");
    }
  }

  // UPDATE CONNECTION STATUS
  Future<void> updateConnectionStatus(List<ConnectivityResult> results) async {
    if (results.isEmpty) return;

    final currentStatus = results.first;
    setState(() {
      _connectionStatus = currentStatus;
    });

    if (currentStatus == ConnectivityResult.none) {
      // Show dialog when there is no connectivity
      _showNoConnectivityDialog();
    }
  }

  // SHOW NO CONNECTIVITY DIALOG
  void _showNoConnectivityDialog() {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            alignment: Alignment.center,
            title: const Text('No Internet'),
            content: const Text('Turn on Mobile Internet or WiFi to continue'),
            actions: [
              MyTextButton(
                onTap: () async {
                  final currentStatus =
                      await Connectivity().checkConnectivity();

                  if (currentStatus.first != ConnectivityResult.none) {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                text: 'Retry',
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
