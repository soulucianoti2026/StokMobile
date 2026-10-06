import 'package:flutter/material.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

class NewProductController extends ChangeNotifier {
  final nome = TextEditingController();
  final sku = TextEditingController();
  final estoqueMinimo = TextEditingController(text: '3');
  final valor = TextEditingController();
  int quantidade = 10;
  String categoria = 'Eletrônicos';
  bool scanning = false;
  bool saving = false;
  String imageUrl = '';
  bool _disposed = false;
  String? error;

  NewProductController() {
    sku.addListener(_changed);
  }
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  List<String> get categorias => {
    'Eletrônicos',
    'Escritório',
    'Limpeza',
    'Alimentos',
    ...productsJson
        .map((p) => p['category'] as String? ?? '')
        .where((c) => c.isNotEmpty),
  }.toList();
  String? validateCode(String value) {
    final code = value.trim().toUpperCase();
    if (code.isEmpty) return 'Informe o código de barras ou SKU';
    if (code.length > 128 || !RegExp(r'^[A-Z0-9._/ -]+$').hasMatch(code)) {
      return 'Informe um código válido com até 128 caracteres';
    }
    if (productsJson.any(
      (p) => (p['code'] as String).trim().toUpperCase() == code,
    )) {
      return 'Este código já existe';
    }
    return null;
  }

  String? get codeMessage => sku.text.trim().isEmpty
      ? null
      : validateCode(sku.text) ??
            '✓ Código único disponível para uso corporativo';
  bool get codeAvailable =>
      sku.text.trim().isNotEmpty && validateCode(sku.text) == null;
  void changeQuantity(int delta) {
    if (quantidade + delta < 0) return;
    quantidade += delta;
    notifyListeners();
  }

  void selectCategory(String? value) {
    if (value == null) return;
    categoria = value;
    notifyListeners();
  }

  Future<void> scanBarcode(Future<String?> Function() scan) async {
    if (scanning || _disposed) return;
    scanning = true;
    error = null;
    notifyListeners();
    try {
      final result = await scan();
      if (!_disposed && result != null && result.trim().isNotEmpty) {
        sku.text = result.trim();
      }
    } catch (_) {
      if (!_disposed) {
        error =
            'Não foi possível ler o código. Tente novamente ou digite o SKU.';
      }
    } finally {
      if (!_disposed) {
        scanning = false;
        notifyListeners();
      }
    }
  }

  Future<bool> submit() async {
    if (saving) return false;
    saving = true;
    notifyListeners();
    try {
      error = await salvar(
        nome: nome.text,
        codigo: sku.text,
        estoqueMinimo: estoqueMinimo.text,
        valor: valor.text,
        quantidade: quantidade,
        categoria: categoria,
      );
    } catch (_) {
      error = 'Não foi possível salvar o produto. Tente novamente.';
    } finally {
      saving = false;
      if (!_disposed) notifyListeners();
    }
    return error == null;
  }

  Future<String?> salvar({
    required String nome,
    required String codigo,
    required String estoqueMinimo,
    required String valor,
    required int quantidade,
    required String categoria,
  }) async {
    nome = nome.trim();
    codigo = codigo.trim().toUpperCase();
    if (nome.isEmpty) return 'Informe o nome do produto';
    final codeError = validateCode(codigo);
    if (codeError != null) return codeError;
    final minimum = int.tryParse(estoqueMinimo.trim());
    if (minimum == null || minimum < 0) {
      return 'Informe um estoque mínimo inteiro e não negativo';
    }
    if (quantidade < 0) return 'A quantidade não pode ser negativa';
    if (!categorias.contains(categoria)) {
      return 'Selecione uma categoria válida';
    }
    var priceText = valor.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (priceText.contains(',')) {
      priceText = priceText.replaceAll('.', '').replaceAll(',', '.');
    }
    final price = double.tryParse(priceText);
    if (price == null || !price.isFinite || price <= 0) {
      return 'Informe um valor unitário maior que zero';
    }
    final product = Product(
      code: codigo,
      name: nome,
      imageUrl: imageUrl,
      price: price,
      stock: quantidade,
      minimumStock: minimum,
      category: categoria,
      description: '',
      isActive: true,
    );
    await MockProductsRepository.instance.save(product.toJson(), create: true);
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    sku.removeListener(_changed);
    for (final field in [nome, sku, estoqueMinimo, valor]) {
      field.dispose();
    }
    super.dispose();
  }
}
