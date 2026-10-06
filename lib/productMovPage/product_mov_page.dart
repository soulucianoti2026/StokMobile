import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stokmobile/productMovPage/controllers/productMovePage_controller.dart';
import 'package:stokmobile/shared/app_colors.dart';
import 'package:stokmobile/shared/widgets/app_elevated_button.dart';
import 'package:stokmobile/shared/widgets/custom_bottom_nav_bar.dart';

class ProductMovPage extends StatefulWidget {
  const ProductMovPage({super.key});

  static const String route = '/movimentacoes';

  @override
  State<ProductMovPage> createState() => _ProductMovPageState();
}

class _ProductMovPageState extends State<ProductMovPage> {
  final _controller = ProductMovController();
  final _quantity = TextEditingController(text: '5');
  bool _showValidation = true;

  @override
  void dispose() {
    _controller.dispose();
    _quantity.dispose();
    super.dispose();
  }

  TextStyle _style(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: weight,
    color: color ?? AppColors.slate600,
  );

  Widget _icon(String name, double size) => SvgPicture.asset(
    'assets/images/movement/$name.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: _style(13)),
      const SizedBox(height: 6),
      child,
    ],
  );

  Future<void> _selectProduct() async {
    var query = '';
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.slate50,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, updateSheet) {
          final products = _controller.products;
          final indices = List.generate(products.length, (index) => index)
              .where(
                (index) =>
                    products[index].isActive &&
                    '${products[index].name} ${products[index].code}'
                        .toLowerCase()
                        .contains(query.toLowerCase()),
              )
              .toList();
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selecionar Produto',
                      style: _style(
                        20,
                        color: AppColors.slate950,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      autofocus: true,
                      onChanged: (value) => updateSheet(() => query = value),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nome ou código',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: indices.isEmpty
                          ? const Center(
                              child: Text('Nenhum produto encontrado'),
                            )
                          : ListView.builder(
                              itemCount: indices.length,
                              itemBuilder: (context, position) {
                                final index = indices[position];
                                final product = products[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    product.name,
                                    style: _style(
                                      14,
                                      color: AppColors.slate950,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${product.code} • Estoque: ${product.stock} un',
                                  ),
                                  trailing: index == _controller.selectedIndex
                                      ? Icon(
                                          Icons.check,
                                          color: AppColors.teal600,
                                        )
                                      : null,
                                  onTap: () =>
                                      Navigator.pop(sheetContext, index),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (!mounted || selected == null) return;
    _controller.selectProduct(selected);
  }

  void _register() {
    setState(() => _showValidation = true);
    if (!_controller.register()) return;
    _quantity.clear();
    setState(() => _showValidation = false);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimentação registrada com sucesso')),
    );
  }

  Widget _operation(MovementOperation operation, String label) {
    final selected = _controller.operation == operation;
    final exit = operation == MovementOperation.exit;
    final color = exit ? AppColors.red500 : AppColors.teal600;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _controller.setOperation(operation),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? (exit ? AppColors.red100 : AppColors.teal50)
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: selected
                  ? Border.all(
                      color: exit ? AppColors.red300 : AppColors.teal600,
                    )
                  : null,
            ),
            child: Text(
              label,
              style: _style(
                14,
                color: selected ? color : AppColors.slate600,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.slate50,
      ),
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              final product = _controller.selectedProduct;
              final error = _showValidation ? _controller.error : null;
              final now = DateTime.now();
              final date =
                  '${now.day.toString().padLeft(2, '0')}/'
                  '${now.month.toString().padLeft(2, '0')}/${now.year}';
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Movimentação',
                      style: _style(
                        20,
                        color: AppColors.slate950,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Registrar entrada ou saída de produto',
                      style: _style(13, weight: FontWeight.w400),
                    ),
                    const SizedBox(height: 28),
                    _field(
                      'Selecionar Produto',
                      Material(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.slate200),
                        ),
                        child: InkWell(
                          onTap: _selectProduct,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product?.name ?? 'Selecionar Produto',
                                        style: _style(
                                          14,
                                          color: AppColors.slate950,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (product != null)
                                        Text(
                                          'Estoque Atual Disponível: ${product.stock} un',
                                          style: _style(
                                            12,
                                            color: product.stock <= 3
                                                ? AppColors.red500
                                                : AppColors.teal600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _icon('chevron', 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _field(
                      'Operação de Movimentação',
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.slate200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _operation(MovementOperation.entry, 'Entrada (+)'),
                            _operation(MovementOperation.exit, 'Saída (-)'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _field(
                      'Quantidade a movimentar',
                      TextField(
                        controller: _quantity,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() => _showValidation = true);
                          _controller.setQuantity(value);
                        },
                        style: _style(
                          14,
                          color: error != null
                              ? AppColors.red500
                              : AppColors.slate950,
                          weight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Informe a quantidade',
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: error != null
                                  ? AppColors.red500
                                  : AppColors.slate200,
                              width: error != null ? 1.5 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: error != null
                                  ? AppColors.red500
                                  : AppColors.teal600,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red100,
                          border: Border.all(color: AppColors.red300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _icon('alert', 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  error,
                                  style: _style(12, color: AppColors.red500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _field(
                      'Data do Registro',
                      Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.slate200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$date (Hoje - Automático)',
                                style: _style(14, weight: FontWeight.w400),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _icon('calendar', 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppElevatedButton(
                      label: 'Registrar Movimentação',
                      type: ButtonType.filled,
                      backgroundColor: AppColors.teal600,
                      textStyle: _style(14, color: AppColors.white),
                      elevation: 0,
                      onPressed: _register,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      ),
    );
  }
}
