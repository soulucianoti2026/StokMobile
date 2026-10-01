import 'package:flutter/material.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mock.dart';

enum ProductsViewState { loading, success, erros }

class Productcontrollers extends ChangeNotifier {
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
        return product.stock <= 5;
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
    _allProducts.removeWhere((element) => element.code == product.code);
    notifyListeners();
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
    Product findedProduct = _allProducts
        .where((element) => element.code == product.code)
        .first;
    _allProducts[_allProducts.indexOf(findedProduct)] = product;
    notifyListeners();
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
