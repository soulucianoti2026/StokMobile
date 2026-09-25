import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stokmobile/productPage/controllers/product_controllers.dart';

import 'package:stokmobile/routes.dart';
import 'package:stokmobile/loginpage/login_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return LoginController();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return Productcontrollers();
          },
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'StokMobile',
          theme: ThemeData(primarySwatch: Colors.teal),
          initialRoute: AppRoutes.login,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
