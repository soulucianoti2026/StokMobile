import 'package:flutter/material.dart';
import 'package:stokmobile/productmodel/products_model.dart';

class products_card extends StatelessWidget {
  const products_card({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFECCFBF1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.category,
                style: const TextStyle(
                  color: Color(0xFF0D9488),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              product.code,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(product.name),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${product.stock}  un'),
            ),
            const Icon(Icons.arrow_forward_ios_rounded),
          ],
        ),
        Row(children: [Text('R\$: ${product.price.toString()} /un')]),
      ],
    );
  }
}
