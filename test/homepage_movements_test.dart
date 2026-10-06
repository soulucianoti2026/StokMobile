import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/homepage/controllers/homepage_controller.dart';
import 'package:stokmobile/productMovPage/controllers/productMovePage_controller.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

void main() {
  test('Home totals follow successful movements and exclude previous days', () {
    final products = productsJson
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    final history = List<Map<String, dynamic>>.from(productMovementsJson);
    final home = HomepageController();
    final controller = ProductMovController();
    addTearDown(() {
      home.dispose();
      controller.dispose();
      productsJson
        ..clear()
        ..addAll(products);
      productMovementsJson
        ..clear()
        ..addAll(history);
    });
    productMovementsJson
      ..clear()
      ..add({
        'type': 'entry',
        'quantity': 100,
        'date': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      });
    var notifications = 0;
    home.addListener(() => notifications++);
    expect(home.entriesToday, 0);
    controller.setOperation(MovementOperation.entry);
    controller.setQuantity('7');
    expect(controller.register(), isTrue);
    expect(home.entriesToday, 7);
    expect(notifications, 1);
    controller.setOperation(MovementOperation.exit);
    controller.setQuantity('3');
    expect(controller.register(), isTrue);
    expect(home.exitsToday, 3);
    expect(home.entriesToday, 7);
    controller.setQuantity('999999');
    expect(controller.register(), isFalse);
    expect(home.exitsToday, 3);
    expect(notifications, 2);
  });
}
