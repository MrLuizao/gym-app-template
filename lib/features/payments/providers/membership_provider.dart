import 'package:flutter_riverpod/flutter_riverpod.dart';

class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.level,
    required this.price,
    this.tag,
  });

  final String id;
  final String name;
  final String level;
  final double price;
  final String? tag;
}

const membershipPlans = <MembershipPlan>[
  MembershipPlan(
    id: 'classic',
    name: 'Plan Classic',
    level: 'CLASSIC',
    price: 199,
  ),
  MembershipPlan(
    id: 'plus',
    name: 'Plan Plus',
    level: 'PLUS',
    price: 299,
    tag: 'MÁS POPULAR',
  ),
  MembershipPlan(
    id: 'black',
    name: 'Plan Black',
    level: 'BLACK',
    price: 399,
    tag: 'TODO INCLUIDO',
  ),
];

class MembershipState {
  const MembershipState({
    required this.plan,
    required this.level,
    required this.status,
    this.expiresAt,
  });

  final String plan;
  final String level;
  final String status;
  final DateTime? expiresAt;

  bool get isActive => status == 'ACTIVE';
}

class MembershipNotifier extends Notifier<MembershipState> {
  @override
  MembershipState build() {
    final now = DateTime.now();
    return MembershipState(
      plan: 'Plan Black',
      level: 'BLACK',
      status: 'ACTIVE',
      expiresAt: DateTime(now.year, now.month, now.day + 45),
    );
  }

  void renew(MembershipPlan plan) {
    final now = DateTime.now();
    state = MembershipState(
      plan: plan.name,
      level: plan.level,
      status: 'ACTIVE',
      expiresAt: DateTime(now.year, now.month, now.day + 30),
    );
  }
}

final membershipProvider =
    NotifierProvider<MembershipNotifier, MembershipState>(
  MembershipNotifier.new,
);

class PaymentResult {
  const PaymentResult({
    required this.success,
    this.transactionId,
    this.message,
  });

  final bool success;
  final String? transactionId;
  final String? message;
}

class MockPaymentGateway {
  Future<PaymentResult> charge({
    required String cardNumber,
    required double amount,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    final digits = cardNumber.replaceAll(' ', '');
    if (digits.endsWith('0000')) {
      return const PaymentResult(
        success: false,
        message: 'Pago rechazado por el banco emisor',
      );
    }
    return PaymentResult(
      success: true,
      transactionId: 'TX-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

double planPrice(MembershipPlan plan) => plan.price;
