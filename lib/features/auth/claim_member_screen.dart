import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/firebase/api_client.dart';
import '../../core/firebase/auth_provider.dart';
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

class _ClaimMemberScreenState extends ConsumerState<ClaimMemberScreen> {
  final _number = TextEditingController(text: 'CF-');
  final _pin = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _number.selection = TextSelection.collapsed(offset: _number.text.length);
  }

  @override
  void dispose() {
    _number.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _ensureCursorAfterPrefix() {
    if (_number.selection.baseOffset < 3) {
      _number.selection = TextSelection.collapsed(offset: _number.text.length);
    }
  }

  Future<void> _claim() async {
    if (_saving) return;
    final rawNumber = _number.text.trim().toUpperCase();
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final pin = _pin.text.trim();

    if (digits.isEmpty || pin.length != 6) {
      setState(
        () => _error = 'Ingresa tu número de socio y el código de 6 dígitos',
      );
      return;
    }
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
      setState(() {
        _saving = false;
        _error = message;
      });
    } catch (_) {
      setState(() {
        _saving = false;
        _error = 'Sin conexión — revisa tu internet';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Scaffold(
      backgroundColor: brand.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          children: [
            Icon(Icons.badge_rounded, size: 40, color: brand.accent),
            const SizedBox(height: 16),
            Text(
              'Ingresa tu número de socio',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Recepción te envió un código de 6 dígitos a tu correo al '
              'registrarte. Si aún no eres socio, acude a tu sucursal.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _number,
              autocorrect: false,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [_MemberNumberFormatter()],
              onTap: _ensureCursorAfterPrefix,
              style: TextStyle(
                color: brand.accent,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
              decoration: _decoration(
                brand,
                hint: 'CF-00000',
                icon: Icons.tag_rounded,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _pin,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _claim(),
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: brand.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
              decoration: _decoration(
                brand,
                hint: 'Código de 6 dígitos',
                icon: Icons.pin_rounded,
              ).copyWith(
                counterText: '',
                /// El letterSpacing del estilo de entrada se propaga al
                /// hint (merge del decorator) — se resetea aquí.
                hintStyle: TextStyle(
                  color: brand.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: brand.occupancyHigh,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 28),
            if (_saving)
              const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
            else
              PrimaryButton(
                label: 'VINCULAR MI CUENTA',
                icon: Icons.link_rounded,
                onTap: _claim,
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.read(authControllerProvider).signOut(),
              child: Text(
                'Usar otra cuenta',
                style: TextStyle(color: brand.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
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
        borderSide: BorderSide(color: brand.accent),
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
