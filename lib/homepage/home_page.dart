import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/loginpage/login_controller.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/mocks/mock_product.dart';
import 'package:stokmobile/shared/Widget/custom_bottom_nav_bar.dart';

const int kEstoqueMinimoPadrao = 10;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  // Converte o productsJson (List<Map>) pra List<Product> usando o factory
  // que já existe no model. Considera só produtos ativos, já que agora
  // temos esse campo.
  List<Product> get _products => productsJson
      .map((json) => Product.fromJson(json))
      .where((p) => p.isActive)
      .toList();

  int get _totalProdutos => _products.length;

  double get _valorEstoque =>
      _products.fold<double>(0, (soma, p) => soma + p.stock * p.price);

  List<Product> get _produtosComEstoqueBaixo {
    final baixo = _products
        .where((p) => p.stock < kEstoqueMinimoPadrao)
        .toList();
    baixo.sort((a, b) => a.stock.compareTo(b.stock));
    return baixo;
  }

  // O User/mock só tem email e senha, sem campo de nome. Até existir um
  // campo de nome de verdade, derivo um nome de exibição a partir da parte
  // antes do @ do email (ex: 'bruno@gmail.com' -> 'Bruno').
  String _nomeExibicao(BuildContext context) {
    final user = context.watch<LoginController>().user;
    if (user == null || user.email.isEmpty) return 'Usuário';

    final parteAntesDoArroba = user.email.split('@').first;
    if (parteAntesDoArroba.isEmpty) return 'Usuário';

    return parteAntesDoArroba[0].toUpperCase() +
        parteAntesDoArroba.substring(1);
  }

  String _formatBRL(double valor) {
    // Formatação simples sem depender de pacote intl.
    final int inteiro = valor.round();
    final String str = inteiro.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return 'R\$ ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            _buildStatGrid(),
            const SizedBox(height: 24),
            _buildAlertsHeader(),
            const SizedBox(height: 12),
            ..._produtosComEstoqueBaixo.map(_buildAlertCard),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  // ---------- Header com avatar e saudação ----------
  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFD9DCE2), Color(0xFFC4C8D0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Olá, ${_nomeExibicao(context)}',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Painel de controle geral',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _StatCard(
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFF3D6BFF),
          iconBg: const Color(0xFFE8EDFF),
          value: '$_totalProdutos',
          label: 'Total de Produtos',
        ),
        _StatCard(
          icon: Icons.attach_money,
          iconColor: const Color(0xFF3D6BFF),
          iconBg: const Color(0xFFE8EDFF),
          value: _formatBRL(_valorEstoque),
          label: 'Valor do Estoque',
        ),
        // Entradas/Saídas, ainda não temos histórico de movimentação.
        _StatCard(
          icon: Icons.arrow_downward,
          iconColor: const Color(0xFF1DBE6B),
          iconBg: const Color(0xFFE4F8ED),
          value: '—',
          valueColor: const Color(0xFF1DBE6B),
          label: 'Entradas Hoje',
        ),
        _StatCard(
          icon: Icons.arrow_upward,
          iconColor: const Color(0xFFFF4D4D),
          iconBg: const Color(0xFFFFE9E9),
          value: '—',
          valueColor: const Color(0xFFFF4D4D),
          label: 'Saídas Hoje',
        ),
      ],
    );
  }

  // ---------- Cabeçalho da seção de alertas ----------
  Widget _buildAlertsHeader() {
    final count = _produtosComEstoqueBaixo.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Alertas de Estoque Baixo',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9E9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count ${count == 1 ? 'ALERTA' : 'ALERTAS'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF4D4D),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Card individual de alerta ----------
  Widget _buildAlertCard(Product p) {
    final int estoqueAtual = p.stock;
    final String nome = p.name;
    final ratio = estoqueAtual / kEstoqueMinimoPadrao;
    final bool critico = ratio <= 0.3;
    final Color iconBg = critico
        ? const Color(0xFFFFE9E9)
        : const Color(0xFFFFF4DE);
    final IconData icon = critico
        ? Icons.dangerous_outlined
        : Icons.warning_amber_rounded;
    final Color iconColor = critico
        ? const Color(0xFFFF4D4D)
        : const Color(0xFFF5A524);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEDF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    children: [
                      const TextSpan(text: 'Estoque atual: '),
                      TextSpan(
                        text: '$estoqueAtual',
                        style: const TextStyle(
                          color: Color(0xFFFF4D4D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' unidades (Mín: $kEstoqueMinimoPadrao)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

// ---------- Widget de card de estatística ----------
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final Color? valueColor;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEDF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
