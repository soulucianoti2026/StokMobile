import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/homePage/homepage.dart';
import 'package:stokmobile/loginPage/loginpage.dart';
import 'package:stokmobile/main.dart';
import 'package:stokmobile/routes.dart';

void main() {
  testWidgets('App starts on LoginPage', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(Homepage), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(LoginPage))).canPop(),
      isFalse,
    );
  });

  testWidgets('Home route opens Homepage', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    Navigator.of(
      tester.element(find.byType(LoginPage)),
    ).pushNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.byType(Homepage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
