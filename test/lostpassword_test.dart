import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/lostpasswordPage/lostpasword_page.dart';

void main() {
  testWidgets('Valida e-mail e informa serviço indisponível', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LostpaswordPage()));
    await tester.tap(find.text('Enviar instruções'));
    await tester.pump();
    expect(find.text('Informe seu e-mail corporativo.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'invalido');
    await tester.tap(find.text('Enviar instruções'));
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'teste@empresa.com');
    await tester.tap(find.text('Enviar instruções'));
    await tester.pump();
    expect(
      find.text('O serviço de recuperação de senha ainda não está disponível.'),
      findsOneWidget,
    );
  });

  testWidgets('Envia e-mail sem espaços e bloqueia envios duplicados', (
    tester,
  ) async {
    final completion = Completer<void>();
    final emails = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: LostpaswordPage(
          sendInstructions: (email) {
            emails.add(email);
            return completion.future;
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), ' teste@empresa.com ');
    await tester.tap(find.text('Enviar instruções'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(emails, ['teste@empresa.com']);
    completion.complete();
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Se o e-mail estiver cadastrado'),
      findsOneWidget,
    );
  });

  testWidgets('Trata falha e permite tentar novamente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LostpaswordPage(
          sendInstructions: (_) async => throw Exception('Falha'),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'teste@empresa.com');
    await tester.tap(find.text('Enviar instruções'));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível enviar as instruções. Tente novamente.'),
      findsOneWidget,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('Suporta tela pequena e descarte durante envio', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final completion = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: LostpaswordPage(sendInstructions: (_) => completion.future),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'teste@empresa.com');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    completion.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
