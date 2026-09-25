// part of 'homepage.dart';

// class _HomepageController {
//   List<_Product> get products => _HomepageMock.products;

//   List<_Product> get stockAlerts =>
//       products.where((product) => product.lowStock).toList();

//   int get stockValueCents => products.fold(
//     0,
//     (total, product) => total + product.quantity * product.priceCents,
//   );

//   int get incomingToday => _HomepageMock.todayMovements
//       .where((movement) => movement.quantity > 0)
//       .fold(0, (total, movement) => total + movement.quantity);

//   int get outgoingToday => _HomepageMock.todayMovements
//       .where((movement) => movement.quantity < 0)
//       .fold(0, (total, movement) => total - movement.quantity);
// }
