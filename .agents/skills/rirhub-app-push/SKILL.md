---
name: rirhub-app-push
description: >-
  Use this skill when working on push notifications (push_notification_service.dart),
  FCM topic subscriptions (all_members, branch_{id}), foreground notifications, or target tab navigation.
---

# Push Notifications FCM (Flutter)

## Servicio Central: `push_notification_service.dart`
- Suscripción a topics: `all_members` y `branch_{id}` de su sede.
- Foreground en Android vía `flutter_local_notifications` (canal `push_channel` "Notificaciones").
- En iOS vía `setForegroundNotificationPresentationOptions`.

## Navegación por Tap
- El payload incluye `data['target']` que mapea directo a la pestaña del Shell:
  - `home` -> Tab 0
  - `explore` -> Tab 1
  - `allies` -> Tab 2
  - `promos` -> Tab 3
  - `rewards` -> Tab 4
- Mapeo por `kind` si target es `auto`:
  - `SPONSOR` -> Tab 2 (Aliados)
  - `BRAND` -> Tab 3 (Promos)
