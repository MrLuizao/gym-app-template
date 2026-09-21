import 'dart:async';

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../data/repositories/gym_repositories.dart';

class QrToken {
  const QrToken({
    required this.payload,
    required this.memberId,
    required this.signature,
    required this.issuedAt,
    required this.ttl,
  });

  final String payload;
  final String memberId;
  final String signature;
  final DateTime issuedAt;
  final Duration ttl;

  DateTime get expiresAt => issuedAt.add(ttl);

  String get signaturePreview =>
      signature.length <= 12 ? signature : signature.substring(0, 12);

  double remainingRatio(DateTime now) {
    final total = ttl.inMilliseconds;
    if (total <= 0) return 0;
    final left = expiresAt.difference(now).inMilliseconds;
    return (left / total).clamp(0.0, 1.0);
  }

  int remainingSeconds(DateTime now) =>
      expiresAt.difference(now).inSeconds.clamp(0, ttl.inSeconds);
}

class QrTokenNotifier extends Notifier<QrToken> {
  Timer? _timer;

  @override
  QrToken build() {
    _timer?.cancel();
    ref.onDispose(() => _timer?.cancel());
    _scheduleRotation();
    return _generate();
  }

  QrToken _generate() {
    final memberId =
        ref.watch(memberProvider).value?.id ?? AppConfig.demoUserId;
    final issuedAt = DateTime.now();
    final signature = Hmac(sha256, utf8.encode(AppConfig.qrSigningKey))
        .convert(utf8.encode('$memberId|${issuedAt.millisecondsSinceEpoch}'))
        .toString();
    return QrToken(
      payload: jsonEncode({
        'v': 1,
        'uid': memberId,
        'ts': issuedAt.millisecondsSinceEpoch,
        'sig': signature,
      }),
      memberId: memberId,
      signature: signature,
      issuedAt: issuedAt,
      ttl: AppConfig.qrTokenTtl,
    );
  }

  void _scheduleRotation() {
    _timer = Timer(AppConfig.qrTokenTtl, () {
      state = _generate();
      _scheduleRotation();
    });
  }

  void refresh() {
    _timer?.cancel();
    state = _generate();
    _scheduleRotation();
  }
}

final qrTokenProvider = NotifierProvider<QrTokenNotifier, QrToken>(
  QrTokenNotifier.new,
);
