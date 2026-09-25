import 'package:flutter/material.dart';

class LostpasswordController extends ChangeNotifier {
  LostpasswordController({this.sendInstructions});

  // Conectar ao serviço de recuperação quando a API estiver disponível.
  final Future<void> Function(String email)? sendInstructions;
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _disposed = false;
  bool _hasError = false;
  String? _message;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get message => _message;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail corporativo.';
    if (!RegExp(r'^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$').hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  void clearMessage() {
    if (_message == null) return;
    _message = null;
    _hasError = false;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_disposed || _isLoading) return;
    clearMessage();
    if (!(formKey.currentState?.validate() ?? false)) return;
    final send = sendInstructions;
    if (send == null) {
      _hasError = true;
      _message = 'O serviço de recuperação de senha ainda não está disponível.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await send(emailController.text.trim());
      if (_disposed) return;
      _message =
          'Se o e-mail estiver cadastrado, você receberá as instruções de redefinição.';
    } catch (_) {
      if (_disposed) return;
      _hasError = true;
      _message = 'Não foi possível enviar as instruções. Tente novamente.';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void backToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  void dispose() {
    _disposed = true;
    emailController.dispose();
    super.dispose();
  }
}
