import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  // 1. Exigimos o currentIndex e a função onTap no construtor
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int)
  onTap; // 2. Variável para receber a função da tela principal

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Usa o valor que veio da tela principal
      type: BottomNavigationBarType.fixed,
      fixedColor: const Color(0xFF0D9488),
      onTap:
          onTap, // 3. Quando clicado, executa a função que a tela principal enviou
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.border_all_sharp),
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFECCFBF1),
            ),
            child: const Icon(Icons.border_all_sharp),
          ),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_2_rounded),
          label: 'Produtos',
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFECCFBF1),
            ),
            child: const Icon(Icons.inbox_rounded),
          ),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.sync_alt),
          label: 'Mover',
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFECCFBF1),
            ),
            child: const Icon(Icons.sync_alt),
          ),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time),
          label: 'Histórico',
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFECCFBF1),
            ),
            child: const Icon(Icons.access_time),
          ),
        ),
      ],
    );
  }
}
