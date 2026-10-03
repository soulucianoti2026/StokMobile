import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/NewProductPage/Page/new_product_page.dart';
import 'package:stokmobile/NewProductPage/controllers/new_product_controller.dart';
import 'package:stokmobile/shared/Widget/button_new_product.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/homepage/controllers/homepage_controller.dart';

void main() {
  late List<Map<String, dynamic>> original;
  setUp(() {
    original = productsJson.map((p) => Map<String, dynamic>.from(p)).toList();
  });
  tearDown(() {
    productsJson
      ..clear()
      ..addAll(original);
  });

  test('Saves real barcodes, product names, currency and minimum stock', () {
    final controller = NewProductController();
    addTearDown(controller.dispose);
    expect(
      controller.salvar(
        nome: 'Papel A4 75g',
        codigo: '7891234567895',
        estoqueMinimo: '25',
        valor: '1.234,56',
        quantidade: 20,
        categoria: 'Escritório',
      ),
      isNull,
    );
    final saved = Product.fromJson(productsJson.first);
    expect(saved.code, '7891234567895');
    expect(saved.price, 1234.56);
    expect(saved.minimumStock, 25);
    final home = HomepageController();
    addTearDown(home.dispose);
    expect(home.stockAlerts.any((p) => p.code == saved.code), isTrue);
    expect(controller.validateCode(saved.code), 'Este código já existe');
    expect(
      controller.salvar(
        nome: 'Produto',
        codigo: 'NEW-001',
        estoqueMinimo: '-1',
        valor: '10',
        quantidade: 0,
        categoria: 'Escritório',
      ),
      isNotNull,
    );
    expect(
      controller.salvar(
        nome: 'Produto',
        codigo: 'NEW-001',
        estoqueMinimo: '1',
        valor: 'NaN',
        quantidade: 0,
        categoria: 'Escritório',
      ),
      isNotNull,
    );
  });

  test('Scan handles a result, cancellation and failure', () async {
    final controller = NewProductController();
    addTearDown(controller.dispose);
    await controller.scanBarcode(() async => '7891234567895');
    expect(controller.sku.text, '7891234567895');
    await controller.scanBarcode(() async => null);
    expect(controller.sku.text, '7891234567895');
    await controller.scanBarcode(() async => throw Exception('camera'));
    expect(controller.error, isNotNull);
    expect(controller.scanning, isFalse);
  });

  testWidgets('Product button opens functional form and scanned SKU is saved', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: ButtonNewProduct()),
        routes: {
          NewProductPage.route: (_) =>
              NewProductPage(scanBarcode: () async => '7891234567895'),
        },
      ),
    );
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.byType(NewProductPage), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Fone de Ouvido 2');
    await tester.tap(find.byTooltip('Escanear código de barras'));
    await tester.pumpAndSettle();
    expect(find.text('7891234567895'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(3), '189,90');
    await tester.ensureVisible(find.text('Salvar Produto'));
    await tester.tap(find.text('Salvar Produto'));
    await tester.pumpAndSettle();
    expect(find.byType(ButtonNewProduct), findsOneWidget);
    expect(productsJson.first['name'], 'Fone de Ouvido 2');
    expect(productsJson.first['code'], '7891234567895');
    expect(productsJson.first['minimumStock'], 3);
    expect(tester.takeException(), isNull);
  });
}
