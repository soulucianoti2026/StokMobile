import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stokmobile/shared/mocks/mock_users.dart';
import 'package:stokmobile/registerPage/controllers/controller.dart';
import 'package:stokmobile/registerPage/page/register_page.dart';
import 'package:stokmobile/loginpage/controllers/login_controller.dart';
import 'package:stokmobile/registerPage/services/user_photo_storage.dart';
import 'helpers/fake_image_picker.dart';

RegisterPage registrationPage() {
  final controller = RegisterController(imagePicker: FakeImagePicker());
  addTearDown(controller.dispose);
  return RegisterPage(controller: controller);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final disk = <String, String>{};
  var failWrite = false;
  setUp(() {
    disk.clear();
    failWrite = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final args = call.arguments as Map;
          if (call.method == 'read') return disk[args['key']];
          if (call.method == 'write') {
            if (failWrite) throw PlatformException(code: 'storage_error');
            disk[args['key'] as String] = args['value'] as String;
          }
          return null;
        });
  });

  const account = UsersMock(
    email: 'novo@example.com',
    senha: 'Senha1234',
    nome: 'Novo Usuário',
    documento: '12345678901',
  );

  test(
    'Restores registered accounts in a fresh repository and rejects duplicates',
    () async {
      final firstUsers = <UsersMock>[];
      await MockUsersRepository(users: firstUsers).register(account);
      expect(firstUsers.single.nome, 'Novo Usuário');
      final restoredUsers = <UsersMock>[];
      final restarted = MockUsersRepository(users: restoredUsers);
      await restarted.load();
      expect(restoredUsers.single.toJson(), account.toJson());
      await expectLater(
        restarted.register(account),
        throwsA(isA<DuplicateUserException>()),
      );
      await expectLater(
        restarted.register(
          const UsersMock(
            email: 'outro@example.com',
            senha: 'Senha1234',
            documento: '123.456.789-01',
          ),
        ),
        throwsA(isA<DuplicateUserException>()),
      );
    },
  );

  test('Failed writes do not add users and can be retried', () async {
    final users = <UsersMock>[];
    final repository = MockUsersRepository(users: users);
    failWrite = true;
    await expectLater(
      repository.register(account),
      throwsA(isA<PlatformException>()),
    );
    expect(users, isEmpty);
    failWrite = false;
    await repository.register(account);
    expect(users.length, 1);
  });

  test(
    'Photo and all account fields survive restart and cache removal',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'stokmobile_photo_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final source = await File(
        '${directory.path}/camera.jpg',
      ).writeAsBytes([1, 2, 3]);
      final photos = UserPhotoStorage(
        documentsDirectory: () async => directory,
      );
      final users = <UsersMock>[];
      await MockUsersRepository(
        users: users,
        photos: photos,
      ).register(account, photoSourcePath: source.path);
      await source.delete();

      final restored = <UsersMock>[];
      await MockUsersRepository(users: restored).load();
      expect(restored.single.nome, account.nome);
      expect(restored.single.documento, account.documento);
      expect(restored.single.email, account.email);
      expect(restored.single.senha, account.senha);
      expect(restored.single.foto, startsWith('assets/images/user_'));
      final reopenedPhotos = UserPhotoStorage(
        documentsDirectory: () async => directory,
      );
      expect(
        await (await reopenedPhotos.resolve(
          restored.single.foto,
        )).readAsBytes(),
        [1, 2, 3],
      );
    },
  );

  test('Failed account write removes copied photo and permits retry', () async {
    final directory = await Directory.systemTemp.createTemp(
      'stokmobile_photo_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final source = await File(
      '${directory.path}/camera.jpg',
    ).writeAsBytes([1, 2, 3]);
    final photos = UserPhotoStorage(documentsDirectory: () async => directory);
    final users = <UsersMock>[];
    final repository = MockUsersRepository(users: users, photos: photos);
    failWrite = true;
    await expectLater(
      repository.register(account, photoSourcePath: source.path),
      throwsA(isA<PlatformException>()),
    );
    expect(users, isEmpty);
    expect(
      await Directory('${directory.path}/assets/images').list().toList(),
      isEmpty,
    );
    failWrite = false;
    await repository.register(account, photoSourcePath: source.path);
    expect(await (await photos.resolve(users.single.foto)).exists(), isTrue);
  });

  test('Older accounts without photo remain readable', () {
    final oldAccount = account.toJson()..remove('foto');
    expect(UsersMock.fromJson(oldAccount).foto, isEmpty);
  });

  test('Login loads the account persisted by registration', () async {
    await MockUsersRepository(users: []).register(account);
    final login = LoginController();
    login.emailController.text = account.email;
    login.senhaController.text = account.senha;
    await login.login();
    expect(login.user?.email, account.email);
    usuariosMock.removeWhere((user) => user.email == account.email);
    login.emailController.dispose();
    login.senhaController.dispose();
    login.dispose();
  });

  test('Validates required fields and matching passwords', () {
    final controller = RegisterController();
    addTearDown(controller.dispose);
    expect(controller.validateName('Nome'), isNotNull);
    expect(controller.validateEmail('email'), isNotNull);
    expect(controller.validateDocument(''), isNotNull);
    expect(controller.validatePassword('123'), isNotNull);
    controller.password.text = 'Senha1234';
    expect(controller.validateConfirmation('Outra123'), isNotNull);
    expect(controller.validateConfirmation('Senha1234'), isNull);
  });

  testWidgets('Renders fields, validates and toggles password visibility', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: registrationPage()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe seu nome completo.'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Mostrar Senha'));
    await tester.tap(find.byTooltip('Mostrar Senha'));
    await tester.pump();
    expect(find.byTooltip('Ocultar Senha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Submitting the form saves all account fields and returns to login',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Login de teste')),
          routes: {RegisterPage.route: (_) => registrationPage()},
        ),
      );
      final context = tester.element(find.text('Login de teste'));
      Navigator.of(context).pushNamed(RegisterPage.route);
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Maria da Silva');
      await tester.enterText(fields.at(1), 'MARIA@example.com');
      await tester.enterText(fields.at(2), 'RG-123456');
      await tester.enterText(fields.at(3), 'Senha1234');
      await tester.enterText(fields.at(4), 'Senha1234');
      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.runAsync(() async {
        await tester.tap(find.text('Cadastrar'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Login de teste'), findsOneWidget);
      final restored = <UsersMock>[];
      await tester.runAsync(() => MockUsersRepository(users: restored).load());
      final saved = restored.singleWhere(
        (user) => user.email == 'maria@example.com',
      );
      expect(saved.nome, 'Maria da Silva');
      expect(saved.documento, 'RG123456');
      expect(saved.senha, 'Senha1234');
      usuariosMock.removeWhere((user) => user.email == saved.email);
    },
  );

  testWidgets('Works on a narrow display with large text and keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.5),
            viewInsets: const EdgeInsets.only(bottom: 240),
          ),
          child: child!,
        ),
        home: registrationPage(),
      ),
    );
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
