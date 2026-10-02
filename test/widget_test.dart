import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/main.dart';
import 'package:stokmobile/nativesplashPage.dart';
import 'package:stokmobile/loginPage/page/login_page.dart';

void main() {
  testWidgets('Splash appears for three seconds then opens login', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(NativeSplashPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    await tester.pump(const Duration(milliseconds: 2999));
    expect(find.byType(NativeSplashPage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(NativeSplashPage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(LoginPage))).canPop(),
      isFalse,
    );
  });

  testWidgets('Disposing splash cancels navigation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NativeSplashPage()));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
}
