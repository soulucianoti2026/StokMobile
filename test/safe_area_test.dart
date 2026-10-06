import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/routes.dart';
import 'package:stokmobile/NewProductPage/Page/barcode_scanner_page.dart';
import 'package:stokmobile/loginpage/controllers/login_controller.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/productEditPage/page/product_edit_page.dart';
import 'package:stokmobile/productmodel/products_model.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(390, 844)]) {
    for (final route in {
      ...AppRoutes.routes,
      '/scanner': (_) => const BarcodeScannerPage(),
    }.entries) {
      testWidgets('${route.key} respects system insets at $size', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.view.padding = const FakeViewPadding(
          left: 12,
          top: 44,
          right: 12,
          bottom: 34,
        );
        tester.view.viewPadding = const FakeViewPadding(
          left: 12,
          top: 44,
          right: 12,
          bottom: 34,
        );
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => LoginController()),
              ChangeNotifierProvider(create: (_) => Productcontrollers()),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => route.key == ProductEditPage.route
                    ? ProductEditPage(
                        product: Product.fromJson({
                          'name': 'Produto teste',
                          'category': 'Categoria comprida para testar o layout',
                        }),
                      )
                    : route.value(context),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
        final areas = find.byType(SafeArea);
        expect(areas, findsWidgets);
        for (final element in areas.evaluate()) {
          final area = element.widget as SafeArea;
          final rect = tester.getRect(find.byWidget(area.child));
          expect(rect.left, greaterThanOrEqualTo(12));
          expect(rect.right, lessThanOrEqualTo(size.width - 12));
          expect(rect.top, greaterThanOrEqualTo(44));
          expect(rect.bottom, lessThanOrEqualTo(size.height - 34));
        }
        if (route.key == ProductEditPage.route) {
          tester.view.viewInsets = const FakeViewPadding(bottom: 240);
          await tester.pump();
          await tester.ensureVisible(find.text('Salvar alterações'));
          await tester.pump();
          expect(find.text('Salvar alterações').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 4));
      });
    }
  }
}
