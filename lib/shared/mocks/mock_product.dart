import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

// Notifica as telas após alterações no catálogo compartilhado.
final productsRevision = ValueNotifier<int>(0);

void notifyProductsChanged() => productsRevision.value++;

// Histórico demonstrativo: nomes e destinos representam o momento do registro.
final List<Map<String, dynamic>> productMovementsJson = [
  {
    'productCode': 'COD-001',
    'productName': 'Teclado Mecânico RGB',
    'type': 'exit',
    'quantity': 2,
    'date': '2026-10-02T14:30:00',
    'sector': 'Tecnologia da Informação',
    'costCenter': 'CC-001',
  },
  {
    'productCode': 'COD-002',
    'productName': 'Papel A4 Chamex 75g',
    'type': 'entry',
    'quantity': 10,
    'date': '2026-10-02T11:15:00',
  },
  {
    'productCode': 'COD-003',
    'productName': 'Detergente Líquido 5L',
    'type': 'exit',
    'quantity': 5,
    'date': '2026-10-01T16:45:00',
    'sector': 'Limpeza',
    'costCenter': 'CC-003',
  },
  {
    'productCode': 'COD-005',
    'productName': 'Mouse Óptico Sem Fio',
    'type': 'entry',
    'quantity': 50,
    'date': '2026-09-30T10:00:00',
  },
];

final List<Map<String, dynamic>> productsJson = [
  // =========================
  // ELETRÓNICOS
  // =========================
  {
    'code': 'COD-001', //[cite: 3, 4]
    'name': 'Teclado Mecânico RGB', //[cite: 3, 4]
    'imageUrl': '', // Pode substituir pelas imagens reais
    'price': 250.00, //[cite: 4]
    'stock': 1, //[cite: 4]
    'category': 'Eletrônicos', //[cite: 3, 4]
    'description':
        'Teclado mecânico com iluminação RGB e switches táteis.', //[cite: 3]
  },

  // =========================
  // ESCRITÓRIO
  // =========================
  {
    'code': 'COD-002', //[cite: 4]
    'name': 'Papel A4 Chamex 75g', //[cite: 4]
    'imageUrl': '',
    'price': 28.00, //[cite: 4]
    'stock': 3, //[cite: 4]
    'category': 'Escritório', //[cite: 4]
    'description':
        'Papel sulfite A4 de alta qualidade, ideal para impressões e fotocópias no dia a dia.',
  },

  // =========================
  // LIMPEZA
  // =========================
  {
    'code': 'COD-003', //[cite: 4]
    'name': 'Detergente Líquido 5L', //[cite: 4]
    'imageUrl': '',
    'price': 18.90, //[cite: 4]
    'stock': 15, //[cite: 4]
    'category': 'Limpeza', //[cite: 4]
    'description':
        'Detergente líquido de grande formato, excelente para uso profissional ou doméstico.',
  },

  // =========================
  // ALIMENTOS
  // =========================
  {
    'code': 'COD-004', //[cite: 4]
    'name': 'Café Torrado Moído 500g', //[cite: 4]
    'imageUrl': '',
    'price': 22.50, //[cite: 4]
    'stock': 200, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
  {
    'code': 'COD-004', //[cite: 4]
    'name': 'Café Torrado Moído 500g', //[cite: 4]
    'imageUrl': '',
    'price': 22.50, //[cite: 4]
    'stock': 45, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
  {
    'code': 'COD-004', //[cite: 4]
    'name': 'Café Torrado Moído 500g', //[cite: 4]
    'imageUrl': '',
    'price': 22.50, //[cite: 4]
    'stock': 45, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
  {
    'code': 'COD-004', //[cite: 4]
    'name': 'Café Torrado Moído 500g', //[cite: 4]
    'imageUrl': '',
    'price': 22.50, //[cite: 4]
    'stock': 45, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
];

/// A complete local snapshot, including photo bytes, survives app restarts.
class MockProductsRepository {
  MockProductsRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  static final instance = MockProductsRepository();
  static const storageKey = 'stokmobile.products.v1';
  final FlutterSecureStorage _storage;
  Future<void>? _pending;

  Future<void> load() async {
    final raw = await _storage.read(key: storageKey);
    if (raw == null) return;
    final saved = (jsonDecode(raw) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    productsJson
      ..clear()
      ..addAll(saved);
    notifyProductsChanged();
  }

  Future<void> save(Map<String, dynamic> product, {bool create = false}) {
    Future<void> write() async {
      final next = productsJson
          .map((p) => Map<String, dynamic>.from(p))
          .toList();
      final index = next.indexWhere((p) => p['code'] == product['code']);
      if (create) {
        if (index >= 0) throw StateError('Este código já existe');
        next.insert(0, product);
      } else {
        if (index < 0) throw StateError('Produto não encontrado');
        next[index] = {...next[index], ...product};
      }
      await _storage.write(key: storageKey, value: jsonEncode(next));
      productsJson
        ..clear()
        ..addAll(next);
      notifyProductsChanged();
    }

    final operation = _pending == null
        ? write()
        : _pending!.then((_) => write());
    final queued = operation.then<void>((_) {}, onError: (Object _) {});
    _pending = queued;
    queued.then((_) {
      if (identical(_pending, queued)) _pending = null;
    });
    return operation;
  }
}
