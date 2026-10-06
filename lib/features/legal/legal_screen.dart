import 'package:flutter/material.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/app_card.dart';
import 'legal_document_screen.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  static const _docs = <({String title, String subtitle, String asset})>[
    (
      title: 'Aviso de privacidad',
      subtitle: 'Cómo el gimnasio trata tus datos personales',
      asset: 'assets/legal/aviso-privacidad-gimnasio.md',
    ),
    (
      title: 'Términos y condiciones',
      subtitle: 'Reglas de uso de la app, pagos y recompensas',
      asset: 'assets/legal/terminos.md',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Scaffold(
      backgroundColor: brand.background,
      appBar: AppBar(
        backgroundColor: brand.background,
        title: const Text('Legal'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _docs.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, indent: 56, color: brand.cardBorder),
                  _DocRow(doc: _docs[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Documentos en revisión legal — pueden sufrir ajustes.',
            style: TextStyle(
              fontSize: 11,
              color: brand.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.doc});

  final ({String title, String subtitle, String asset}) doc;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LegalDocumentScreen(title: doc.title, asset: doc.asset),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.description_outlined, color: brand.accent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc.subtitle,
                    style: TextStyle(fontSize: 12, color: brand.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: brand.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
