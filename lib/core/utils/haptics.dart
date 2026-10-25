import 'package:flutter/services.dart';

/// Utilidad centralizada de respuestas hápticas para micro-interacciones.
/// Safe en web/plataformas sin motor háptico (no lanza excepción).
class AppHaptics {
  const AppHaptics._();

  /// Toque ligero — botones, tarjetas, chips, cambio de slide.
  static void light() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Cambio de selección — barra inferior de navegación, filtros, dígitos PIN.
  static void selection() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Impacto medio — confirmar reserva, abrir pase QR, ajustar meta, logro.
  static void medium() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Impacto fuerte — error de PIN, acción crítica o celebración de racha.
  static void heavy() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
