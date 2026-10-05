import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../data/repositories/gym_repositories.dart';

/// Estado de soporte del socio: mensajes sin leer + id de la conversación
/// abierta (null si no hay). Stream en vivo — el badge se enciende solo
/// cuando staff responde.
typedef SupportState = ({int unread, String? conversationId});

final supportStateProvider = StreamProvider<SupportState>((ref) {
  final member = ref.watch(memberProvider).value;
  if (member == null || !AppConfig.firebaseActive) {
    return Stream.value((unread: 0, conversationId: null));
  }
  return FirebaseFirestore.instance
      .collection('conversations')
      .where('member_id', isEqualTo: member.id)
      .snapshots()
      .map((snap) {
        String? convId;
        var unread = 0;
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['status'] != 'open') continue;
          convId ??= doc.id;
          unread += (data['unread_member'] as num?)?.toInt() ?? 0;
        }
        return (unread: unread, conversationId: convId);
      });
});
