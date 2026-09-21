import 'package:flutter/material.dart';

import 'brand.dart';

const capitalFitness = BrandConfig(
  id: 'capital_fitness',
  appName: 'CAPITAL FITNESS',
  tagline: 'Entrena sin límites',
  background: Color(0xFF050505),
  surface: Color(0xFF111411),
  cardBorder: Color(0xFF232823),
  accent: Color(0xFFF4E701),
  accentDark: Color(0xFF9E8E00),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF9AA39A),
);

const novaFit = BrandConfig(
  id: 'nova_fit',
  appName: 'NOVA FIT',
  tagline: 'Tu mejor versión',
  background: Color(0xFF0B1014),
  surface: Color(0xFF121A20),
  cardBorder: Color(0xFF22303A),
  accent: Color(0xFF22D3EE),
  accentDark: Color(0xFF0E7490),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF8CA3B5),
);

const availableBrands = <BrandConfig>[capitalFitness, novaFit];
