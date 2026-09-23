import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/firebase/auth_provider.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/branch.dart';
import '../home/providers/branch_providers.dart';

/// Primer login social: el usuario existe en Auth pero no en /users.
/// Aquí confirma su nombre y elige su sede — recepción le asigna
/// número de socio y plan cuando lo active en el B2B.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  late final TextEditingController _name;
  String? _branchId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    _name = TextEditingController(
      text: user?.displayName ?? user?.email?.split('@').first ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).value;
    if (user == null || _saving) return;
    if (_name.text.trim().length < 3 || _branchId == null) {
      setState(() => _error = 'Escribe tu nombre y elige tu sede');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      /// Solo campos de perfil — las reglas bloquean membresía/QR.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _name.text.trim(),
        'email': user.email,
        'photo_url': user.photoURL,
        'branch_id': _branchId,
        'created_at': FieldValue.serverTimestamp(),
      });

      /// memberDocExistsProvider emite true y el gate navega solo.
    } on FirebaseException catch (e) {
      setState(() {
        _saving = false;
        _error = 'No se pudo guardar (${e.code})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final branches = ref.watch(branchesProvider).value ?? <Branch>[];
    return Scaffold(
      backgroundColor: brand.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          children: [
            Icon(Icons.waving_hand_rounded, size: 40, color: brand.accent),
            const SizedBox(height: 16),
            Text(
              '¡Bienvenido!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Completa tu registro para que recepción '
              'te asigne tu número de socio',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: brand.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                labelStyle: TextStyle(color: brand.textSecondary),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: brand.textSecondary,
                  size: 20,
                ),
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
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _branchId,
              dropdownColor: brand.surface,
              style: TextStyle(color: brand.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Tu sede',
                labelStyle: TextStyle(color: brand.textSecondary),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: brand.textSecondary,
                  size: 20,
                ),
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
              ),
              items: [
                for (final branch in branches)
                  DropdownMenuItem(value: branch.id, child: Text(branch.name)),
              ],
              onChanged: (value) => setState(() => _branchId = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: brand.occupancyHigh, fontSize: 13),
              ),
            ],
            const SizedBox(height: 28),
            if (_saving)
              const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
            else
              PrimaryButton(
                label: 'CONTINUAR',
                icon: Icons.arrow_forward_rounded,
                onTap: _save,
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
}
