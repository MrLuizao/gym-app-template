import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  PushNotificationService._();

  static Future<void> initialize() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        debugPrint('FCM foreground: ${notification.title} · ${notification.body}');
      }
    });
    final token = await fcm.getToken();
    if (token != null) {
      debugPrint('FCM token: $token');
    }
    await fcm.subscribeToTopic('all_members');
  }
}
