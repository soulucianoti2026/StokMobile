import 'package:flutter/material.dart';
import 'package:stokmobile/shared/wigdets/app_elevated_button.dart';

class ProductMovPage extends StatelessWidget {
  const ProductMovPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Movimentação', style: TextStyle(fontSize: 24)),
            Text(
              'Registrar entrada ou saída de produto',
              style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Localizar produto
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Text(
                    'Localizar Produto por Texto',
                    style: TextStyle(fontSize: 17, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Selecionar Produto',
                style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
              ),

              const SizedBox(height: 6),

              // Selecionar produto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF475569)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teclado Mecânico RGB',
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            'Estoque Atual Disponível 1 un',
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Operação de Movimento',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 6),

              // Entrada / Saída
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 37,
                        child: Center(
                          child: Text(
                            'Entrada(+)',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 37,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFFEE2E2),
                        ),
                        child: const Center(
                          child: Text(
                            'Saída(-)',
                            style: TextStyle(fontSize: 17, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Quantidade a Movimentar',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 6),

              // Quantidade
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Text(
                    '5',
                    style: TextStyle(fontSize: 17, color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Erro
              Container(
                width: double.infinity,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text(
                      'Estoque insuficiente para efetuar esta saída',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text('Data do Registro', style: TextStyle(fontSize: 16)),

              const SizedBox(height: 6),

              // Data
              Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        '12/10/2026 (Hoje - Automático)',
                        style: TextStyle(color: Color(0xFF475569)),
                      ),
                      Spacer(),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF475569),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botão
              AppElevatedButton(
                label: 'Registrar Movimento',
                type: ButtonType.outlined,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
