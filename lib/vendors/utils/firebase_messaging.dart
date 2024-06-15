import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class Messaging {
  final messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      await messaging.requestPermission();
    } catch (e) {
      print('Permission error: $e');
    }
    final token = await messaging.getToken();
    print('Token: $token');
    FirebaseMessaging.onBackgroundMessage((message) {
      return handleBackgroundMessage(message);
    });
  }
}
