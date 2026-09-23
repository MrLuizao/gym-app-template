import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

/// Botón oficial de Google Sign-In (FedCM) — requerido en web: el SDK
/// de Google no permite sign-in programático, solo su botón renderizado.
Widget googleSignInWebButton() => gsi_web.renderButton();
