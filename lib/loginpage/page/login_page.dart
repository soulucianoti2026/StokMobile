import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/loginpage/login_controller.dart';
import 'package:stokmobile/lostpasswordPage/lostpasword_page.dart';
import 'package:stokmobile/routes.dart';
import 'package:stokmobile/shared/app_colors.dart';
import 'package:stokmobile/shared/exceptions/auth_exception.dart';
import 'package:stokmobile/shared/widgets/app_check_box.dart';
import 'package:stokmobile/shared/widgets/app_elavated_button.dart';
import 'package:stokmobile/shared/widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String route = '/login';

  InputDecoration _decoration({String? hint, Widget? suffixIcon}) {
    OutlineInputBorder borda(Color cor) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cor),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.slate400),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: borda(AppColors.slate200),
      enabledBorder: borda(AppColors.slate200),
      focusedBorder: borda(AppColors.teal600),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Consumer<LoginController>(
              builder: (context, controller, child) {
                return Form(
                  key: controller.key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoginHeader(),
                      const SizedBox(height: 32),
                      Text(
                        'E-mail corporativo',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.slate700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: AppColors.slate950),
                        decoration: _decoration(hint: 'exemplo@empresa.com'),
                        validator: (value) => controller.validateEmail(value),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Senha',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.slate700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                LostpaswordPage.route,
                              );
                            },
                            child: Text(
                              'Esqueceu?',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.teal600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: controller.senhaController,
                        obscureText: !controller.isPasswordVisible,
                        style: TextStyle(color: AppColors.slate950),
                        decoration: _decoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.slate400,
                            ),
                            onPressed: controller.changePasswordVisibility,
                          ),
                        ),
                        validator: (value) =>
                            controller.validatePassword(value),
                      ),
                      const SizedBox(height: 16),

                      AppCheckBox(
                        value: controller.isActiveCheckbox,
                        onChanged: (value) {
                          controller.changeAtivateCheckBox();
                        },
                        label: 'Manter-me contectado.',
                      ),

                      const SizedBox(height: 24),
                      //App button já está com animação do loading do login.
                      AppElevatedButton(
                        label: 'Entrar',
                        isLoading: controller.isLoading,
                        onPressed: () async {
                          try {
                            await controller.handleLogin();
                            Navigator.pushNamed(context, HomePage.route);
                          } on AuthException catch (e) {
                            if (!context.mounted) return;
                            AnimatedSnackBar.material(
                              e.message,
                              type: AnimatedSnackBarType.error,
                              mobileSnackBarPosition:
                                  MobileSnackBarPosition.bottom,
                            ).show(context);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
