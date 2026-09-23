import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/member.dart';

/// Topics FCM — el backend envía a topics, no a tokens:
/// `all_members`, `branch_{id}`, `expired_members`.
class PushNotificationService {
  PushNotificationService._();

  static Future<void> initialize() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        debugPrint(
          'FCM foreground: ${notification.title} · ${notification.body}',
        );
      }
    });
    await fcm.subscribeToTopic('all_members');
  }

  /// Suscribe los topics del perfil del socio — llamar tras login y
  /// cuando cambie su sede/estatus de membresía.
  static Future<void> syncTopics(Member? member, {Member? previous}) async {
    final fcm = FirebaseMessaging.instance;
    final next = <String>{
      if (member?.branchId != null) 'branch_${member!.branchId}',
      if (member != null && !member.isActive) 'expired_members',
    };
    final prev = <String>{
      if (previous?.branchId != null) 'branch_${previous!.branchId}',
      if (previous != null && !previous.isActive) 'expired_members',
    };
    for (final topic in prev.difference(next)) {
      await fcm.unsubscribeFromTopic(topic);
    }
    for (final topic in next.difference(prev)) {
      await fcm.subscribeToTopic(topic);
    }
  }
}
