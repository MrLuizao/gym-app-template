import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/firebase/api_client.dart';

/// Evento de interacción con un anuncio de aliado.
/// Se reporta al backend: POST /api/ads/track incrementa
/// impressions/taps del doc /sponsorAds/{id} (métricas para cobro).
class AdMetricEvent {
  const AdMetricEvent({
    required this.adId,
    required this.type,
    required this.at,
  });

  final String adId;

  /// 'tap' (abrió el detalle) | 'coupon' (generó cupón) | 'impression'
  final String type;
  final DateTime at;
}

class AdMetricsNotifier extends Notifier<List<AdMetricEvent>> {
  @override
  List<AdMetricEvent> build() => const [];

  void track(String adId, String type) {
    final event = AdMetricEvent(adId: adId, type: type, at: DateTime.now());
    state = [...state, event];
    if (!AppConfig.firebaseActive) {
      debugPrint('[METRICS] ad=$adId event=$type (sin firebase)');
      return;
    }

    /// El backend solo incrementa impressions/taps — 'coupon' cuenta
    /// como tap (interacción) desde el punto de vista del aliado.
    final apiEvent = type == 'impression' ? 'impression' : 'tap';
    ApiClient.post('/api/ads/track', {
      'adId': adId,
      'event': apiEvent,
    }).catchError((Object e) {
      debugPrint('[METRICS] track falló: $e');
      return <String, dynamic>{};
    });
  }
}

final adMetricsProvider =
    NotifierProvider<AdMetricsNotifier, List<AdMetricEvent>>(
      AdMetricsNotifier.new,
    );
