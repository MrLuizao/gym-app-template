import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/app_card.dart';
import 'providers/notification_prefs_provider.dart';

/// Ajustes de la app — preferencias que no necesitan estar a la vista.
/// Accesible desde Perfil → "Ajustes de la app".
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SwitchRow(
                  icon: Icons.notifications_active_rounded,
                  label: 'Avisos del gimnasio',
                  subtitle: 'Clases, aforo y tu membresía',
                  warning:
                      'Si los apagas podrías perderte avisos de tus clases, '
                      'el aforo en vivo y el vencimiento de tu membresía.',
                  provider: gymNotifsEnabledProvider,
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: context.brand.cardBorder,
                ),
                _SwitchRow(
                  icon: Icons.campaign_rounded,
                  label: 'Promos de aliados',
                  subtitle: 'Ofertas de marcas aliadas del gym',
                  warning:
                      'Si los apagas dejarás de recibir descuentos y ofertas '
                      'exclusivas de los negocios aliados de tu gym.',
                  provider: sponsorPromosOptInProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends ConsumerWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.warning,
    required this.provider,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  /// Texto del modal que aparece al APAGAR el switch — disuade sin
  /// prohibir (el usuario confirma o cancela).
  final String warning;
  final NotifierProvider<PrefToggleNotifier, bool> provider;

  Future<void> _onChanged(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    if (value) {
      ref.read(provider.notifier).setEnabled(true);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Apagar "$label"?'),
        content: Text(warning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mantener activos'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(provider.notifier).setEnabled(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final enabled = ref.watch(provider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: brand.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Icon(icon, size: 16, color: brand.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: brand.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: brand.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeTrackColor: brand.accent,
            onChanged: (value) => _onChanged(context, ref, value),
          ),
        ],
      ),
    );
  }
}
