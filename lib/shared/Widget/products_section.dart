import 'package:flutter/material.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/Widget/products_card.dart';

class products_section extends StatelessWidget {
  const products_section({
    super.key,
    required this.hasError,
    required this.products,
  });
  final bool hasError;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Builder(
        builder: (context) {
          if (hasError) {
            return const Center(child: Text('Erro ao carregar os produtos.'));
          }

          if (products.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(3),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.all(6),
                height: 92,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 1.0),
                  color: Colors.white,
                ),
                child: products_card(product: products[index]),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 10);
            },
          );
        },
      ),
    );
  }
}
