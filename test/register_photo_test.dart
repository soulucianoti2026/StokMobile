import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stokmobile/registerPage/controllers/controller.dart';
import 'package:stokmobile/registerPage/page/register_page.dart';

import 'helpers/fake_image_picker.dart';

XFile testPhoto() => XFile.fromData(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
  ),
  name: 'photo.png',
  mimeType: 'image/png',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Cancel preserves previous photo and permission errors allow retry',
    () async {
      final picker = FakeImagePicker()..selected = testPhoto();
      final controller = RegisterController(imagePicker: picker);
      addTearDown(controller.dispose);
      await controller.pickPhoto(ImageSource.gallery);
      final previous = controller.photo;
      expect(controller.photoBytes, isNotEmpty);
      picker.selected = null;
      await controller.pickPhoto(ImageSource.camera);
      expect(controller.photo, same(previous));
      expect(controller.error, isNull);
      picker.failure = PlatformException(code: 'camera_access_denied');
      await controller.pickPhoto(ImageSource.camera);
      expect(controller.error, contains('permissões'));
      expect(controller.isPickingPhoto, isFalse);
      expect(controller.photo, same(previous));
      picker.failure = null;
      picker.selected = testPhoto();
      await controller.pickPhoto(ImageSource.camera);
      expect(controller.error, isNull);
      expect(controller.photo, isNot(same(previous)));
    },
  );

  test('Recovers the Android photo after activity recreation', () async {
    final picker = FakeImagePicker()
      ..lost = LostDataResponse(files: [testPhoto()]);
    final controller = RegisterController(imagePicker: picker);
    addTearDown(controller.dispose);
    await controller.recoverPhoto();
    expect(controller.photoBytes, isNotEmpty);
    expect(controller.isPickingPhoto, isFalse);
  });

  testWidgets('Photo actions select their source and display a preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 1154);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 25);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    final picker = FakeImagePicker();
    final controller = RegisterController(imagePicker: picker);
    addTearDown(controller.dispose);
    final boundaryKey = GlobalKey();
    if (Platform.environment['REGISTER_PREVIEW'] == '1') {
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);
      await tester.runAsync(() async {
        final font = FontLoader('Inter')
          ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
        await font.load();
      });
    }
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RegisterPage(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(RegisterPage));
      await precacheImage(
        const AssetImage('assets/images/register/camera_preview.png'),
        context,
      );
      if (!context.mounted) return;
      await precacheImage(
        const AssetImage('assets/images/register/camera.png'),
        context,
      );
    });
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma foto adicionada'), findsOneWidget);
    expect(tester.takeException(), isNull);
    if (Platform.environment['REGISTER_PREVIEW'] == '1') {
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build').create(recursive: true);
        await File(
          'build/register_preview.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    debugDisableShadows = true;
    await tester.ensureVisible(find.text('Adicionar foto existente'));
    await tester.tap(find.text('Adicionar foto existente'));
    await tester.pumpAndSettle();
    expect(picker.lastSource, ImageSource.gallery);
    expect(find.text('Nenhuma foto adicionada'), findsOneWidget);
    picker.selected = testPhoto();
    await tester.tap(find.text('Tirar foto com a câmera'));
    await tester.pumpAndSettle();
    expect(picker.lastSource, ImageSource.camera);
    expect(find.bySemanticsLabel('Prévia da foto do usuário'), findsOneWidget);
    expect(find.text('Nenhuma foto adicionada'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
