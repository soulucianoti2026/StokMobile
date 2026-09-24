import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/productManager/product_manage_page.dart';
import 'package:stokmobile/productpage/product/controllers/productControllers.dart';

import 'package:stokmobile/productpage/product/page/productPage_.dart';
import 'package:stokmobile/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: AppRoutes.routes,
      home: const Scaffold(body: Center(child: HomeContent())),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return Productcontrollers();
          },
        ),
      ],
      child: MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: ProductPage.route,
      ),
    );
  }
}
