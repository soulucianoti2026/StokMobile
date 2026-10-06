import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stokmobile/NewProductPage/controllers/new_product_controller.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';
import 'package:stokmobile/shared/widgets/product_photo.dart';
import 'helpers/fake_image_picker.dart';

const pixel =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aN1sAAAAASUVORK5CYII=';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Map<String, dynamic>> original;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    original = productsJson.map((p) => Map<String, dynamic>.from(p)).toList();
  });
  tearDown(() {
    productsJson
      ..clear()
      ..addAll(original);
  });

  test(
    'Creation and editing restore photo and product after memory is cleared',
    () async {
      final create = NewProductController();
      final edit = Productcontrollers();
      addTearDown(create.dispose);
      addTearDown(edit.dispose);
      create.nome.text = 'Produto com foto';
      create.sku.text = 'PHOTO-001';
      create.valor.text = '10';
      create.imageUrl = 'data:image/jpeg;base64,$pixel';
      expect(await create.submit(), isTrue);
      productsJson.clear();
      await MockProductsRepository().load();
      expect(productsJson.first['imageUrl'], create.imageUrl);
      await edit.updateProduct(
        Product.fromJson({
          ...productsJson.first,
          'name': 'Foto alterada',
          'imageUrl': 'data:image/png;base64,$pixel',
        }),
      );
      productsJson.clear();
      await MockProductsRepository().load();
      expect(productsJson.first['name'], 'Foto alterada');
      expect(productsJson.first['imageUrl'], 'data:image/png;base64,$pixel');
    },
  );

  testWidgets(
    'Camera captures bytes and cancellation preserves existing photo',
    (tester) async {
      final picker = FakeImagePicker()
        ..selected = XFile.fromData(
          Uint8List.fromList(base64Decode(pixel)),
          name: 'photo.png',
        );
      var photo = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ProductPhotoPicker(
                photo: photo,
                imagePicker: picker,
                onChanged: (value) => setState(() => photo = value),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tirar foto'));
      await tester.pumpAndSettle();
      expect(picker.lastSource, ImageSource.camera);
      expect(photo, 'data:image/jpeg;base64,$pixel');
      await tester.tap(find.text('Escolher da galeria'));
      await tester.pumpAndSettle();
      expect(picker.lastSource, ImageSource.gallery);
      expect(photo, 'data:image/jpeg;base64,$pixel');
      picker.selected = null;
      await tester.tap(find.text('Alterar foto'));
      await tester.pumpAndSettle();
      expect(photo, 'data:image/jpeg;base64,$pixel');
      picker.failure = Exception('Camera denied');
      await tester.tap(find.text('Alterar foto'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Verifique a permissão'), findsOneWidget);
      expect(photo, 'data:image/jpeg;base64,$pixel');
    },
  );
}
