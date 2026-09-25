import 'package:flutter/material.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/loginpage/login_page.dart';
import 'package:stokmobile/lostpasswordPage/lostpasword_page.dart';

abstract final class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const lostPassword = '/lost-password';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    home: (_) => const HomePage(),
    lostPassword: (_) => const LostpaswordPage(),
  };
}
