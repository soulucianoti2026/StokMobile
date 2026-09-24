import 'package:flutter/material.dart';
import 'package:stokmobile/productManager/product_manage_page.dart';
import 'package:stokmobile/productpage/product/page/productPage_.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    ProductPage.route: (context) => ProductPage(),
    ProductManagePage.route: (context) => ProductManagePage(),
  };
}
