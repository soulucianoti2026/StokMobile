import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';

// Importe os seus widgets personalizados aqui (ajuste os caminhos se necessário)
import 'package:stokmobile/shared/Widget/button_search.dart';
import 'package:stokmobile/shared/Widget/list_view_horizontal.dart';
import 'package:stokmobile/shared/Widget/products_section.dart';
import 'package:stokmobile/shared/Widget/button_new_product.dart';
import 'package:stokmobile/shared/Widget/custom_bottom_nav_bar.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  static const String route = '/Product';

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _selectedIndex = 2; // Mantendo o índice inicial da sua versão anterior

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Productcontrollers>().getproducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF0D9488),
          borderRadius: BorderRadius.circular(30),
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add_circle_outline_sharp, color: Colors.white),
        ),
      ),
      appBar: AppBar(title: const Text('Produtos'), shadowColor: Colors.white),

      body: Container(
        color: Colors.grey.shade200,
        child: Consumer<Productcontrollers>(
          builder: (context, productCrontroller, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Barra de Pesquisa
              ButtonSearch(
                onChanged: (valor) {
                  productCrontroller.search(valor);
                },
              ),

              // 2. Lista Horizontal de Categorias (Chips)
              ListViewHorizontal(
                categoria: productCrontroller.categoria,
                selectedIndex: productCrontroller.selectedIndex,
                changeSelectedIndex: productCrontroller.changeSelectedIndex,
              ),

              // 3. Verifica o estado de Loading (opcional, mas recomendado) e desenha a lista
              if (productCrontroller.productsState == ProductsViewState.loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                // Seção de Produtos (Card)
                products_section(
                  hasError:
                      productCrontroller.productsState ==
                      ProductsViewState.erros,
                  products: productCrontroller.products,
                ),

              // 4. Botão de Adicionar Novo Produto (O que ficava no canto inferior direito)
              // const ButtonNewProduct(),
            ],
          ),
        ),
      ),
      // 5. Barra de Navegação Inferior
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
