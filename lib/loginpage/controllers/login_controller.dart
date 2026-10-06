import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stokmobile/registerPage/services/user_photo_storage.dart';
import 'package:flutter/material.dart';
import 'package:stokmobile/loginpage/model/user.dart';
import 'package:stokmobile/shared/exceptions/auth_exception.dart';
import 'package:stokmobile/shared/mocks/mock_users.dart';

class LoginController extends ChangeNotifier {
  final RegExp _emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
  final RegExp _senhaRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  User? user;

  void updateProfile(UsersMock profile) {
    user = User(
      email: profile.email,
      senha: profile.senha,
      nome: profile.nome,
      documento: profile.documento,
      foto: profile.foto,
    );
    notifyListeners();
  }

  void logout() {
    user = null;
    emailController.clear();
    senhaController.clear();
    notifyListeners();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  // Utilizada para validar nosso formulário por dentro do controller
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  bool isActiveCheckbox = true;
  bool isLoading = false;
  bool isPasswordVisible = false;

  void changeIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void changeAtivateCheckBox() {
    isActiveCheckbox = !isActiveCheckbox;
    notifyListeners();
  }

  void changePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  Future<void> handleLogin() async {
    if (!key.currentState!.validate()) {
      throw ErrorDescription('validação incorreta!');
    }

    changeIsLoading(true);
    try {
      await login();
      emailController.clear();
      senhaController.clear();
    } finally {
      changeIsLoading(false);
    }
  }

  Future<void> login() async {
    try {
      await MockUsersRepository.instance.load();
    } catch (_) {
      throw AuthException(
        'Não foi possível carregar os usuários salvos. Tente novamente.',
      );
    }
    // simula o delay de uma chamada de API
    await Future.delayed(const Duration(seconds: 2));

    final email = emailController.text.trim().toLowerCase();
    final senha = senhaController.text.trim();

    for (final searchUser in usuariosMock) {
      if (searchUser.email == email && searchUser.senha == senha) {
        user = User(
          email: searchUser.email,
          senha: searchUser.senha,
          nome: searchUser.nome,
          documento: searchUser.documento,
          foto: searchUser.foto,
        );
        return;
      }
    }

    throw AuthException('E-mail ou senha incorretos!');
  }

  String? validateEmail(String? value) {
    if (_emailRegex.hasMatch(emailController.text.trim())) {
      return null;
    }
    return 'E-mail inválido';
  }

  String? validatePassword(String? value) {
    if (_senhaRegex.hasMatch(senhaController.text.trim())) {
      return null;
    }
    return 'Senha inválida';
  }
}

class DuplicateUserException implements Exception {
  const DuplicateUserException(this.message);
  final String message;
}

/// The mock remains the login source; added accounts survive app restarts.
/// Write first, then update memory so a storage failure never reports success.
class MockUsersRepository {
  MockUsersRepository({
    FlutterSecureStorage? storage,
    List<UsersMock>? users,
    UserPhotoStorage? photos,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _photos = photos ?? UserPhotoStorage(),
       _users = users ?? usuariosMock;

  static final instance = MockUsersRepository();
  static const storageKey = 'stokmobile.users.v2';
  static const legacyStorageKey = 'stokmobile.registered_users.v1';
  final FlutterSecureStorage _storage;
  final UserPhotoStorage _photos;
  final List<UsersMock> _users;
  Future<void>? _loading;
  Future<void> _pendingWrite = Future.value();

  Future<void> load() => _loading ??= _read();

  Future<void> _read() async {
    try {
      final snapshot = await _storage.read(key: storageKey);
      final raw = snapshot ?? await _storage.read(key: legacyStorageKey);
      final saved = raw == null
          ? <UsersMock>[]
          : (jsonDecode(raw) as List)
                .map(
                  (item) => UsersMock.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList();
      // A complete snapshot preserves renamed/deleted seed accounts as well.
      if (snapshot != null) _users.clear();
      for (final user in saved) {
        final index = _users.indexWhere(
          (existing) =>
              existing.email.toLowerCase() == user.email.toLowerCase(),
        );
        if (index < 0) {
          _users.add(user);
        } else {
          _users[index] = user;
        }
      }
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }

  Future<void> register(UsersMock user, {String? photoSourcePath}) {
    final operation = _pendingWrite.then(
      (_) => _register(user, photoSourcePath),
    );
    _pendingWrite = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _register(UsersMock user, String? photoSourcePath) async {
    await load();
    if (_users.any(
      (existing) => existing.email.toLowerCase() == user.email.toLowerCase(),
    )) {
      throw const DuplicateUserException('Este e-mail já está cadastrado.');
    }
    if (_users.any(
      (existing) =>
          existing.documento.isNotEmpty &&
          normalizeDocument(existing.documento) ==
              normalizeDocument(user.documento),
    )) {
      throw const DuplicateUserException(
        'Este CPF/identidade já está cadastrado.',
      );
    }
    String? savedPhoto;
    late final List<UsersMock> next;
    try {
      if (photoSourcePath != null) {
        savedPhoto = await _photos.save(photoSourcePath);
        user = UsersMock(
          email: user.email,
          senha: user.senha,
          nome: user.nome,
          documento: user.documento,
          foto: savedPhoto,
        );
      }
      next = [..._users, user];
      await _writeSnapshot(next);
    } catch (_) {
      if (savedPhoto != null) await _photos.delete(savedPhoto);
      rethrow;
    }
    _users.add(user);
  }

  Future<UsersMock> update(
    String originalEmail,
    UsersMock changes, {
    String? photoSourcePath,
  }) {
    final operation = _pendingWrite.then((_) async {
      await load();
      final index = _users.indexWhere(
        (u) => u.email.toLowerCase() == originalEmail.toLowerCase(),
      );
      if (index < 0) throw StateError('Usuário não encontrado');
      for (var i = 0; i < _users.length; i++) {
        if (i == index) continue;
        if (_users[i].email.toLowerCase() == changes.email.toLowerCase()) {
          throw const DuplicateUserException('Este e-mail já está cadastrado.');
        }
        if (changes.documento.isNotEmpty &&
            normalizeDocument(_users[i].documento) ==
                normalizeDocument(changes.documento)) {
          throw const DuplicateUserException(
            'Este CPF/identidade já está cadastrado.',
          );
        }
      }
      final previous = _users[index];
      String? newPhoto;
      late UsersMock updated;
      try {
        if (photoSourcePath != null) {
          newPhoto = await _photos.save(photoSourcePath);
        }
        updated = UsersMock(
          email: changes.email,
          senha: changes.senha,
          nome: changes.nome,
          documento: changes.documento,
          foto: newPhoto ?? previous.foto,
        );
        final next = [..._users]..[index] = updated;
        await _writeSnapshot(next);
        _users[index] = updated;
      } catch (_) {
        if (newPhoto != null) await _removePhoto(newPhoto);
        rethrow;
      }
      if (newPhoto != null && previous.foto.isNotEmpty) {
        await _removePhoto(previous.foto);
      }
      return updated;
    });
    _pendingWrite = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> delete(String email) {
    final operation = _pendingWrite.then((_) async {
      await load();
      final index = _users.indexWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
      if (index < 0) throw StateError('Usuário não encontrado');
      final previous = _users[index];
      final next = [..._users]..removeAt(index);
      await _writeSnapshot(next);
      _users.removeAt(index);
      if (previous.foto.isNotEmpty) await _removePhoto(previous.foto);
    });
    _pendingWrite = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _writeSnapshot(List<UsersMock> users) async {
    await _storage.write(
      key: storageKey,
      value: jsonEncode(users.map((u) => u.toJson()).toList()),
    );
    // Only retire the old registration data after the new snapshot is durable.
    try {
      await _storage.delete(key: legacyStorageKey);
    } catch (_) {}
  }

  Future<void> _removePhoto(String path) async {
    // The committed account change must not be reported as failed if cleanup fails.
    try {
      await _photos.delete(path);
    } catch (_) {}
  }

  static String normalizeDocument(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
}
