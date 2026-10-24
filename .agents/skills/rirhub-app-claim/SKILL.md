---
name: rirhub-app-claim
description: >-
  Use this skill when working on account claiming in the Flutter app
  (claim_member_screen.dart), member number formatting (CF- prefix),
  or the integration with POST /api/members/claim.
---

# Member Account Claim Flow (Flutter)

## Visión General
La app móvil **nunca da de alta** a un socio desde cero. La recepción del gimnasio lo registra en la consola B2B con número de socio (`member_number`) y correo de contacto, lo cual genera un PIN de un solo uso (`claim_pin`).
El socio descarga la app, inicia sesión con Google o Apple, y vincula su ficha en la pantalla de reclamo.

## Pantalla: `features/onboarding/claim_member_screen.dart`

### Reglas de Entrada de Datos
1. **Prefijo obligatorio `CF-`**:
   - Se utiliza el formateador `_MemberNumberFormatter`.
   - El usuario **no puede borrar** el prefijo `CF-`.
   - El teclado se abre directamente en modo numérico (`TextInputType.number`).
   - El número ingresado se normaliza a 5 dígitos rellenando con ceros si es necesario (ej: `CF-00042`).
2. **PIN de reclamo**:
   - Entrada de 6 dígitos numéricos.

### Llamada al API
- Se invoca vía `ApiClient`:
  ```dart
  final response = await ref.read(apiClientProvider).post(
    '/api/members/claim',
    data: {
      'member_number': memberNumber,
      'claim_pin': pin,
    },
  );
  ```
- **Respuestas del Backend**:
  - `200 OK`: Ficha vinculada exitosamente. Se invalida `currentMemberProvider` y navega al `MainShell`.
  - `400 / 401`: PIN incorrecto o número inexistente. (Nota: 3 fallos provocan lockout de 15 min en backend).
  - `409 Conflict`: La ficha ya fue reclamada por otra cuenta.

## Manejo de Estado
- Tras el reclamo exitoso, `auth_provider.dart` refresca el token o el documento en `users/{authUid}` para reflejar el estado activo.
