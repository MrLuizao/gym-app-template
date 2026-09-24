import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/member.dart';

/// Topics FCM — el backend envía a topics, no a tokens:
/// `all_members`, `branch_{id}`, `expired_members`.
class PushNotificationService {
  PushNotificationService._();

  /// Tab destino al tocar una notificación — MainShell lo consume.
  /// kind: SPONSOR → Aliados, BRAND → Descuentos.
  static final StreamController<int> _tabRequests =
      StreamController<int>.broadcast();
  static Stream<int> get tabRequests => _tabRequests.stream;

  /// Notificación que abrió la app desde cold start — MainShell lo consume
  /// una sola vez tras el primer frame.
  static int? _initialTab;
  static int? takeInitialTab() {
    final tab = _initialTab;
    _initialTab = null;
    return tab;
  }

  /// Tab destino: el push puede traer `target` explícito; si no (o 'auto')
  /// cae al mapping por kind — SPONSOR → Aliados, BRAND → Descuentos.
  static int _tabFor(Map<String, dynamic> data) {
    const targets = {
      'home': 0,
      'explore': 1,
      'allies': 2,
      'promos': 3,
      'profile': 4,
    };
    return targets[data['target']] ?? (data['kind'] == 'SPONSOR' ? 2 : 3);
  }

  static Future<void> initialize() async {
    /// Topics FCM no existen en web — el token va por VAPID y se
    /// suscribe desde un service worker, no desde el cliente.
    if (kIsWeb) return;
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);
    /// iOS no muestra banner con la app abierta salvo que se pida explícito.
    await fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        debugPrint(
          'FCM foreground: ${notification.title} · ${notification.body}',
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _tabRequests.add(_tabFor(message.data));
    });
    final initial = await fcm.getInitialMessage();
    if (initial != null) _initialTab = _tabFor(initial.data);
    await fcm.subscribeToTopic('all_members');
  }

  /// Suscribe los topics del perfil del socio — llamar tras login y
  /// cuando cambie su sede/estatus de membresía.
  static Future<void> syncTopics(Member? member, {Member? previous}) async {
    if (kIsWeb) return;
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
