---
name: rirhub-app-ads-allies
description: >-
  Use this skill when working on the Allies directory (features/allies),
  Home carousel sponsor ads, impression/tap tracking (/api/ads/track), or placement rules.
---

# Sponsor Ads & Allies Directory (Flutter)

## Tipos de Colocación (Placements)
- `carousel`: Espacio premium (máximo 5 spots concurrentes). Aparece en:
  1. Carrusel superior del Home.
  2. Pestaña de Promociones (`promos`).
  3. Los primeros 5 puestos fijados del Directorio de Aliados.
- `list`: Aparece en el Directorio de Aliados (`allies`) en orden aleatorio después de los 5 de carrusel.

## Métricas (/api/ads/track)
- Al mostrarse: evento `impression`.
- Al pulsar: evento `tap`.
- Deduplicación diaria server-side por socio.
