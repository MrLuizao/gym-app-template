import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preferencia de notificaciones conmutables desde el Perfil.
/// TODO(Firebase): persistir en `members/{id}/prefs`.
abstract class PrefToggleNotifier extends Notifier<bool> {
  void setEnabled(bool value) => state = value;
}

/// Avisos operativos del gimnasio (clases, aforo, membresía).
class GymNotifsEnabledNotifier extends PrefToggleNotifier {
  @override
  bool build() => true;
}

final gymNotifsEnabledProvider =
    NotifierProvider<GymNotifsEnabledNotifier, bool>(
      GymNotifsEnabledNotifier.new,
    );

/// Opt-in requerido por las guías de las stores para recibir
/// notificaciones de marketing de terceros ("Promos de aliados").
/// TODO(Firebase): suscribir al topic FCM `sponsor_promos` cuando esté activo.
class SponsorPromosOptInNotifier extends PrefToggleNotifier {
  @override
  bool build() => true;
}

final sponsorPromosOptInProvider =
    NotifierProvider<SponsorPromosOptInNotifier, bool>(
      SponsorPromosOptInNotifier.new,
    );
