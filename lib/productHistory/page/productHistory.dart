// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stokmobile/productHistory/controllers/controller.dart';
import 'package:stokmobile/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:stokmobile/shared/app_colors.dart';

class ProductHistoryPage extends StatefulWidget {
  const ProductHistoryPage({super.key});
  static const route = '/historico';

  @override
  State<ProductHistoryPage> createState() => _ProductHistoryPageState();
}

class _ProductHistoryPageState extends State<ProductHistoryPage> {
  final _controller = ProductHistoryController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _style(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: weight,
    color: color ?? AppColors.slate950,
  );

  Widget _filter<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) => Container(
    constraints: const BoxConstraints(minHeight: 36),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.slate200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        isDense: true,
        hint: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(12, color: AppColors.slate600),
        ),
        style: _style(12, color: AppColors.slate600),
        icon: SvgPicture.asset(
          'assets/images/history/chevron.svg',
          width: 14,
          height: 14,
        ),
        items: items,
        selectedItemBuilder: (context) => [
          for (final item in items)
            Align(
              alignment: Alignment.centerLeft,
              child: item.value == null
                  ? Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : item.child,
            ),
        ],
        onChanged: onChanged,
      ),
    ),
  );

  Widget _card(ProductMovement movement) {
    final color = movement.isExit ? AppColors.red500 : AppColors.emerald500;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _style(14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _controller.dateLabel(movement.date),
                  style: _style(11, color: AppColors.slate400),
                ),
                if (movement.isExit) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Destino: ${movement.destinationLabel.isEmpty ? 'Não informado' : movement.destinationLabel}',
                    style: _style(11, color: AppColors.slate600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: movement.isExit
                      ? AppColors.red100
                      : AppColors.emerald100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  movement.typeLabel,
                  style: _style(12, color: color, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                movement.quantityLabel,
                style: _style(13, weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ),
    child: Scaffold(
      backgroundColor: AppColors.slate50,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            final movements = _controller.movements;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico',
                          style: _style(20, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Registro de movimentações passadas',
                          style: _style(13, color: AppColors.slate600),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _filter<String>(
                                label: 'Filtrar Produto',
                                value: _controller.productCode,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Todos os produtos'),
                                  ),
                                  for (final product
                                      in _controller.products.entries)
                                    DropdownMenuItem(
                                      value: product.key,
                                      child: Text(
                                        product.value,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                                onChanged: _controller.filterProduct,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _filter<HistoryMovementType>(
                                label: 'Tipo: Todas',
                                value: _controller.type,
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('Tipo: Todas'),
                                  ),
                                  DropdownMenuItem(
                                    value: HistoryMovementType.entry,
                                    child: Text('Tipo: Entrada'),
                                  ),
                                  DropdownMenuItem(
                                    value: HistoryMovementType.exit,
                                    child: Text('Tipo: Saída'),
                                  ),
                                ],
                                onChanged: _controller.filterType,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (movements.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _controller.emptyMessage,
                          textAlign: TextAlign.center,
                          style: _style(14, color: AppColors.slate600),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverList.separated(
                      itemCount: movements.length,
                      itemBuilder: (context, index) => _card(movements[index]),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
