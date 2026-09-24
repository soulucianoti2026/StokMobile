import 'package:flutter/material.dart';
import 'package:stokmobile/shared/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.teal600,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowTeal60027,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'StokMobile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.slate950,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistema de Controle de Estoque',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.slate500),
        ),
      ],
    );
  }
}
