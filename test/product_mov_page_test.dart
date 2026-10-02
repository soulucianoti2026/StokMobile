import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/productMovPage/product_mov_page.dart';
import 'package:stokmobile/productMovPage/controllers/productMovePage_controller.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

void main() {
  test('Rejects invalid exits and updates stock for valid movements', () {
    final source = [
      <String, dynamic>{'name': 'Produto', 'stock': 1},
    ];
    final controller = ProductMovController(source: source);
    addTearDown(controller.dispose);
    expect(controller.register(), isFalse);
    expect(source.first['stock'], 1);
    controller.setOperation(MovementOperation.entry);
    expect(controller.register(), isTrue);
    expect(source.first['stock'], 6);
    expect(controller.register(), isFalse);
    controller.setQuantity('6');
    controller.setOperation(MovementOperation.exit);
    expect(controller.register(), isTrue);
    expect(source.first['stock'], 0);
    for (final invalid in ['', '0', '-1', '1.5', 'invalid']) {
      controller.setQuantity(invalid);
      expect(controller.register(), isFalse);
    }
  });

  test('Handles empty data and duplicate product codes', () {
    final empty = ProductMovController(source: []);
    expect(empty.register(), isFalse);
    empty.dispose();
    final source = [
      <String, dynamic>{'code': 'same', 'stock': 10},
      <String, dynamic>{'code': 'same', 'stock': 20},
    ];
    final controller = ProductMovController(source: source);
    controller.selectProduct(1);
    expect(controller.register(), isTrue);
    expect(source[0]['stock'], 10);
    expect(source[1]['stock'], 15);
    controller.dispose();
  });

  testWidgets('Selects mock products, validates and registers a movement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final original = productsJson
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    addTearDown(() {
      productsJson
        ..clear()
        ..addAll(original);
    });
    await tester.pumpWidget(const MaterialApp(home: ProductMovPage()));
    expect(find.text('Teclado Mecânico RGB'), findsOneWidget);
    expect(
      find.text('Estoque insuficiente para efetuar esta saída'),
      findsOneWidget,
    );
    await tester.tap(find.text('Registrar Movimentação'));
    await tester.pump();
    expect(productsJson.first['stock'], 1);
    await tester.tap(find.text('Teclado Mecânico RGB'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'COD-003');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detergente Líquido 5L'));
    await tester.pumpAndSettle();
    expect(find.text('Estoque Atual Disponível: 15 un'), findsOneWidget);
    expect(
      find.text('Estoque insuficiente para efetuar esta saída'),
      findsNothing,
    );
    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('Registrar Movimentação'));
    await tester.pumpAndSettle();
    expect(productsJson[2]['stock'], 13);
    expect(find.text('Movimentação registrada com sucesso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fits a narrow screen with enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const ProductMovPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Registrar Movimentação'));
    expect(tester.takeException(), isNull);
  });
}
