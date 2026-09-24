import 'package:flutter/material.dart';
import 'package:stokmobile/loginpage/model/user.dart';
import 'package:stokmobile/shared/exceptions/auth_exception.dart';
import 'package:stokmobile/shared/mocks/usuarios_mock.dart';

class LoginController extends ChangeNotifier {
  final RegExp _emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
  final RegExp _senhaRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  User? user;

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
    // simula o delay de uma chamada de API
    await Future.delayed(const Duration(seconds: 2));

    final email = emailController.text.trim().toLowerCase();
    final senha = senhaController.text.trim();

    for (final searchUser in usuariosMock) {
      if (searchUser.email == email && searchUser.senha == senha) {
        user = User(email: searchUser.email, senha: searchUser.senha);
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
