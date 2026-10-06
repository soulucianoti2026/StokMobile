import 'package:flutter/material.dart';
import 'package:stokmobile/NewProductPage/Page/new_product_page.dart';

class ButtonNewProduct extends StatelessWidget {
  const ButtonNewProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488),
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, NewProductPage.route);
        },
        icon: const Icon(Icons.add_circle_outline_sharp, color: Colors.white),
      ),
    );
  }
}
