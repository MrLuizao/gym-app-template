import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/models/member.dart';

/// Topics FCM — el backend envía a topics, no a tokens:
/// `all_members`, `branch_{id}`, `expired_members`, `member_{id}`.
class PushNotificationService {
  PushNotificationService._();

  /// Tab destino al tocar una notificación — MainShell lo consume.
  /// kind: SPONSOR → Aliados, BRAND → Descuentos.
  static final StreamController<int> _tabRequests =
      StreamController<int>.broadcast();
  static Stream<int> get tabRequests => _tabRequests.stream;

  /// Tap en push de soporte (`data.type == 'support'`) — MainShell lo
  /// consume y abre el chat.
  static final StreamController<void> _supportRequests =
      StreamController<void>.broadcast();
  static Stream<void> get supportRequests => _supportRequests.stream;

  /// Tap en push de lealtad (`data.type == 'loyalty'`, p.ej. meta
  /// semanal cumplida) — MainShell abre la pantalla de Recompensas.
  static final StreamController<void> _rewardsRequests =
      StreamController<void>.broadcast();
  static Stream<void> get rewardsRequests => _rewardsRequests.stream;

  /// Notificación que abrió la app desde cold start — MainShell lo consume
  /// una sola vez tras el primer frame.
  static int? _initialTab;
  static int? takeInitialTab() {
    final tab = _initialTab;
    _initialTab = null;
    return tab;
  }

  static bool _initialSupport = false;
  static bool takeInitialSupport() {
    final flag = _initialSupport;
    _initialSupport = false;
    return flag;
  }

  static bool _initialRewards = false;
  static bool takeInitialRewards() {
    final flag = _initialRewards;
    _initialRewards = false;
    return flag;
  }

  /// Enruta el tap: soporte abre el chat, lealtad abre Recompensas; el
  /// resto cae al mapping por target/kind.
  static void _route(Map<String, dynamic> data) {
    if (data['type'] == 'support') {
      _supportRequests.add(null);
      return;
    }
    if (data['type'] == 'loyalty') {
      _rewardsRequests.add(null);
      return;
    }
    _tabRequests.add(_tabFor(data));
  }

  /// Android no muestra nada con la app en foreground — el banner lo
  /// dibuja flutter_local_notifications en este canal de alta importancia.
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'push_channel',
    'Notificaciones',
    description: 'Avisos y promociones del gimnasio',
    importance: Importance.high,
  );

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
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        /// Tap en el banner de foreground — misma navegación que el tap
        /// del sistema (onMessageOpenedApp).
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null) return;
          try {
            _route(jsonDecode(payload) as Map<String, dynamic>);
          } on FormatException {
            // Payload inválido — se ignora el tap.
          }
        },
      );
    }
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null || !Platform.isAndroid) return;
      _local.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _route(message.data);
    });
    final initial = await fcm.getInitialMessage();
    if (initial != null) {
      if (initial.data['type'] == 'support') {
        _initialSupport = true;
      } else if (initial.data['type'] == 'loyalty') {
        _initialRewards = true;
      } else {
        _initialTab = _tabFor(initial.data);
      }
    }
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
      /// Topic personal — respuestas de soporte llegan solo a este socio.
      if (member != null) 'member_${member.id}',
    };
    final prev = <String>{
      if (previous?.branchId != null) 'branch_${previous!.branchId}',
      if (previous != null && !previous.isActive) 'expired_members',
      if (previous != null) 'member_${previous.id}',
    };
    for (final topic in prev.difference(next)) {
      await fcm.unsubscribeFromTopic(topic);
    }
    for (final topic in next.difference(prev)) {
      await fcm.subscribeToTopic(topic);
    }
  }
}
