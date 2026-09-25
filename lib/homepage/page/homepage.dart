// import 'package:flutter/material.dart';

// part 'homepage_controller.dart';
// part 'homepage_widgets.dart';

// class Homepage extends StatelessWidget {
//   const Homepage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = _HomepageController();
//     return Scaffold(
//       body: SafeArea(
//         bottom: false,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 650),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Color(0xFFE5E7EB),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Olá, Usuário',
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   Text(
//                     'Painel de controle geral',
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   const SizedBox(height: 12),
//                   _SummaryGrid(controller: controller),
//                   const SizedBox(height: 24),
//                   _StockAlerts(controller: controller),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
