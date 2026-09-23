import 'package:flutter/material.dart';

import 'homePage/homepage.dart';
import 'loginPage/loginpage.dart';

abstract final class AppRoutes {
  static const login = '/';
  static const home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    home: (_) => const Homepage(),
  };
}
