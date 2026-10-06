import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/loginpage/controllers/login_controller.dart';
import 'package:stokmobile/loginpage/page/login_page.dart';
import 'package:stokmobile/profilePage/profile_edit_page.dart';
import 'package:stokmobile/registerPage/controllers/controller.dart';
import 'package:stokmobile/registerPage/services/user_photo_storage.dart';
import 'package:stokmobile/shared/mocks/mock_users.dart';
import 'package:stokmobile/shared/exceptions/auth_exception.dart';

import 'helpers/fake_image_picker.dart';

const account = UsersMock(
  email: 'mariana@empresa.com',
  senha: 'Senha1234',
  nome: 'Mariana Oliveira',
  documento: '12345678900',
);
const edited = UsersMock(
  email: 'maria@empresa.com',
  senha: 'Nova12345',
  nome: 'Maria Oliveira',
  documento: '98765432100',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final disk = <String, String>{};
  var failWrite = false;
  setUp(() {
    disk.clear();
    failWrite = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            final args = call.arguments as Map;
            if (call.method == 'read') return disk[args['key']];
            if (call.method == 'write') {
              if (failWrite) throw PlatformException(code: 'storage_error');
              disk[args['key'] as String] = args['value'] as String;
            }
            if (call.method == 'delete') disk.remove(args['key']);
            return null;
          },
        );
  });

  test(
    'Migrates registered users and persists all edited fields after restart',
    () async {
      disk[MockUsersRepository.legacyStorageKey] = jsonEncode([
        account.toJson(),
      ]);
      final users = <UsersMock>[];
      final repository = MockUsersRepository(users: users);
      await repository.update(account.email, edited);
      expect(users.single.toJson(), edited.toJson());
      expect(disk.containsKey(MockUsersRepository.legacyStorageKey), isFalse);
      final restored = <UsersMock>[];
      await MockUsersRepository(users: restored).load();
      expect(restored.single.toJson(), edited.toJson());
    },
  );

  test(
    'Renamed and deleted seed accounts do not reappear on restart',
    () async {
      final repository = MockUsersRepository(users: [account]);
      await repository.update(account.email, edited);
      final restored = [account];
      final restarted = MockUsersRepository(users: restored);
      await restarted.load();
      expect(restored.single.email, edited.email);
      await restarted.delete(edited.email);
      final afterDeletion = [account];
      await MockUsersRepository(users: afterDeletion).load();
      expect(afterDeletion, isEmpty);
    },
  );

  test(
    'Own fields are accepted while another account email or document is rejected',
    () async {
      final users = [account, edited];
      final repository = MockUsersRepository(users: users);
      await repository.update(account.email, account);
      await expectLater(
        repository.update(account.email, edited),
        throwsA(isA<DuplicateUserException>()),
      );
      await expectLater(
        repository.update(
          account.email,
          UsersMock(
            email: account.email,
            senha: account.senha,
            nome: account.nome,
            documento: edited.documento,
          ),
        ),
        throwsA(isA<DuplicateUserException>()),
      );
      expect(users.first.toJson(), account.toJson());
    },
  );

  test(
    'Failed update or deletion leaves the persisted account intact',
    () async {
      final users = <UsersMock>[];
      final repository = MockUsersRepository(users: users);
      await repository.register(account);
      failWrite = true;
      await expectLater(
        repository.update(account.email, edited),
        throwsA(isA<PlatformException>()),
      );
      await expectLater(
        repository.delete(account.email),
        throwsA(isA<PlatformException>()),
      );
      final restored = <UsersMock>[];
      await MockUsersRepository(users: restored).load();
      expect(restored.single.toJson(), account.toJson());
      expect(users.single.toJson(), account.toJson());
      failWrite = false;
      await repository.update(account.email, edited);
      expect(users.single.email, edited.email);
    },
  );

  test(
    'Photo replacement is durable, rolls back on failure and cleans up after deletion',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'stokmobile_edit_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final photos = UserPhotoStorage(
        documentsDirectory: () async => directory,
      );
      final source = await File(
        '${directory.path}/photo.jpg',
      ).writeAsBytes([1, 2, 3]);
      final users = <UsersMock>[];
      final repository = MockUsersRepository(users: users, photos: photos);
      await repository.register(account, photoSourcePath: source.path);
      final oldPhoto = users.single.foto;
      failWrite = true;
      await expectLater(
        repository.update(account.email, edited, photoSourcePath: source.path),
        throwsA(isA<PlatformException>()),
      );
      expect(await (await photos.resolve(oldPhoto)).exists(), isTrue);
      expect(
        await Directory('${directory.path}/assets/images').list().length,
        1,
      );
      failWrite = false;
      final result = await repository.update(
        account.email,
        edited,
        photoSourcePath: source.path,
      );
      expect(await (await photos.resolve(oldPhoto)).exists(), isFalse);
      await source.delete();
      final restored = <UsersMock>[];
      await MockUsersRepository(users: restored).load();
      expect(restored.single.foto, result.foto);
      expect(await (await photos.resolve(result.foto)).readAsBytes(), [
        1,
        2,
        3,
      ]);
      await repository.delete(edited.email);
      expect(await (await photos.resolve(result.foto)).exists(), isFalse);
    },
  );

  test(
    'Login accepts the updated credentials and rejects the old credentials',
    () async {
      final backup = [...usuariosMock];
      usuariosMock
        ..clear()
        ..add(account);
      final login = LoginController();
      addTearDown(() {
        usuariosMock
          ..clear()
          ..addAll(backup);
        login.emailController.dispose();
        login.senhaController.dispose();
        login.dispose();
      });
      await MockUsersRepository.instance.update(account.email, edited);
      login.emailController.text = account.email;
      login.senhaController.text = account.senha;
      await expectLater(login.login(), throwsA(isA<AuthException>()));
      login.emailController.text = edited.email;
      login.senhaController.text = edited.senha;
      await login.login();
      expect(login.user?.nome, edited.nome);
      expect(login.user?.documento, edited.documento);
    },
  );

  Future<void> openEditor(
    WidgetTester tester, {
    GlobalKey? captureKey,
    bool dashboard = true,
  }) async {
    final repository = MockUsersRepository(users: [account]);
    final controller = RegisterController(
      repository: repository,
      initialUser: account,
      imagePicker: FakeImagePicker(),
    );
    final login = LoginController()..updateProfile(account);
    addTearDown(controller.dispose);
    addTearDown(() {
      login.emailController.dispose();
      login.senhaController.dispose();
      login.dispose();
    });
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: ChangeNotifierProvider.value(
          value: login,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: dashboard
                ? const HomePage()
                : Builder(
                    builder: (context) => Scaffold(
                      body: Column(
                        children: [
                          const Text('Olá, Mariana'),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              ProfileEditPage.route,
                            ),
                            child: const Text('editar perfil'),
                          ),
                        ],
                      ),
                    ),
                  ),
            routes: {
              ProfileEditPage.route: (_) =>
                  ProfileEditPage(controller: controller),
              LoginPage.route: (_) =>
                  const Scaffold(body: Text('Login após exclusão')),
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Olá, Mariana'), findsOneWidget);
    await tester.tap(find.text('editar perfil'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Home link opens populated profile; saving updates session and disk',
    (tester) async {
      await openEditor(tester);
      final fields = find.byType(TextFormField);
      expect(find.text(account.nome), findsOneWidget);
      expect(find.text(account.email), findsOneWidget);
      expect(
        (tester.widget<TextFormField>(fields.at(3))).controller!.text,
        isEmpty,
      );
      await tester.enterText(fields.at(0), edited.nome);
      await tester.enterText(fields.at(1), edited.email);
      await tester.ensureVisible(find.text('Salvar alterações'));
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(find.text('Olá, Maria'), findsOneWidget);
      final restored = <UsersMock>[];
      await tester.runAsync(() => MockUsersRepository(users: restored).load());
      expect(restored.single.email, edited.email);
      expect(restored.single.senha, account.senha);
    },
  );

  testWidgets('New password must match confirmation and is saved', (
    tester,
  ) async {
    await openEditor(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(3), edited.senha);
    await tester.enterText(fields.at(4), 'Outra123');
    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    expect(find.text('As senhas devem ser iguais.'), findsOneWidget);
    await tester.enterText(fields.at(4), edited.senha);
    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    final restored = <UsersMock>[];
    await tester.runAsync(() => MockUsersRepository(users: restored).load());
    expect(restored.single.senha, edited.senha);
  });

  testWidgets(
    'Self deletion requires confirmation and signs out after saving',
    (tester) async {
      await openEditor(tester);
      await tester.ensureVisible(find.text('Autoexclusão'));
      await tester.tap(find.text('Autoexclusão'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Não'));
      await tester.pumpAndSettle();
      expect(find.text('Editar perfil'), findsOneWidget);
      expect(disk, isEmpty);
      await tester.tap(find.text('Autoexclusão'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Sim, excluir'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Login após exclusão'), findsOneWidget);
      final restored = [account];
      await tester.runAsync(() => MockUsersRepository(users: restored).load());
      expect(restored, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Back discards unsaved profile edits', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.byType(TextFormField).first, edited.nome);
    await tester.ensureVisible(find.byTooltip('Voltar'));
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Mariana'), findsOneWidget);
    expect(disk, isEmpty);
  });

  testWidgets(
    'Profile fits narrow screens and can be rendered for visual review',
    (tester) async {
      final preview = Platform.environment['PROFILE_PREVIEW'] == '1';
      tester.view.physicalSize = preview
          ? const Size(402, 1186)
          : const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 25);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      if (preview) {
        await tester.runAsync(() async {
          await (FontLoader(
            'Inter',
          )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
        });
        debugDisableShadows = false;
      }
      final key = GlobalKey();
      await openEditor(tester, captureKey: key, dashboard: false);
      if (preview) {
        await tester.runAsync(() async {
          final context = tester.element(find.byType(ProfileEditPage));
          await precacheImage(
            const AssetImage('assets/images/register/camera.png'),
            context,
          );
          if (!context.mounted) return;
          await precacheImage(
            const AssetImage('assets/images/register/camera_preview.png'),
            context,
          );
        });
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'build/profile_preview.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        debugDisableShadows = true;
      }
      await tester.ensureVisible(find.text('Autoexclusão'));
      expect(find.text('Autoexclusão').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
