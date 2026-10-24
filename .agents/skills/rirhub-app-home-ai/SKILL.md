---
name: rirhub-app-home-ai
description: >-
  Use this skill when working on the Home dashboard card, WeeklySummarySection,
  weekly progress streak, AI Coach suggestions (/api/members/ai-coach), or 1-tap goal adjustment.
---

# Home AI Coach & Weekly Summary (Flutter)

## Componente Central: `WeeklySummarySection`
- Ubicado en: `lib/features/home/widgets/weekly_summary_card.dart`
- Combina en una única tarjeta moderna el resumen de asistencia y las recomendaciones predictivas del Coach de IA.

## Funcionalidades Clave

### 1. Progreso de la Semana y Racha
- Barra de avance visual comparando las visitas realizadas en la semana vs `member.weeklyGoal`.
- 7 pastillas o círculos correspondientes a los días Lunes a Domingo:
  - Rellenos si hubo visita registrada en `users/{id}/visits/{dateKey}`.
  - Indicador del bono de `+50 pts` de lealtad al completar la meta.

### 2. Sugerencias del Coach IA (`/api/members/ai-coach`)
- Consume el endpoint con el ID token del socio:
  ```dart
  GET /api/members/ai-coach
  ```
- **Información provista**:
  - `habitual_time`: Horario promedio habitual del socio.
  - `best_window_today`: La mejor ventana horaria para entrenar hoy con menor aforo estimado en su sede favorita.
  - `recommended_action`: Acción estratégica sugerida por el motor de retención / IA.

### 3. Ajuste Inteligente de Meta (1-Tap)
- Si la IA detecta que el socio está por perder su racha o que su ritmo amerita un ajuste, despliega un botón de acción rápida (ej: "Ajustar meta a 3 días").
- Al pulsar, actualiza `users/{id}.weekly_goal` sin salir de la tarjeta ni abrir pantallas intermedias.
