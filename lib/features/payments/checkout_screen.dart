import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
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
  final _cardCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  int _selectedPlan = 1;
  bool _processing = false;
  bool _success = false;
  String? _transactionId;
  String? _error;

  bool get _cardValid =>
      _cardCtrl.text.replaceAll(' ', '').length == 16;

  bool get _expiryValid {
    final parts = _expiryCtrl.text.split('/');
    if (parts.length != 2) return false;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    return DateTime(2000 + year, month + 1).isAfter(DateTime.now());
  }

  bool get _formValid =>
      _cardValid &&
      _holderCtrl.text.trim().length >= 3 &&
      _expiryValid &&
      _cvvCtrl.text.length >= 3;

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_processing || !_formValid) return;
    setState(() => _processing = true);
    final plan = membershipPlans[_selectedPlan];
    final result = await MockPaymentGateway().charge(
      cardNumber: _cardCtrl.text,
      amountBs: plan.priceBs,
    );
    if (!mounted) return;
    if (result.success) {
      ref.read(membershipProvider.notifier).renew(plan);
      setState(() {
        _success = true;
        _transactionId = result.transactionId;
      });
    } else {
      setState(() {
        _processing = false;
        _error = result.message ?? 'No se pudo procesar el pago';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final plan = membershipPlans[_selectedPlan];

    if (_processing) {
      return Scaffold(
        backgroundColor: brand.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 2.5),
              const SizedBox(height: 18),
              Text(
                'Procesando tu pago…',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: brand.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Conectando con el banco emisor',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: brand.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                    '¡Pago exitoso!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu membresía ${membership.plan} está activa '
                    'hasta ${_formatDate(membership.expiresAt)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: brand.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: brand.cardBorder),
                    ),
                    child: Text(
                      'Nº ${_transactionId ?? '—'}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: brand.textSecondary,
                      ),
                    ),
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
      body: ListView(
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
          Text('Elige tu plan',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (var i = 0; i < membershipPlans.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PlanCard(
                plan: membershipPlans[i],
                selected: i == _selectedPlan,
                onTap: () => setState(() => _selectedPlan = i),
              ),
            ),
          const SizedBox(height: 8),
          Text('Datos de la tarjeta',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CardField(
                  controller: _cardCtrl,
                  label: 'Número de tarjeta',
                  icon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  formatter: _CardNumberFormatter(),
                ),
                const SizedBox(height: 12),
                _CardField(
                  controller: _holderCtrl,
                  label: 'Titular de la tarjeta',
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CardField(
                        controller: _expiryCtrl,
                        label: 'Vence (MM/AA)',
                        keyboardType: TextInputType.number,
                        formatter: _ExpiryFormatter(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CardField(
                        controller: _cvvCtrl,
                        label: 'CVV',
                        obscure: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        digitsOnly: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                'Bs ${plan.priceBs.toStringAsFixed(0)}',
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
                    'Procesando tu pago…',
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
              label: 'PAGAR Bs ${plan.priceBs.toStringAsFixed(0)}',
              icon: Icons.lock_rounded,
              onTap: _formValid ? _pay : null,
            ),
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
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    this.onTap,
  });

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
                  ? Icon(Icons.check_rounded,
                      size: 15, color: brand.background)
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
                    text: 'Bs ${plan.priceBs.toStringAsFixed(0)}',
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

class _CardField extends StatelessWidget {
  const _CardField({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.formatter,
    this.obscure = false,
    this.maxLength,
    this.digitsOnly = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputFormatter? formatter;
  final int? maxLength;
  final bool digitsOnly;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: [
        if (formatter != null) formatter!,
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
      ],
      style: TextStyle(fontSize: 14, color: brand.textPrimary),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        labelStyle: TextStyle(color: brand.textSecondary, fontSize: 12),
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: brand.textSecondary)
            : null,
        filled: true,
        fillColor: brand.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brand.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: brand.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: brand.accent),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited =
        digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      if ((i + 1) % 4 == 0 && i != limited.length - 1) {
        buffer.write(' ');
      }
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited =
        digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = limited.length <= 2
        ? limited
        : '${limited.substring(0, 2)}/${limited.substring(2)}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
