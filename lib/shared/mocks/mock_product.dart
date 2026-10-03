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
    'imageUrl':
        'https://i.postimg.cc/placeholder.png', // Pode substituir pelas imagens reais
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
    'imageUrl': 'https://i.postimg.cc/placeholder.png',
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
    'imageUrl': 'https://i.postimg.cc/placeholder.png',
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
    'imageUrl': 'https://i.postimg.cc/placeholder.png',
    'price': 22.50, //[cite: 4]
    'stock': 200, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
  {
    'code': 'COD-004', //[cite: 4]
    'name': 'Café Torrado Moído 500g', //[cite: 4]
    'imageUrl': 'https://i.postimg.cc/placeholder.png',
    'price': 22.50, //[cite: 4]
    'stock': 45, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
  {
    'code': 'COD-004', //[cite: 4]
    'name': 'Café Torrado Moído 500g', //[cite: 4]
    'imageUrl': 'https://i.postimg.cc/placeholder.png',
    'price': 22.50, //[cite: 4]
    'stock': 45, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
  {
    'code': 'COD-004', //[cite: 4]
    'name': 'Café Torrado Moído 500g', //[cite: 4]
    'imageUrl': 'https://i.postimg.cc/placeholder.png',
    'price': 22.50, //[cite: 4]
    'stock': 45, //[cite: 4]
    'category': 'Alimentos', //[cite: 4]
    'description':
        'Café torrado e moído com aroma intenso, perfeito para começar o dia.',
  },
];
