import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/branding/brand.dart';

/// Visor simple de documentos markdown empaquetados como assets.
/// Soporta: # ## ### encabezados, **negritas**, listas con -, tablas |,
/// divisores --- y párrafos.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.title, required this.asset});

  final String title;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Scaffold(
      backgroundColor: brand.background,
      appBar: AppBar(
        backgroundColor: brand.background,
        title: Text(title),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(asset),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudo cargar el documento',
                style: TextStyle(color: brand.textSecondary),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            children: _renderMarkdown(context, snapshot.data!),
          );
        },
      ),
    );
  }

  List<Widget> _renderMarkdown(BuildContext context, String md) {
    final brand = context.brand;
    final widgets = <Widget>[];
    bool inTable = false;

    for (final rawLine in md.split('\n')) {
      final line = rawLine.trimRight();
      final trimmed = line.trim();

      final isTableLine = trimmed.startsWith('|') && trimmed.endsWith('|');
      if (!isTableLine && inTable) {
        widgets.add(const SizedBox(height: 10));
        inTable = false;
      }

      if (trimmed.isEmpty) continue;

      if (isTableLine) {
        // Filas separadoras (|---|---|) se omiten
        if (RegExp(r'^\|[\s\-|]+\|$').hasMatch(trimmed)) continue;
        final cells = trimmed
            .substring(1, trimmed.length - 1)
            .split('|')
            .map((c) => c.trim())
            .toList();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _rich(
              context,
              cells.join('  ·  '),
              TextStyle(
                fontSize: 13,
                height: 1.5,
                color: brand.textSecondary,
              ),
            ),
          ),
        );
        inTable = true;
        continue;
      }

      if (trimmed == '---') {
        widgets.add(
          Divider(height: 28, color: brand.cardBorder),
        );
        continue;
      }

      if (trimmed.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: _rich(
              context,
              trimmed.substring(4),
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
        continue;
      }
      if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 8),
            child: _rich(
              context,
              trimmed.substring(3),
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        );
        continue;
      }
      if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: _rich(
              context,
              trimmed.substring(2),
              const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: brand.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _rich(
                    context,
                    trimmed.substring(2),
                    TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: brand.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('*') && trimmed.endsWith('*') && trimmed.length > 2) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _rich(
              context,
              trimmed.substring(1, trimmed.length - 1),
              TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: brand.textSecondary,
              ),
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _rich(
            context,
            trimmed,
            TextStyle(
              fontSize: 13,
              height: 1.6,
              color: brand.textSecondary,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _rich(BuildContext context, String text, TextStyle base) {
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(
        TextSpan(
          text: parts[i],
          style: i.isOdd
              ? base.copyWith(color: Colors.white, fontWeight: FontWeight.w800)
              : null,
        ),
      );
    }
    return Text.rich(
      TextSpan(children: spans, style: base),
      style: base,
    );
  }
}
