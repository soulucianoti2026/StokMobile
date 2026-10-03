import 'package:flutter/foundation.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

class HomepageController extends ChangeNotifier {
  HomepageController() {
    productsRevision.addListener(notifyListeners);
  }

  static const minimumStock = 10;

  List<Product> get products => productsJson
      .map(Product.fromJson)
      .where((product) => product.isActive)
      .toList();
  int get totalProducts => products.length;
  double get stockValue => products.fold<double>(
    0,
    (total, product) => total + product.stock * product.price,
  );
  List<Product> get stockAlerts {
    final alerts = products
        .where((product) => product.stock < product.minimumStock)
        .toList();
    alerts.sort((a, b) => a.stock.compareTo(b.stock));
    return alerts;
  }

  @override
  void dispose() {
    productsRevision.removeListener(notifyListeners);
    super.dispose();
  }
}
