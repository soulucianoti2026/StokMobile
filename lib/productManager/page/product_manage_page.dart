import 'package:flutter/material.dart';
import 'package:stokmobile/NewProductPage/Page/new_product_page.dart';

/// Compatibilidade para os acessos existentes ao cadastro de produto.
class ProductManagePage extends StatelessWidget {
  const ProductManagePage({super.key});
  static const route = '/productManage';
  @override
  Widget build(BuildContext context) => const NewProductPage();
}
