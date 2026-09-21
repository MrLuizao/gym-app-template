import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Evento de interacción con un anuncio de aliado.
/// TODO(Firebase): persistir en `/adEvents` o POST /ads/{id}/track.
class AdMetricEvent {
  const AdMetricEvent({
    required this.adId,
    required this.type,
    required this.at,
  });

  final String adId;

  /// 'tap' (abrió el detalle) | 'coupon' (generó cupón)
  final String type;
  final DateTime at;
}

class AdMetricsNotifier extends Notifier<List<AdMetricEvent>> {
  @override
  List<AdMetricEvent> build() => const [];

  void track(String adId, String type) {
    final event = AdMetricEvent(adId: adId, type: type, at: DateTime.now());
    state = [...state, event];
    debugPrint('[METRICS] ad=$adId event=$type at=${event.at.toIso8601String()}');
  }
}

final adMetricsProvider =
    NotifierProvider<AdMetricsNotifier, List<AdMetricEvent>>(
  AdMetricsNotifier.new,
);
