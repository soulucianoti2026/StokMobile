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
  List<Product> products = [];

  int pageViewIndex = 0;
  int selectedIndex = 0;
  ProductsViewState productsState = ProductsViewState.loading;

  void changeSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners(); // Avisa a interface que o botão selecionado mudou
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
      // O código agora lê o JSON e converte para a lista de forma instantânea
      products = productsJson.map((item) {
        return Product.fromJson(item);
      }).toList();

      changeproductsState(ProductsViewState.success);
    } catch (e) {
      changeproductsState(ProductsViewState.erros);
    }
  }
}
