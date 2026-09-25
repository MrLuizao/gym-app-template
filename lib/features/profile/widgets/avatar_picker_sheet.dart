import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/member_avatar.dart';
import '../../../data/models/member.dart';

/// Selector de avatar del socio — guarda `users/{docId}.avatar` y el
/// stream del memberProvider lo refleja en vivo en toda la app.
class AvatarPickerSheet extends StatelessWidget {
  const AvatarPickerSheet({super.key, required this.member});

  final Member member;

  static Future<void> show(BuildContext context, Member member) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(member: member),
    );
  }

  Future<void> _pick(BuildContext context, String avatarId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(member.id)
          .update({'avatar': avatarId});
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar tu avatar')),
        );
      }
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: brand.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: brand.cardBorder,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Elige tu avatar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: brand.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu identidad en el gym — sin fotos, solo estilo.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: [
              for (final spec in memberAvatarCatalog)
                GestureDetector(
                  onTap: AppConfig.firebaseActive
                      ? () => _pick(context, spec.id)
                      : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MemberAvatar(
                        avatarId: spec.id,
                        initials: member.initials,
                        size: 64,
                      ),
                      if (spec.id == member.avatarId)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: brand.accent,
                              border: Border.all(
                                color: brand.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: brand.background,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
