import 'package:stokmobile/loginpage/controllers/login_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stokmobile/shared/mocks/mock_users.dart';
import 'package:stokmobile/registerPage/services/user_photo_storage.dart';

class RegisterController extends ChangeNotifier {
  RegisterController({
    MockUsersRepository? repository,
    ImagePicker? imagePicker,
    this.initialUser,
    UserPhotoStorage? photoStorage,
  }) : _repository = repository ?? MockUsersRepository.instance,
       _imagePicker = imagePicker ?? ImagePicker(),
       _photoStorage = photoStorage ?? UserPhotoStorage() {
    name.text = initialUser?.nome ?? '';
    email.text = initialUser?.email ?? '';
    document.text = initialUser?.documento ?? '';
  }
  final UsersMock? initialUser;
  final UserPhotoStorage _photoStorage;
  UsersMock? savedUser;
  bool get isEditing => initialUser != null;

  Future<void> initialize() async {
    final path = initialUser?.foto ?? '';
    if (path.isNotEmpty) {
      isPickingPhoto = true;
      notifyListeners();
      try {
        final file = await _photoStorage.resolve(path);
        final bytes = await file.readAsBytes();
        if (!_disposed) photoBytes = bytes;
      } catch (_) {
        if (!_disposed) {
          error =
              'Não foi possível carregar a foto salva. Você pode selecionar outra.';
        }
      } finally {
        if (!_disposed) {
          isPickingPhoto = false;
          notifyListeners();
        }
      }
    }
    if (!_disposed) await recoverPhoto();
  }

  final MockUsersRepository _repository;
  final ImagePicker _imagePicker;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final document = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool isLoading = false;
  bool isPickingPhoto = false;
  XFile? photo;
  Uint8List? photoBytes;
  bool passwordVisible = false;
  bool confirmationVisible = false;
  bool _disposed = false;
  String? error;

  Future<void> _setPhoto(XFile selected) async {
    final bytes = await selected.readAsBytes();
    if (bytes.isEmpty) throw StateError('Foto vazia');
    if (_disposed) return;
    photo = selected;
    photoBytes = bytes;
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (_disposed || isLoading || isPickingPhoto) return;
    isPickingPhoto = true;
    error = null;
    notifyListeners();
    try {
      final selected = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (selected != null) await _setPhoto(selected);
    } catch (_) {
      error =
          'Não foi possível acessar a foto. Verifique as permissões '
          'de câmera ou galeria e tente novamente.';
    } finally {
      if (!_disposed) {
        isPickingPhoto = false;
        notifyListeners();
      }
    }
  }

  /// Android can recreate the activity while the native camera is open.
  Future<void> recoverPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (_disposed || isPickingPhoto || isLoading) return;
    isPickingPhoto = true;
    notifyListeners();
    try {
      final response = await _imagePicker.retrieveLostData();
      if (response.files?.isNotEmpty ?? false) {
        await _setPhoto(response.files!.first);
      } else if (response.exception != null) {
        throw response.exception!;
      }
    } catch (_) {
      error = 'Não foi possível recuperar a foto. Selecione-a novamente.';
    } finally {
      if (!_disposed) {
        isPickingPhoto = false;
        notifyListeners();
      }
    }
  }

  String? validateName(String? value) =>
      (value ?? '')
              .trim()
              .split(RegExp(r'\s+'))
              .where((part) => part.length > 1)
              .length <
          2
      ? 'Informe seu nome completo.'
      : null;
  String? validateEmail(String? value) =>
      RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch((value ?? '').trim())
      ? null
      : 'Informe um e-mail válido.';
  String? validateDocument(String? value) =>
      MockUsersRepository.normalizeDocument(value ?? '').length < 5
      ? 'Informe seu CPF ou identidade.'
      : null;
  String? validatePassword(String? value) =>
      (isEditing && (value ?? '').isEmpty) ||
          RegExp(
            r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
          ).hasMatch(value ?? '')
      ? null
      : 'Use 8 ou mais caracteres, com letras e números, sem símbolos.';
  String? validateConfirmation(String? value) =>
      (isEditing && password.text.isEmpty && (value ?? '').isEmpty) ||
          value == password.text && (value ?? '').isNotEmpty
      ? null
      : 'As senhas devem ser iguais.';

  void togglePassword() {
    passwordVisible = !passwordVisible;
    notifyListeners();
  }

  void toggleConfirmation() {
    confirmationVisible = !confirmationVisible;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (_disposed || isLoading || isPickingPhoto) return false;
    error = null;
    if (!(formKey.currentState?.validate() ?? false)) {
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    try {
      final account = UsersMock(
        email: email.text.trim().toLowerCase(),
        senha: isEditing && password.text.isEmpty
            ? initialUser!.senha
            : password.text,
        nome: name.text.trim(),
        documento: MockUsersRepository.normalizeDocument(document.text),
      );
      if (isEditing) {
        savedUser = await _repository.update(
          initialUser!.email,
          account,
          photoSourcePath: photo?.path,
        );
      } else {
        await _repository.register(account, photoSourcePath: photo?.path);
      }
      return true;
    } on DuplicateUserException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Não foi possível salvar o cadastro. Tente novamente.';
      return false;
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> deleteAccount() async {
    if (!isEditing || _disposed || isLoading || isPickingPhoto) return false;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repository.delete(initialUser!.email);
      return true;
    } catch (_) {
      error = 'Não foi possível excluir sua conta. Tente novamente.';
      return false;
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final field in [name, email, document, password, confirmation]) {
      field.dispose();
    }
    super.dispose();
  }
}
