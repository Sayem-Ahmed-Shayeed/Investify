// import 'package:flutter/material.dart';
// import 'package:investify/utils/sizes/size.dart';
//
// import '../../model/chat_model.dart';
//
// class ScamAlertCard extends StatelessWidget {
//   final ScamAlert alert;
//   final VoidCallback? onViewTips;
//
//   const ScamAlertCard({
//     super.key,
//     required this.alert,
//     this.onViewTips,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: RomRomSizes.medium),
//       padding: const EdgeInsets.all(RomRomSizes.containerPadding),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(RomRomSizes.roundedBoxCorner),
//         border: Border.all(
//           color: theme.colorScheme.outline.withValues(alpha: 0.2),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(RomRomSizes.roundedButtonCorner),
//             decoration: const BoxDecoration(
//               color: Colors.red,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.warning_rounded,
//               size: RomRomSizes.iconSmall,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(width: RomRomSizes.medium),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       alert.title,
//                       style: theme.textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(width: RomRomSizes.small),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: RomRomSizes.small,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(RomRomSizes.small),
//                       ),
//                       child: Text(
//                         alert.riskLevel,
//                         style: theme.textTheme.labelSmall?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: RomRomSizes.small),
//                 Text(
//                   alert.description,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
//                   ),
//                 ),
//                 const SizedBox(height: RomRomSizes.small),
//                 GestureDetector(
//                   onTap: onViewTips,
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'View Safety Tips',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: theme.colorScheme.primary,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(width: RomRomSizes.spaceBetweenItem),
//                       Icon(
//                         Icons.arrow_forward,
//                         size: RomRomSizes.iconSmall,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
