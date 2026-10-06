import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/NewProductPage/Page/new_product_page.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(640, 360),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('New product fits $size at text scale $scale with keyboard', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const NewProductPage(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(TextField).at(1), 'ABC123');
        await tester.pumpAndSettle();
        expect(
          find.text('✓ Código único disponível para uso corporativo'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding(bottom: 200);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Aumentar quantidade'));
        await tester.tap(find.byTooltip('Aumentar quantidade'));
        await tester.pump();
        expect(find.text('11'), findsOneWidget);
        await tester.ensureVisible(find.text('Salvar Produto'));
        await tester.pumpAndSettle();
        expect(find.text('Salvar Produto').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
