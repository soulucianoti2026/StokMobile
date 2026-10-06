import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/productEditPage/page/product_edit_page.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/profilePage/profile_avatar.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

void main() {
  testWidgets('Editing coffee shows selected data and app icon without a photo', (tester) async {
    final product = Product.fromJson(productsJson.firstWhere((p) => p['code'] == 'COD-004'));
    final controller = Productcontrollers();
    addTearDown(controller.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(home: ProductEditPage(product: product)),
    ));
    await tester.pumpAndSettle();
    expect(find.text(product.name), findsWidgets);
    expect(find.text(product.code), findsOneWidget);
    expect(find.text('Teclado Mecânico RGB'), findsNothing);
    expect(find.text('COD-001'), findsNothing);
    final fields = tester.widgetList<EditableText>(find.byType(EditableText)).toList();
    expect(fields.map((f) => f.controller.text), [product.name, product.price.toString(), product.stock.toString(), product.description]);
    expect(tester.widget<Image>(find.byType(Image)).image, const AssetImage('assets/images/app_icon.png'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('User without photo displays Material account icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ProfileAvatar(photo: ''))));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.account_box), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
