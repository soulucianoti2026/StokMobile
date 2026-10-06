import 'package:flutter/material.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

enum ProductsViewState { loading, success, erros }

class Productcontrollers extends ChangeNotifier {
  Productcontrollers() {
    productsRevision.addListener(getproducts);
  }

  @override
  void dispose() {
    productsRevision.removeListener(getproducts);
    super.dispose();
  }

  List<String> categoria = ['Todos', 'Estoque Baixo'];

  String _query = '';

  List<Product> _allProducts = [];

  List<Product> get products {
    List<Product> listaFiltrada = _allProducts;

    // Proteção: caso selectedIndex seja maior que a lista
    if (selectedIndex >= categoria.length) {
      selectedIndex = 0;
    }

    String categoriaSelecionada = categoria[selectedIndex];

    if (categoriaSelecionada == 'Estoque Baixo') {
      listaFiltrada = _allProducts.where((product) {
        return product.isActive && product.stock < product.minimumStock;
      }).toList();
    } else if (categoriaSelecionada != 'Todos') {
      listaFiltrada = _allProducts.where((product) {
        return product.category.toLowerCase() ==
            categoriaSelecionada.toLowerCase();
      }).toList();
    }

    if (_query.isNotEmpty) {
      final querySearch = _query.toLowerCase();
      listaFiltrada = listaFiltrada.where((product) {
        return product.name.toLowerCase().contains(querySearch) ||
            product.code.toLowerCase().contains(querySearch);
      }).toList();
    }

    List<Product> listaOrdenada = listaFiltrada.toList();

    listaOrdenada.sort((a, b) => a.stock.compareTo(b.stock));

    return listaOrdenada;
  }

  int pageViewIndex = 0;
  int selectedIndex = 0;
  ProductsViewState productsState = ProductsViewState.loading;

  void deleteProduct(Product product) {
    productsJson.removeWhere((element) => element['code'] == product.code);
    notifyProductsChanged();
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  void changeSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void changePageViewIndex(int index) {
    pageViewIndex = index;
    notifyListeners();
  }

  void changeproductsState(ProductsViewState state) {
    productsState = state;
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await MockProductsRepository.instance.save(product.toJson());
  }

  Future<void> getproducts() async {
    try {
      _allProducts = productsJson.map((item) {
        return Product.fromJson(item);
      }).toList();

      Set<String> categoriasUnicas = _allProducts
          .map((p) => p.category)
          .toSet();

      categoria = ['Todos', 'Estoque Baixo', ...categoriasUnicas];

      changeproductsState(ProductsViewState.success);
    } catch (e) {
      changeproductsState(ProductsViewState.erros);
    }
  }
}
