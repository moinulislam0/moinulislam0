// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:jwells/features/auth/model/shoutModel.dart';

// class VoiceMessageCard extends StatelessWidget {
//   final ShoutModel shout;
//   const VoiceMessageCard({super.key, required this.shout});

//   @override
//   Widget build(BuildContext context) {
//     var voiceMedia = shout.medias?.firstWhere(
//       (m) => m.type == "VOICE",
//       orElse: () => Medias(),
//     );

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: const BoxDecoration(color: Color(0xFF0F0F0F)),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundImage: NetworkImage(
//               shout.user?.avatar ?? "https://i.pravatar.cc/150",
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   shout.user?.name ?? "Anonymous User",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   shout.content ?? "Voice Message",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(color: Colors.grey[400], fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
//             child: Row(
//               children: [
//                 const Icon(Icons.play_arrow, color: Color(0xFF00D09C)),
//                 const SizedBox(width: 8),
//                 Text(
//                   voiceMedia?.duration ?? "0:00",
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
