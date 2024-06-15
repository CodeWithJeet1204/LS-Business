import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {}

class Messaging {
  final messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      await messaging.requestPermission();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    // final token = await messaging.getToken();
    FirebaseMessaging.onBackgroundMessage((message) {
      return handleBackgroundMessage(message);
    });
  }
}
