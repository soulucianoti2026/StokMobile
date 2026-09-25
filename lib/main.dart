import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/productPage/product_page.dart';

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
