import 'package:stokmobile/shared/mocks/mock_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/loginpage/controllers/login_controller.dart';
import 'package:stokmobile/nativesplashPage.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await MockProductsRepository.instance.load();
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
          debugShowCheckedModeBanner: false,
          initialRoute: NativeSplashPage.route,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
