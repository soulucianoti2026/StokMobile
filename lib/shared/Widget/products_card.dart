import 'package:stokmobile/shared/widgets/product_photo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/productEditPage/page/product_edit_page.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/productmodel/products_model.dart';

class ProductsCard extends StatelessWidget {
  const ProductsCard({super.key, required this.product});

  final Product product;

  Color _getBgColor(int stock) {
    if (stock <= 2) {
      return const Color(0xFFFEE2E2);
    } else if (stock <= 5) {
      return const Color(0xFFFEF9C3);
    } else {
      return const Color(0xFFECFDF5);
    }
  }

  Color _getTextColor(int stock) {
    if (stock <= 2) {
      return const Color(0xFFEF4444); //
    } else if (stock <= 5) {
      return const Color(0xFFD97706); //
    } else {
      return const Color(0xFF0D9488); //
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Ações do produto"),
              // content: const Text(
              //   'Escolha uma opção para o produto selecionado.',
              // ),
              content: ProductDialogContent(product: product),
              actions: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.grey),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Cancelar')],
                    ),
                  ),
                ),
                // ProductDialogContent(product: product),
              ],
            );
          },
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 10,
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
            const SizedBox(height: 8),
            Row(
              children: [
                if (product.imageUrl.isNotEmpty) ...[
                  ProductPhoto(photo: product.imageUrl, size: 48),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getBgColor(product.stock),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.stock} un',
                    style: TextStyle(
                      color: _getTextColor(product.stock),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'R\$ ${product.price.toStringAsFixed(2)} / un',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDialogContent extends StatelessWidget {
  const ProductDialogContent({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1.0, color: Color(0xFFE2E8F0)),
            color: Color(0xFFF8FAFC),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0D9488),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    product.code,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(
              context,
              ProductEditPage.route,
              arguments: product,
            );
          },
          child: Container(
            padding: EdgeInsets.all(6),
            // height: 110,
            // width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1.0, color: Color(0xFFCCFBF1)),
              color: Color(0xFFF0FDFA),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.only(right: 10),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),

                    color: Colors.white,
                  ),
                  child: Icon(Icons.edit_square, color: Color(0xFF0D9488)),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Editar cadastro',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Alterar nome, preço e informações do produto',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Excluir produto'),
                content: Text(
                  'Tem certeza de que deseja excluir o produto "${product.name}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Não'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Sim'),
                  ),
                ],
              ),
            );

            if (confirmed != true || !context.mounted) return;

            context.read<Productcontrollers>().deleteProduct(product);
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.all(6),
            // height: 110,
            // width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1.0, color: Color(0xFFFECACA)),
              color: Color(0xFFFEF2F2),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.only(right: 10),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),

                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.delete_outline_outlined,
                    color: Color(0xFFEF4444),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Excluir da base',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Remover o produto permanentemente do catálogo.',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // GestureDetector(
        //   onTap: () {},
        //   child: Container(
        //     padding: EdgeInsets.all(6),
        //     height: 110,
        //     width: double.infinity,
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(12),
        //       border: Border.all(width: 1.0, color: Color(0xFFFECACA)),
        //       color: Color(0xFFFEF2F2),
        //     ),
        //     child: Row(
        //       children: [
        //         Container(
        //           padding: EdgeInsets.all(6),
        //           height: 40,
        //           width: 40,
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(30),

        //             color: Colors.white,
        //           ),
        //           child: Icon(
        //             Icons.delete_outline_outlined,
        //             color: Color(0xFFEF4444),
        //           ),
        //         ),
        //         Spacer(),
        //         Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text('Excluir da base'),
        //             Text(
        //               'Remover o produto permanentemente\n'
        //               ' do catálogo.\n',
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // SizedBox(height: 12),
      ],
    );
  }
}
