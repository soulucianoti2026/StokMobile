import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';

class ButtonSearch extends StatelessWidget {
  const ButtonSearch({super.key, required this.onChanged});
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar Produtos por nome...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: (valor) {},
            ),
          ),
        ),
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
        ),
      ],
    );
  }
}
