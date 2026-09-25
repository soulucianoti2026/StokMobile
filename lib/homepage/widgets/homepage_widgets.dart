// part of 'homepage.dart';

// class _SummaryGrid extends StatelessWidget {
//   const _SummaryGrid({required this.controller});

//   final _HomepageController controller;

//   @override
//   Widget build(BuildContext context) {
//     final summaries = [
//       ('Produtos cadastrados', '${controller.products.length}'),
//       (
//         'Valor em estoque',
//         'R\$ ${(controller.stockValueCents / 100).toStringAsFixed(2).replaceAll('.', ',')}',
//       ),
//       ('Entradas hoje', '${controller.incomingToday}'),
//       ('Saídas hoje', '${controller.outgoingToday}'),
//     ];

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final columns = constraints.maxWidth < 400 ? 1 : 2;
//         final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
//         return Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: [
//             for (final summary in summaries)
//               SizedBox(
//                 width: width,
//                 child: Card(
//                   margin: EdgeInsets.zero,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(summary.$1),
//                         const SizedBox(height: 8),
//                         Text(
//                           summary.$2,
//                           style: Theme.of(context).textTheme.titleLarge,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _StockAlerts extends StatelessWidget {
//   const _StockAlerts({required this.controller});

//   final _HomepageController controller;

//   @override
//   Widget build(BuildContext context) {
//     final alerts = controller.stockAlerts;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Alertas de estoque',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 12),
//         if (alerts.isEmpty)
//           const Text('Nenhum produto abaixo do estoque mínimo.'),
//         for (final product in alerts)
//           Card(
//             child: ListTile(
//               leading: Icon(
//                 product.critical
//                     ? Icons.error_outline
//                     : Icons.warning_amber_rounded,
//                 color: product.critical
//                     ? Theme.of(context).colorScheme.error
//                     : null,
//               ),
//               title: Text(product.name),
//               subtitle: Text(
//                 '${product.id}\nEstoque: ${product.quantity} • Mínimo: ${product.minimum}',
//               ),
//               isThreeLine: true,
//             ),
//           ),
//       ],
//     );
//   }
// }
