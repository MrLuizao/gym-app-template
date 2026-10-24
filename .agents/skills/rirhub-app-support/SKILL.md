---
name: rirhub-app-support
description: >-
  Use this skill when working on the member support chat screen (features/support),
  realtime message listeners, conversation lifecycle, or support push handling in Flutter.
---

# Support & Member-Staff Chat (Flutter)

## Flujo Operativo

1. **Creación Perezosa (Lazy Creation)**:
   - Al abrir la pantalla de soporte ("Ayuda y Soporte" desde el menú de Perfil), la conversación **no se crea inmediatamente**.
   - Solo se crea cuando el socio envía su primer mensaje:
     ```dart
     POST /api/support/conversations
     body: {'message': initialText, 'branchId': currentBranchId}
     ```
2. **Escucha en Tiempo Real**:
   - Subcolección `conversations/{conversationId}/messages` ordenada por `created_at asc`.
   - Se usa un `StreamProvider` de Firestore para renderizar la lista de burbujas en vivo.
3. **Envío de Mensajes Posteriores**:
   - Cada mensaje nuevo se envía a través de:
     ```dart
     POST /api/support/{conversationId}/messages
     body: {'text': messageText}
     ```
   - El backend renueva automáticamente el campo `expires_at` (+24h) y notifica al staff de la sede.
4. **Resolución y Expiración**:
   - Cuando el staff resuelve la conversación o expira por inactividad (>24h), el documento y sus mensajes son eliminados.
   - La UI de Flutter debe manejar graciosamente cuando la conversación activa ya no exista, volviendo al estado inicial ("¿En qué podemos ayudarte?").
5. **Notificación Push de Soporte**:
   - Cuando el staff responde, se envía una notificación push con `data.type = 'support'` dirigida al topic `member_{memberId}`.
   - Al tocar la notificación, la app abre directamente la pantalla de chat.
