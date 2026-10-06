import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/loginpage/controllers/login_controller.dart';
import 'package:stokmobile/loginpage/page/login_page.dart';
import 'package:stokmobile/registerPage/controllers/controller.dart';
import 'package:stokmobile/registerPage/page/register_page.dart';
import 'package:stokmobile/shared/mocks/mock_users.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, this.controller});
  static const route = '/editar-perfil';
  final RegisterController? controller;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  RegisterController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final user = context.read<LoginController>().user;
    if (user == null) return;
    _controller =
        widget.controller ??
        RegisterController(
          initialUser: UsersMock(
            email: user.email,
            senha: user.senha,
            nome: user.nome,
            documento: user.documento,
            foto: user.foto,
          ),
        );
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar perfil')),
        body: SafeArea(
          child: Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                LoginPage.route,
                (_) => false,
              ),
              child: const Text('Entre na sua conta para editar o perfil'),
            ),
          ),
        ),
      );
    }
    return RegisterPage(
      controller: _controller,
      onProfileSaved: (profile) {
        context.read<LoginController>().updateProfile(profile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context);
      },
      onAccountDeleted: () {
        context.read<LoginController>().logout();
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginPage.route,
          (_) => false,
        );
      },
    );
  }
}
