// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:stokmobile/homepage/homepage.dart';

// void main() {
//   testWidgets('Homepage displays stock summaries and low stock alerts', (
//     tester,
//   ) async {
//     await tester.pumpWidget(const MaterialApp(home: Homepage()));

//     expect(find.text('142'), findsOneWidget);
//     expect(find.text('R\$ 45280,00'), findsOneWidget);
//     expect(find.text('12'), findsOneWidget);
//     expect(find.text('8'), findsOneWidget);
//     expect(find.text('Teclado Mecânico RGB'), findsOneWidget);
//     expect(find.text('Papel A4 Chamex 75g'), findsOneWidget);
//     expect(find.text('Cabo HDMI 2.0 Ultra'), findsOneWidget);
//     expect(find.text('Caixa organizadora'), findsNothing);
//     expect(tester.takeException(), isNull);
//   });

//   testWidgets('Homepage fits a narrow screen with enlarged text', (
//     tester,
//   ) async {
//     tester.view.physicalSize = const Size(320, 640);
//     tester.view.devicePixelRatio = 1;
//     addTearDown(tester.view.resetPhysicalSize);
//     addTearDown(tester.view.resetDevicePixelRatio);

//     await tester.pumpWidget(
//       const MaterialApp(
//         home: MediaQuery(
//           data: MediaQueryData(textScaler: TextScaler.linear(2)),
//           child: Homepage(),
//         ),
//       ),
//     );
//     await tester.drag(
//       find.byType(SingleChildScrollView),
//       const Offset(0, -1000),
//     );
//     await tester.pumpAndSettle();
//     expect(tester.takeException(), isNull);
//   });
// }
