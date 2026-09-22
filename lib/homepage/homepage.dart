import 'package:flutter/material.dart';

part '../shared/mocks/homepage.mock.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _HomepageController();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.neutral200,
                  ),
                  const SizedBox(height: 8),
                  const Text('Olá, Usuário', style: AppTypography.greeting),
                  const Text(
                    'Painel de controle geral',
                    style: AppTypography.input,
                  ),
                  const SizedBox(height: 12),
                  _SummaryGrid(controller: controller),
                  const SizedBox(height: 24),
                  _StockAlerts(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _HomeNavigation(controller: controller),
    );
  }
}
