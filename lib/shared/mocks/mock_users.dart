import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stokmobile/registerPage/services/user_photo_storage.dart';

class UsersMock {
  final String email;
  final String senha;

  final String nome;
  final String documento;
  final String foto;

  const UsersMock({
    required this.email,
    required this.senha,
    this.nome = '',
    this.documento = '',
    this.foto = '',
  });

  factory UsersMock.fromJson(Map<String, dynamic> json) => UsersMock(
    email: json['email'] as String,
    senha: json['senha'] as String,
    nome: json['nome'] as String? ?? '',
    documento: json['documento'] as String? ?? '',
    foto: json['foto'] as String? ?? '',
  );

  Map<String, String> toJson() => {
    'email': email,
    'senha': senha,
    'nome': nome,
    'documento': documento,
    'foto': foto,
  };
}

const _initialUsers = [
  UsersMock(email: 'bruno@gmail.com', senha: 'Bruno12345'),
  UsersMock(email: 'arthur@gmail.com', senha: 'Arthur12345'),
  UsersMock(email: 'gabril@gmail.com', senha: 'Gabril12345'),
  UsersMock(email: 'luciano@gmail.com', senha: 'Luciano12345'),
];

final List<UsersMock> usuariosMock = [..._initialUsers];

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
