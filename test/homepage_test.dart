import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/loginpage/controllers/login_controller.dart';

void main() {
  testWidgets('Home statistics remain visible on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginController(),
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Total de Produtos'), findsOneWidget);
    expect(find.text('Valor do Estoque'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
