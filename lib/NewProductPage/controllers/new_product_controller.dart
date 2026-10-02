import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mock.dart';

class NewProductController {
  String? salvar({
    required String nome,
    required String codigo,
    required String estoqueMinimo,
    required String valor,
    required int quantidade,
    required String categoria,
  }) {
    nome = nome.trim();
    codigo = codigo.trim().toUpperCase();
    estoqueMinimo = estoqueMinimo.trim();
    valor = valor.trim().replaceAll(',', '.');

    // Nome: só letras (maiúsculas e minúsculas) e espaço
    if (nome.isEmpty || !RegExp(r'^[a-zA-ZÀ-ÿ ]+$').hasMatch(nome)) {
      return 'O nome deve ter apenas letras e espaços';
    }

    // Código: 3 letras e 3 números (exemplo: ABC123)
    if (!RegExp(r'^[A-Z]{3}[0-9]{3}$').hasMatch(codigo)) {
      return 'O código deve ter 3 letras e 3 números (ex: ABC123)';
    }

    // Código não pode se repetir
    bool jaExiste = productsJson.any((p) => p['code'] == codigo);
    if (jaExiste) {
      return 'Este código já existe';
    }

    // Estoque mínimo (validado, mas o model ainda não guarda)
    if (int.tryParse(estoqueMinimo) == null) {
      return 'Informe o estoque mínimo';
    }

    // Valor unitário
    double? preco = double.tryParse(valor);
    if (preco == null || preco <= 0) {
      return 'Informe o valor unitário';
    }

    Product novoProduto = Product(
      code: codigo,
      name: nome,
      imageUrl: '',
      price: preco,
      stock: quantidade,
      category: categoria,
      description: '',
      isActive: true,
    );

    // A lista do mock é de mapas, então converte com toJson()
    productsJson.insert(0, novoProduto.toJson());

    return null;
  }
}
