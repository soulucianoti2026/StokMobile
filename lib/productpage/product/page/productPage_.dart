import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stokmobile/productpage/product/controllers/productControllers.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  static const String route = '/Product';

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Productcontrollers>().getproducts();
    });
  }

  int _selectedIndex = 2;

  // This list stores the screens for each tab
  final List<Widget> _screens = [
    Center(child: Text('inícia Screen')),
    Center(child: Text('Produtos Screen')),
    Center(child: Text('Mover Screen')),
    Center(child: Text('Histórico Screen')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
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
              Row(
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
                        onChanged: (valor) {
                          print('Filtrando resultados por: $valor');
                        },
                        onSubmitted: (valor) {
                          print('Executar chamada na API por: $valor');
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add_circle_outline_sharp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: productCrontroller.categoria.length,
                  itemBuilder: (context, index) {
                    final isSelected =
                        productCrontroller.selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(productCrontroller.categoria[index]),
                        selected: isSelected,
                        onSelected: (_) {
                          productCrontroller.changeSelectedIndex(index);
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (productCrontroller.productsState ==
                        ProductsViewState.erros) {
                      return const Center(
                        child: Text('Erro ao carregar os produtos.'),
                      );
                    }

                    if (productCrontroller.products.isEmpty) {
                      return const Center(
                        child: Text('Nenhum produto cadastrado.'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(3),
                      itemCount: productCrontroller.products.length,
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
                          child: Column(
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
                                      productCrontroller
                                          .products[index]
                                          .category,
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
                                    productCrontroller.products[index].code,
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
                                  Text(productCrontroller.products[index].name),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${productCrontroller.products[index].stock}  un',
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'R\$: ${productCrontroller.products[index].price.toString()} /un',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 10);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        fixedColor: Color(0xFF0D9488),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.border_all_sharp),
            activeIcon: Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFFECCFBF1),
              ),
              child: Icon(Icons.border_all_sharp),
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Produtos',
            activeIcon: Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFFECCFBF1),
              ),
              child: Icon(Icons.inbox_rounded),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync_alt),
            label: 'Mover',
            activeIcon: Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFFECCFBF1),
              ),
              child: Icon(Icons.sync_alt),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Histórico',
            activeIcon: Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFFECCFBF1),
              ),
              child: Icon(Icons.access_time),
            ),
          ),
        ],
      ),
    );
  }
}
