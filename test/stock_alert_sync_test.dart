import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/homepage/controllers/homepage_controller.dart';
import 'package:stokmobile/loginpage/controllers/login_controller.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/productMovPage/controllers/productMovePage_controller.dart';
import 'package:stokmobile/NewProductPage/controllers/new_product_controller.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Map<String, dynamic>> original;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    original = productsJson
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    productsJson
      ..clear()
      ..add({
        'code': 'ABC123',
        'name': 'Produto teste',
        'stock': 2,
        'price': 10.0,
      });
  });
  tearDown(() {
    productsJson
      ..clear()
      ..addAll(original);
  });

  test(
    'Edits persist in mock, reload and update alert fields and totals',
    () async {
      final products = Productcontrollers();
      final home = HomepageController();
      addTearDown(products.dispose);
      addTearDown(home.dispose);
      await products.getproducts();
      var notifications = 0;
      home.addListener(() => notifications++);
      await products.updateProduct(
        Product.fromJson({
          ...productsJson.first,
          'name': 'Nome atualizado',
          'stock': 4,
          'price': 20.0,
        }),
      );
      expect(home.stockAlerts.single.name, 'Nome atualizado');
      expect(home.stockAlerts.single.stock, 4);
      expect(home.stockValue, 80);
      await products.getproducts();
      expect(products.products.single.name, 'Nome atualizado');
      await products.updateProduct(
        Product.fromJson({...productsJson.first, 'stock': 10}),
      );
      expect(home.stockAlerts, isEmpty);
      expect(notifications, 2);
      products.deleteProduct(products.products.single);
      await products.getproducts();
      expect(products.products, isEmpty);
      expect(home.totalProducts, 0);
    },
  );

  test('Movements and new products notify home and product list', () async {
    final home = HomepageController();
    final products = Productcontrollers();
    final movement = ProductMovController();
    addTearDown(home.dispose);
    addTearDown(products.dispose);
    addTearDown(movement.dispose);
    await products.getproducts();
    movement.setOperation(MovementOperation.entry);
    movement.setQuantity('8');
    expect(movement.register(), isTrue);
    expect(home.stockAlerts, isEmpty);
    expect(products.products.single.stock, 10);
    expect(
      await NewProductController().salvar(
        nome: 'Novo Produto',
        codigo: 'DEF456',
        estoqueMinimo: '3',
        valor: '5',
        quantidade: 1,
        categoria: 'Escritório',
      ),
      isNull,
    );
    expect(home.stockAlerts.single.code, 'DEF456');
    expect(products.products.length, 2);
  });

  testWidgets('Visible homepage refreshes after editing a product', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final products = Productcontrollers();
    addTearDown(products.dispose);
    await products.getproducts();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginController(),
        child: const MaterialApp(home: HomePage()),
      ),
    );
    expect(find.text('Produto teste'), findsOneWidget);
    await products.updateProduct(
      Product.fromJson({...productsJson.first, 'name': 'Nome alterado'}),
    );
    await tester.pump();
    expect(find.text('Nome alterado'), findsOneWidget);
    expect(find.text('Produto teste'), findsNothing);
    await products.updateProduct(
      Product.fromJson({...productsJson.first, 'stock': 20}),
    );
    await tester.pump();
    expect(find.text('0 ALERTAS'), findsOneWidget);
    expect(find.text('Nenhum produto com estoque baixo.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
