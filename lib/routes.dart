import 'package:flutter/material.dart';
import 'package:stokmobile/loginPage/page/login_page.dart';
import 'package:stokmobile/productManager/page/product_manage_page.dart';
import 'package:stokmobile/productMovPage/product_mov_page.dart';
import 'package:stokmobile/productPage/product_page.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/lostpasswordPage/lostpasword_page.dart';

abstract final class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    LoginPage.route: (_) => const LoginPage(),
    HomePage.route: (_) => const HomePage(),
    LostpaswordPage.route: (_) => const LostpaswordPage(),
    ProductPage.route: (context) => ProductPage(),
    ProductManagePage.route: (context) => ProductManagePage(),
    ProductMovPage.route: (context) => ProductMovPage(),
  };
}
