import 'package:flutter/material.dart';
import 'package:stokmobile/productManager/page/product_manage_page.dart';
import 'package:stokmobile/productPage/product_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    ProductPage.route: (context) => ProductPage(),
    ProductManagePage.route: (context) => ProductManagePage(),
  };
}
