part of '../../homepage/homepage.dart';

// Immutable local fixtures. Values are cents, quantities are units.
class _Product {
  const _Product(
    this.id,
    this.name,
    this.quantity,
    this.minimum,
    this.priceCents,
  );
  final String id;
  final String name;
  final int quantity;
  final int minimum;
  final int priceCents;
  bool get lowStock => quantity < minimum;
  bool get critical => quantity <= 1;
}

class _StockMovement {
  const _StockMovement(this.productId, this.quantity);
  final String productId;
  final int quantity;
}

abstract final class _HomepageMock {
  static final List<_Product> products = List.unmodifiable([
    const _Product('TEC-001', 'Teclado Mecânico RGB', 1, 5, 25000),
    const _Product('PAP-001', 'Papel A4 Chamex 75g', 3, 10, 2500),
    const _Product('CAB-001', 'Cabo HDMI 2.0 Ultra', 2, 8, 3500),
    for (var i = 1; i <= 138; i++)
      _Product(
        'INS-${i.toString().padLeft(3, '0')}',
        'Insumo de escritório ${i.toString().padLeft(3, '0')}',
        10,
        5,
        3200,
      ),
    const _Product('ORG-001', 'Caixa organizadora', 25, 5, 2900),
  ]);

  // Demonstration snapshot: movements for the simulated current day.
  static const todayMovements = [
    _StockMovement('INS-001', 7),
    _StockMovement('INS-002', 5),
    _StockMovement('PAP-001', -3),
    _StockMovement('CAB-001', -5),
  ];
}
