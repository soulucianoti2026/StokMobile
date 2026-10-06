import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/productHistory/controllers/controller.dart';
import 'package:stokmobile/productHistory/page/productHistory.dart';
import 'package:stokmobile/productMovPage/controllers/productMovePage_controller.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

void main() {
  testWidgets('Open history updates after entries and exits', (tester) async {
    final products = productsJson
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    final history = List<Map<String, dynamic>>.from(productMovementsJson);
    final movement = ProductMovController();
    addTearDown(() {
      movement.dispose();
      productsJson
        ..clear()
        ..addAll(products);
      productMovementsJson
        ..clear()
        ..addAll(history);
    });
    productMovementsJson.clear();
    await tester.pumpWidget(const MaterialApp(home: ProductHistoryPage()));
    expect(find.text('Nenhuma movimentação registrada'), findsOneWidget);
    movement.setOperation(MovementOperation.entry);
    movement.setQuantity('7');
    expect(movement.register(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('+7 un'), findsOneWidget);
    movement.setOperation(MovementOperation.exit);
    movement.setQuantity('3');
    expect(movement.register(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('-3 un'), findsOneWidget);
    expect(find.text('+7 un'), findsOneWidget);
    await tester.tap(find.text('Tipo: Todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tipo: Saída').last);
    await tester.pumpAndSettle();
    expect(find.text('+7 un'), findsNothing);
    expect(find.text('-3 un'), findsOneWidget);
    movement.setQuantity('2');
    expect(movement.register(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('-2 un'), findsOneWidget);
    expect(find.text('+7 un'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Filters by product and type and orders newest first', () {
    final controller = ProductHistoryController();
    addTearDown(controller.dispose);
    expect(controller.movements.length, 4);
    expect(controller.movements.first.productCode, 'COD-001');
    controller.filterType(HistoryMovementType.exit);
    expect(controller.movements.length, 2);
    expect(
      controller.movements.first.destinationLabel,
      'Tecnologia da Informação • CC-001',
    );
    controller.filterProduct('COD-002');
    expect(controller.movements, isEmpty);
    controller.filterType(null);
    expect(controller.movements.single.quantityLabel, '+10 un');
    controller.filterProduct(null);
    expect(controller.movements.length, 4);
  });

  test('Formats dates across month boundaries and handles empty history', () {
    final controller = ProductHistoryController(
      source: [],
      now: () => DateTime(2026, 10, 1, 12),
    );
    addTearDown(controller.dispose);
    expect(controller.dateLabel(DateTime(2026, 10, 1, 9, 5)), 'Hoje, 09:05');
    expect(controller.dateLabel(DateTime(2026, 9, 30, 16, 45)), 'Ontem, 16:45');
    expect(
      controller.dateLabel(DateTime(2025, 9, 30, 10)),
      '30/09/2025, 10:00',
    );
    expect(controller.emptyMessage, 'Nenhuma movimentação registrada');
  });

  testWidgets('Shows mock history and combines dropdown filters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ProductHistoryPage()));
    await tester.pumpAndSettle();
    expect(find.text('Teclado Mecânico RGB'), findsOneWidget);
    expect(
      find.text('Destino: Tecnologia da Informação • CC-001'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tipo: Todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tipo: Saída').last);
    await tester.pumpAndSettle();
    expect(find.text('Papel A4 Chamex 75g').hitTestable(), findsNothing);
    await tester.tap(find.text('Filtrar Produto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Papel A4 Chamex 75g').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Nenhuma movimentação para os filtros selecionados'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fits small screens and enlarged text', (tester) async {
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
        home: const ProductHistoryPage(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
