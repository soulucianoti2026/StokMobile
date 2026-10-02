import 'package:flutter/material.dart';
import 'package:stokmobile/nativesplashPage.dart';
import 'package:stokmobile/NewProductPage/Page/new_product_page.dart';
import 'package:stokmobile/homepage/home_page.dart';

import 'package:stokmobile/loginpage/page/login_page.dart';
import 'package:stokmobile/productEditPage/page/product_edit_page.dart';
import 'package:stokmobile/productManager/page/product_manage_page.dart';
import 'package:stokmobile/productMovPage/product_mov_page.dart';
import 'package:stokmobile/productPage/product_page.dart';
import 'package:stokmobile/lostpasswordPage/lostpasword_page.dart';
import 'package:stokmobile/productmodel/products_model.dart';

abstract final class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    NativeSplashPage.route: (_) => const NativeSplashPage(),
    LoginPage.route: (_) => const LoginPage(),
    HomePage.route: (_) => const HomePage(),
    LostpaswordPage.route: (_) => const LostpaswordPage(),
    ProductPage.route: (context) => ProductPage(),
    ProductManagePage.route: (context) => ProductManagePage(),
    ProductMovPage.route: (context) => ProductMovPage(),
    ProductEditPage.route: (context) {
      final Product product =
          ModalRoute.of(context)!.settings.arguments as Product;
      return ProductEditPage(product: product);
    },
    NewProductPage.route: (context) => const NewProductPage(),
  };
}
