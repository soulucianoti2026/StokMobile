import 'package:flutter/material.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/productMovPage/product_mov_page.dart';
import 'package:stokmobile/productPage/product_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      fixedColor: const Color(0xFF0D9488),
      onTap: (index) {
        // se clicar na aba que já está aberta, não faz nada
        if (index == currentIndex) return;

        if (index == 0) {
          Navigator.pushReplacementNamed(context, HomePage.route);
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, ProductPage.route);
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, ProductMovPage.route);
        } else {
          // Histórico ainda está em desenvolvimento
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Histórico em breve')));
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.border_all_sharp),
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFCCFBF1),
            ),
            child: const Icon(Icons.border_all_sharp),
          ),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_2_rounded),
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFCCFBF1),
            ),
            child: const Icon(Icons.inventory_2_rounded),
          ),
          label: 'Produtos',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.sync_alt),
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFCCFBF1),
            ),
            child: const Icon(Icons.sync_alt),
          ),
          label: 'Mover',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time),
          activeIcon: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFCCFBF1),
            ),
            child: const Icon(Icons.access_time),
          ),
          label: 'Histórico',
        ),
      ],
    );
  }
}
