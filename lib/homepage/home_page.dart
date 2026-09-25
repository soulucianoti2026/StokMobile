import 'package:flutter/material.dart';
import 'package:stokmobile/productMovPage/product_mov_page.dart';
import 'package:stokmobile/productPage/product_page.dart';
import 'package:stokmobile/shared/widgets/app_elavated_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, ProductMovPage.route);
            },
            label: 'Movimentacoes',
          ),
          AppElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, ProductPage.route);
            },
            label: 'Produtos',
          ),
        ],
      ),
    );
  }
}
