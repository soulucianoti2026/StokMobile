// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

enum MovementOperation { entry, exit }

class ProductMovController extends ChangeNotifier {
  ProductMovController({List<Map<String, dynamic>>? source})
    : _source = source ?? productsJson {
    selectedIndex = _source.indexWhere((item) => item['isActive'] != false);
  }

  final List<Map<String, dynamic>> _source;
  late int selectedIndex;
  MovementOperation operation = MovementOperation.exit;
  String quantityText = '5';

  List<Product> get products => _source.map(Product.fromJson).toList();
  Product? get selectedProduct =>
      selectedIndex < 0 ? null : Product.fromJson(_source[selectedIndex]);
  int? get quantity => int.tryParse(quantityText);

  String? get error {
    final product = selectedProduct;
    if (product == null) return 'Selecione um produto para movimentar';
    if (quantity == null || quantity! <= 0) {
      return 'Informe uma quantidade inteira maior que zero';
    }
    if (operation == MovementOperation.exit && quantity! > product.stock) {
      return 'Estoque insuficiente para efetuar esta saída';
    }
    return null;
  }

  void selectProduct(int index) {
    if (index < 0 ||
        index >= _source.length ||
        _source[index]['isActive'] == false) {
      return;
    }
    selectedIndex = index;
    notifyListeners();
  }

  void setOperation(MovementOperation value) {
    operation = value;
    notifyListeners();
  }

  void setQuantity(String value) {
    quantityText = value;
    notifyListeners();
  }

  bool register() {
    if (error != null) return false;
    final delta = operation == MovementOperation.entry ? quantity! : -quantity!;
    _source[selectedIndex]['stock'] = selectedProduct!.stock + delta;
    if (identical(_source, productsJson)) {
      productMovementsJson.add({
        'productCode': selectedProduct!.code,
        'productName': selectedProduct!.name,
        'type': operation == MovementOperation.entry ? 'entry' : 'exit',
        'quantity': quantity!,
        'date': DateTime.now().toIso8601String(),
      });
      notifyProductsChanged();
    }
    quantityText = '';
    notifyListeners();
    return true;
  }
}
