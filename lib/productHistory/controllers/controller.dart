import 'package:flutter/foundation.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';

enum HistoryMovementType { entry, exit }

@immutable
class ProductMovement {
  const ProductMovement({
    required this.productCode,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.sector,
    this.costCenter,
  });

  factory ProductMovement.fromJson(Map<String, dynamic> json) =>
      ProductMovement(
        productCode: json['productCode'] as String,
        productName: json['productName'] as String,
        type: json['type'] == 'exit'
            ? HistoryMovementType.exit
            : HistoryMovementType.entry,
        quantity: json['quantity'] as int,
        date: DateTime.parse(json['date'] as String),
        sector: json['sector'] as String?,
        costCenter: json['costCenter'] as String?,
      );

  final String productCode;
  final String productName;
  final HistoryMovementType type;
  final int quantity;
  final DateTime date;
  final String? sector;
  final String? costCenter;

  bool get isExit => type == HistoryMovementType.exit;
  String get typeLabel => isExit ? 'Saída' : 'Entrada';
  String get quantityLabel => '${isExit ? '-' : '+'}$quantity un';
  String get destinationLabel => [
    if (sector != null && sector!.isNotEmpty) sector!,
    if (costCenter != null && costCenter!.isNotEmpty) costCenter!,
  ].join(' • ');
}

class ProductHistoryController extends ChangeNotifier {
  ProductHistoryController({
    List<Map<String, dynamic>>? source,
    DateTime Function()? now,
  }) : _records = (source ?? productMovementsJson)
           .map(ProductMovement.fromJson)
           .toList(),
       _now = now ?? DateTime.now;

  final List<ProductMovement> _records;
  final DateTime Function() _now;
  String? _productCode;
  HistoryMovementType? _type;
  String? get productCode => _productCode;
  HistoryMovementType? get type => _type;
  Map<String, String> get products => {
    for (final record in _records) record.productCode: record.productName,
  };

  List<ProductMovement> get movements {
    final result = _records
        .where(
          (record) =>
              (_productCode == null || record.productCode == _productCode) &&
              (_type == null || record.type == _type),
        )
        .toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  String get emptyMessage => _records.isEmpty
      ? 'Nenhuma movimentação registrada'
      : 'Nenhuma movimentação para os filtros selecionados';

  void filterProduct(String? value) {
    _productCode = value;
    notifyListeners();
  }

  void filterType(HistoryMovementType? value) {
    _type = value;
    notifyListeners();
  }

  String dateLabel(DateTime value) {
    final date = value.toLocal();
    final now = _now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final time = '${_two(date.hour)}:${_two(date.minute)}';
    if (day == today) return 'Hoje, $time';
    if (day == DateTime(today.year, today.month, today.day - 1)) {
      return 'Ontem, $time';
    }
    return '${_two(date.day)}/${_two(date.month)}/${date.year}, $time';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
