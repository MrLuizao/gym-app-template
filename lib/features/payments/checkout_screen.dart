import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/branding/brand.dart';
import '../../core/config/app_config.dart';
import '../../core/firebase/api_client.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/glass_icon_button.dart';
import '../../core/widgets/primary_button.dart';
import 'providers/membership_provider.dart';

class MembershipCheckoutScreen extends ConsumerStatefulWidget {
  const MembershipCheckoutScreen({super.key});

  static const routeName = '/membership/checkout';

  @override
  ConsumerState<MembershipCheckoutScreen> createState() =>
      _MembershipCheckoutScreenState();
}

class _MembershipCheckoutScreenState
    extends ConsumerState<MembershipCheckoutScreen> {
  int _selectedPlan = 0;
  bool _processing = false;
  bool _success = false;
  String? _error;

  /// Stripe Payment Sheet: crea el PaymentIntent en el backend
  /// (/api/payments/intent) y lo confirma con el sheet nativo.
  /// La membresía se activa por webhook — el stream de users/{uid}
  /// la refleja en vivo unos segundos después del cobro.
  Future<void> _pay(MembershipPlan plan) async {
    if (_processing) return;
    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      final merchantName = context.brand.appName;
      final intent = await ApiClient.post('/api/payments/intent', {
        'planId': plan.id,
      });
      final clientSecret = intent['clientSecret'] as String?;
      if (clientSecret == null) {
        throw Exception('El servidor no devolvió clientSecret');
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantName,
          style: ThemeMode.dark,
        ),
      );
      if (!mounted) return;
      setState(() => _processing = false);
      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;
      setState(() => _success = true);
    } on StripeException catch (e) {
      if (!mounted) return;
      if (e.error.code != FailureCode.Canceled) {
        setState(() {
          _processing = false;
          _error = e.error.localizedMessage ?? 'Pago rechazado';
        });
      } else {
        setState(() => _processing = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = e is ApiException
            ? (e.serverMessage ?? 'No se pudo iniciar el pago')
            : 'No se pudo iniciar el pago';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final plansAsync = ref.watch(plansProvider);
    final plans = plansAsync.value ??
        (plansAsync.hasError ? fallbackPlans : const <MembershipPlan>[]);
    final plan = plans.isEmpty
        ? null
        : plans[_selectedPlan.clamp(0, plans.length - 1)];

    if (_success) {
      final membership = ref.watch(membershipProvider);
      return Scaffold(
        backgroundColor: brand.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          brand.accent.withValues(alpha: 0.3),
                          brand.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 72,
                      color: brand.accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¡Pago recibido!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu membresía ${planNameFor(membership.planId)} '
                    'se activa en unos segundos.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'VOLVER AL INICIO',
                    icon: Icons.check_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: brand.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Row(
            children: [
              GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              Text(
                'Renovar membresía',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: brand.textPrimary,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 20),
          Text('Elige tu plan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            )
          else
            for (var i = 0; i < plans.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlanCard(
                  plan: plans[i],
                  selected: i == _selectedPlan,
                  onTap: () => setState(() => _selectedPlan = i),
                ),
              ),
          const SizedBox(height: 8),
          if (kIsWeb || AppConfig.stripePublishableKey.isEmpty)
            AppCard(
              child: Text(
                kIsWeb
                    ? 'Los pagos con tarjeta solo están disponibles en la '
                        'app móvil.'
                    : 'Pagos con tarjeta aún no configurados '
                        '(falta STRIPE_PUBLISHABLE_KEY).',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: brand.textSecondary,
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: brand.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${plan?.price.toStringAsFixed(0) ?? '—'}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: brand.textPrimary,
                  ),
                ),
                Text(
                  ' /mes',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: brand.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_processing)
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Abriendo Stripe…',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: brand.textPrimary,
                      ),
                    ),
                  ],
                ),
              )
            else
              PrimaryButton(
                label: 'PAGAR \$${plan?.price.toStringAsFixed(0) ?? '—'}',
                icon: Icons.lock_rounded,
                onTap: plan == null ? null : () => _pay(plan),
              ),
            const SizedBox(height: 10),
            Text(
              'Pago seguro procesado por Stripe',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: brand.textSecondary,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: brand.occupancyHigh,
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.selected, this.onTap});

  final MembershipPlan plan;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? brand.accent.withValues(alpha: 0.08)
              : brand.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? brand.accent : brand.cardBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? brand.accent : Colors.transparent,
                border: Border.all(
                  color: selected ? brand.accent : brand.cardBorder,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, size: 15, color: brand.background)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: brand.textPrimary,
                    ),
                  ),
                  if (plan.tag != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      plan.tag!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: brand.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '\$${plan.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: brand.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: ' /mes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: brand.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
