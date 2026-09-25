import 'package:flutter/material.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mock.dart';

enum ProductsViewState { loading, success, erros }

class Productcontrollers extends ChangeNotifier {
  List<String> categoria = [
    'Todos',
    'Estoque Baixo',
    'Eletrônicos',
    'Escritório',
  ];

  String _query = '';

  List<Product> _allProducts = [];

  List<Product> get products {
    List<Product> listaFiltrada = _allProducts;
    String categoriaSelecionada = categoria[selectedIndex];

    if (categoriaSelecionada != 'Todos') {
      listaFiltrada = _allProducts.where((product) {
        return product.category == categoriaSelecionada;
      }).toList();
    }

    if (_query.isEmpty) {
      return listaFiltrada;
    }

    final querySearch = _query.toLowerCase();
    return listaFiltrada.where((product) {
      return product.name.toLowerCase().contains(querySearch) ||
          product.code.toLowerCase().contains(querySearch);
    }).toList();
  }

  int pageViewIndex = 0;
  int selectedIndex = 0;
  ProductsViewState productsState = ProductsViewState.loading;

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

  Future<void> getproducts() async {
    try {
      _allProducts = productsJson.map((item) {
        return Product.fromJson(item);
      }).toList();

      changeproductsState(ProductsViewState.success);
    } catch (e) {
      changeproductsState(ProductsViewState.erros);
    }
  }
}
