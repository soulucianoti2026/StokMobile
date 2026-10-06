import 'package:stokmobile/shared/widgets/product_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stokmobile/NewProductPage/controllers/new_product_controller.dart';
import 'package:stokmobile/NewProductPage/Page/barcode_scanner_page.dart';
import 'package:stokmobile/shared/app_colors.dart';
import 'package:stokmobile/shared/wigdets/app_elevated_button.dart';

class NewProductPage extends StatefulWidget {
  const NewProductPage({super.key, this.scanBarcode});
  static const route = '/NewProduct';
  final Future<String?> Function()? scanBarcode;
  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final controller = NewProductController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  TextStyle _style(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: weight,
    color: color ?? AppColors.slate950,
  );
  Widget _icon(String name, double size) => SvgPicture.asset(
    'assets/images/new_product/$name.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: _style(13, weight: FontWeight.w600, color: AppColors.slate600),
      ),
      const SizedBox(height: 6),
      child,
    ],
  );
  InputDecoration _decoration({
    Widget? suffix,
    String? prefix,
  }) => InputDecoration(
    constraints: const BoxConstraints(minHeight: 44),
    filled: true,
    fillColor: AppColors.white,
    isDense: true,
    prefixText: prefix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    suffixIcon: suffix,
    suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 42),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.slate200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.teal600),
    ),
  );
  Widget _row(List<Widget> children) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      if (constraints.maxWidth < 280 * scale) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [children[0], const SizedBox(height: 12), children[1]],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 12),
          Expanded(child: children[1]),
        ],
      );
    },
  );
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (await controller.submit() && mounted) Navigator.pop(context, true);
  }

  Future<void> _scan() async {
    FocusScope.of(context).unfocus();
    await controller.scanBarcode(
      widget.scanBarcode ??
          () => Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
          ),
    );
  }

  Widget _stepper() => Container(
    constraints: const BoxConstraints(minHeight: 44),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.slate200),
    ),
    child: Row(
      children: [
        _stepButton(false),
        Expanded(
          child: Text(
            '${controller.quantidade}',
            textAlign: TextAlign.center,
            style: _style(14, weight: FontWeight.w700),
          ),
        ),
        _stepButton(true),
      ],
    ),
  );
  Widget _stepButton(bool add) => Container(
    decoration: BoxDecoration(
      border: Border(
        left: add ? BorderSide(color: AppColors.slate200) : BorderSide.none,
        right: add ? BorderSide.none : BorderSide(color: AppColors.slate200),
      ),
    ),
    child: IconButton(
      tooltip: add ? 'Aumentar quantidade' : 'Diminuir quantidade',
      constraints: const BoxConstraints(minWidth: 36, minHeight: 42),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: !add && controller.quantidade == 0
          ? null
          : () => controller.changeQuantity(add ? 1 : -1),
      icon: Text(
        add ? '+' : '-',
        style: _style(18, weight: FontWeight.w600, color: AppColors.slate600),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ),
    child: Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 24).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: IconButton(
                                tooltip: 'Voltar',
                                onPressed: () => Navigator.pop(context),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  padding: EdgeInsets.zero,
                                  side: BorderSide(color: AppColors.slate200),
                                ),
                                icon: _icon('back', 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Novo Produto',
                                    style: _style(20, weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cadastre um item no inventário',
                                    style: _style(
                                      13,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ProductPhotoPicker(
                          photo: controller.imageUrl,
                          enabled: !controller.saving,
                          onChanged: (photo) =>
                              setState(() => controller.imageUrl = photo),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'Nome do Produto',
                          TextField(
                            controller: controller.nome,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            style: _style(14),
                            decoration: _decoration(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _field(
                          'Código de barras / SKU',
                          TextField(
                            controller: controller.sku,
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            style: _style(14),
                            decoration: _decoration(
                              suffix: IconButton(
                                tooltip: 'Escanear código de barras',
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 42,
                                ),
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: controller.scanning ? null : _scan,
                                icon: _icon('barcode', 20),
                              ),
                            ),
                          ),
                        ),
                        if (controller.codeMessage != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            controller.codeMessage!,
                            style: _style(
                              11,
                              color: controller.codeAvailable
                                  ? AppColors.teal600
                                  : AppColors.red500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _field(
                          'Categoria',
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                value: controller.categoria,
                                isExpanded: true,
                                style: _style(14),
                                icon: _icon('chevron', 16),
                                items: controller.categorias
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(
                                          category,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: controller.selectCategory,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _row([
                          _field('Qtd Inicial', _stepper()),
                          _field(
                            'Estoque Mínimo',
                            TextField(
                              controller: controller.estoqueMinimo,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: _style(14),
                              decoration: _decoration(),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _field(
                          'Valor Unitário (R\$)',
                          TextField(
                            controller: controller.valor,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _save(),
                            style: _style(14),
                            decoration: _decoration(prefix: 'R\$ '),
                          ),
                        ),
                        if (controller.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                controller.error!,
                                style: _style(13, color: AppColors.red500),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _row([
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.slate600,
                            minimumSize: const Size.fromHeight(48),
                            side: BorderSide(color: AppColors.slate200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: _style(
                              14,
                              weight: FontWeight.w600,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
                        AppElevatedButton(
                          label: 'Salvar Produto',
                          type: ButtonType.filled,
                          backgroundColor: AppColors.teal600,
                          elevation: 0,
                          textStyle: _style(
                            14,
                            weight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                          onPressed: controller.saving ? null : _save,
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
