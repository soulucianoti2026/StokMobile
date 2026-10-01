import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/shared/Widget/button_new_product.dart';
import 'package:stokmobile/shared/Widget/button_search.dart';
import 'package:stokmobile/shared/Widget/list_view_horizontal.dart';
import 'package:stokmobile/shared/Widget/products_section.dart';
import 'package:stokmobile/shared/Widget/custom_bottom_nav_bar.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  static const String route = '/Product';

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _selectedIndex = 1;

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
      floatingActionButton: ButtonNewProduct(),
      appBar: AppBar(title: const Text('Produtos'), shadowColor: Colors.white),

      body: Container(
        color: Colors.grey.shade200,
        child: Consumer<Productcontrollers>(
          builder: (context, productCrontroller, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ButtonSearch(
                onChanged: (valor) {
                  productCrontroller.search(valor);
                },
              ),

              ListViewHorizontal(
                categoria: productCrontroller.categoria,
                selectedIndex: productCrontroller.selectedIndex,
                changeSelectedIndex: productCrontroller.changeSelectedIndex,
              ),

              if (productCrontroller.productsState == ProductsViewState.loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                products_section(
                  hasError:
                      productCrontroller.productsState ==
                      ProductsViewState.erros,
                  products: productCrontroller.products,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _selectedIndex),
    );
  }
}
