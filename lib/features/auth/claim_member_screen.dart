import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/firebase/api_client.dart';
import '../../core/firebase/auth_provider.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/primary_button.dart';

/// Primer login social: el socio ya fue dado de alta en recepción y
/// tiene su número CF-##### + un PIN de 6 dígitos que le llegó por
/// correo (contact_email). Aquí lo reclama → POST /api/members/claim
/// vincula el doc con auth_uid y consume el PIN (single-use).
class ClaimMemberScreen extends ConsumerStatefulWidget {
  const ClaimMemberScreen({super.key});

  @override
  ConsumerState<ClaimMemberScreen> createState() => _ClaimMemberScreenState();
}

class _ClaimMemberScreenState extends ConsumerState<ClaimMemberScreen>
    with SingleTickerProviderStateMixin {
  final _number = TextEditingController(text: 'CF-');
  final _pin = TextEditingController();
  final _pinFocus = FocusNode();
  bool _saving = false;
  String? _error;
  int _lastPinLen = 0;

  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    _number.selection = TextSelection.collapsed(offset: _number.text.length);
    _pin.addListener(_onPinChanged);
    _pinFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _onPinChanged() {
    final len = _pin.text.length;
    if (len != _lastPinLen) {
      AppHaptics.selection();
      _lastPinLen = len;
      if (_error != null) _error = null;
      setState(() {});
      if (len == 6) {
        final digits = _number.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isNotEmpty) {
          _claim();
        }
      }
    }
  }

  @override
  void dispose() {
    _pin.removeListener(_onPinChanged);
    _number.dispose();
    _pin.dispose();
    _pinFocus.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _ensureCursorAfterPrefix() {
    if (_number.selection.baseOffset < 3) {
      _number.selection = TextSelection.collapsed(offset: _number.text.length);
    }
  }

  void _triggerError(String message) {
    AppHaptics.heavy();
    _shakeController.forward(from: 0);
    setState(() {
      _saving = false;
      _error = message;
    });
  }

  Future<void> _claim() async {
    if (_saving) return;
    final rawNumber = _number.text.trim().toUpperCase();
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final pin = _pin.text.trim();

    if (digits.isEmpty || pin.length != 6) {
      _triggerError('Ingresa tu número de socio y el código de 6 dígitos');
      return;
    }
    AppHaptics.medium();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final paddedDigits = digits.padLeft(5, '0');
      final memberNumber = 'CF-$paddedDigits';

      await ApiClient.post('/api/members/claim', {
        'memberNumber': memberNumber,
        'pin': pin,
      });

      AppHaptics.heavy();
      /// Al escribirse auth_uid, memberDocExistsProvider emite true
      /// y el AuthGate navega solo al shell.
    } on ApiException catch (e) {
      String message = 'No se pudo vincular tu cuenta';
      try {
        final decoded = jsonDecode(e.body);
        if (decoded is Map && decoded['statusMessage'] is String) {
          message = decoded['statusMessage'] as String;
        }
      } catch (_) {}
      _triggerError(message);
    } catch (_) {
      _triggerError('Sin conexión — revisa tu internet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final pinText = _pin.text;
    final pinFocused = _pinFocus.hasFocus;

    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    brand.accent.withValues(alpha: 0.25),
                    brand.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: brand.surface,
                      border: Border.all(
                        color: brand.accent.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: brand.accent.withValues(alpha: 0.22),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.badge_rounded,
                      size: 32,
                      color: brand.accent,
                    ),
                  ),
                ).animate().scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1, 1),
                  duration: 380.ms,
                  curve: Curves.easeOutBack,
                ),
                const SizedBox(height: 20),
                Text(
                  'Activa tu pase digital',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa tu número de socio y el PIN de 6 dígitos que '
                  'recibiste en tu correo al darte de alta en recepción.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                Text(
                  'NÚMERO DE SOCIO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: brand.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _number,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [_MemberNumberFormatter()],
                  onTap: _ensureCursorAfterPrefix,
                  onSubmitted: (_) => _pinFocus.requestFocus(),
                  style: TextStyle(
                    color: brand.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                  decoration: _decoration(
                    brand,
                    hint: 'CF-00000',
                    icon: Icons.tag_rounded,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'CÓDIGO PIN DE 6 DÍGITOS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: brand.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                // Cajas individuales de 6 dígitos con shake en error
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final dx =
                        math.sin(_shakeController.value * math.pi * 4) *
                        10 *
                        (1 - _shakeController.value);
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.light();
                      _pinFocus.requestFocus();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // TextField invisible pero funcional para teclado y pegado
                        Opacity(
                          opacity: 0,
                          child: SizedBox(
                            height: 58,
                            child: TextField(
                              controller: _pin,
                              focusNode: _pinFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _claim(),
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final hasChar = index < pinText.length;
                            final isCurrent =
                                pinFocused &&
                                (index == pinText.length ||
                                    (pinText.length == 6 && index == 5));
                            final hasError = _error != null;

                            final borderColor = hasError
                                ? brand.occupancyHigh
                                : isCurrent
                                ? brand.accent
                                : hasChar
                                ? brand.accent.withValues(alpha: 0.55)
                                : brand.cardBorder;

                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOutCubic,
                                height: 58,
                                margin: EdgeInsets.only(
                                  left: index == 0 ? 0 : 4,
                                  right: index == 5 ? 0 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: hasChar
                                      ? brand.accent.withValues(alpha: 0.1)
                                      : brand.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: borderColor,
                                    width: isCurrent || hasChar ? 1.6 : 1.0,
                                  ),
                                  boxShadow: isCurrent
                                      ? [
                                          BoxShadow(
                                            color: brand.accent.withValues(
                                              alpha: 0.28,
                                            ),
                                            blurRadius: 14,
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: AnimatedScale(
                                  scale: hasChar ? 1.0 : 0.85,
                                  duration: const Duration(milliseconds: 160),
                                  curve: Curves.easeOutBack,
                                  child: Text(
                                    hasChar ? pinText[index] : '•',
                                    style: TextStyle(
                                      fontSize: hasChar ? 22 : 16,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      color: hasChar
                                          ? brand.textPrimary
                                          : brand.textSecondary.withValues(
                                              alpha: 0.35,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: brand.occupancyHigh.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: brand.occupancyHigh.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: brand.occupancyHigh,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: brand.occupancyHigh,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (_saving)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else
                  PrimaryButton(
                    label: 'VINCULAR MI CUENTA',
                    icon: Icons.link_rounded,
                    onTap: _claim,
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    AppHaptics.light();
                    ref.read(authControllerProvider).signOut();
                  },
                  child: Text(
                    'Usar otra cuenta',
                    style: TextStyle(color: brand.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(
    BrandConfig brand, {
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: brand.textSecondary, fontFamily: 'monospace'),
      prefixIcon: Icon(icon, color: brand.textSecondary, size: 20),
      filled: true,
      fillColor: brand.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: brand.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: brand.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: brand.accent, width: 1.5),
      ),
    );
  }
}

/// Formateador que asegura que el prefijo 'CF-' siempre esté presente
/// y no pueda ser borrado, permitiendo al usuario ingresar únicamente los dígitos.
class _MemberNumberFormatter extends TextInputFormatter {
  static const prefix = 'CF-';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.startsWith(prefix)) {
      final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      final capped = digits.length > 5 ? digits.substring(0, 5) : digits;
      final newText = '$prefix$capped';
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    final afterPrefix = newValue.text.substring(prefix.length);
    final digits = afterPrefix.replaceAll(RegExp(r'[^0-9]'), '');
    final capped = digits.length > 5 ? digits.substring(0, 5) : digits;
    final newText = '$prefix$capped';

    var selectionIndex = newValue.selection.end;
    if (selectionIndex < prefix.length) {
      selectionIndex = prefix.length;
    } else if (selectionIndex > newText.length) {
      selectionIndex = newText.length;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
