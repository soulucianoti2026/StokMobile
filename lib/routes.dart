import 'package:flutter/material.dart';
import 'package:stokmobile/productMovPage/product_mov_page.dart';

import 'loginPage/loginpage.dart';

abstract final class AppRoutes {
  static const login = '/';
  static const productMovPage = '/productMovPage';
  static const home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    productMovPage:(_) => const ProductMovPage(),
  
  };
}
