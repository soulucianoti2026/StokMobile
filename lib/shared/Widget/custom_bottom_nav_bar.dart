import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stokmobile/shared/app_colors.dart';
import 'package:stokmobile/homepage/home_page.dart';
import 'package:stokmobile/productMovPage/product_mov_page.dart';
import 'package:stokmobile/productPage/product_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.figmaStyle = false,
  });

  final int currentIndex;
  final bool figmaStyle;

  @override
  Widget build(BuildContext context) {
    void navigate(int index) {
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
    }

    if (figmaStyle) {
      const names = ['home', 'products', 'move', 'history'];
      const labels = ['Início', 'Produtos', 'Mover', 'Histórico'];
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.slate200)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(4, (index) {
                  final selected = index == currentIndex;
                  return Expanded(
                    child: Semantics(
                      selected: selected,
                      button: true,
                      child: InkWell(
                        onTap: () => navigate(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.teal50 : null,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SvgPicture.asset(
                                'assets/images/movement/${names[index]}.svg',
                                width: 20,
                                height: 20,
                                excludeFromSemantics: true,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                height: 1.2,
                                letterSpacing: 0,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: selected
                                    ? AppColors.teal600
                                    : AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    }
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      fixedColor: const Color(0xFF0D9488),
      onTap: navigate,
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
