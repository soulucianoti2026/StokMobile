import 'package:flutter/material.dart';

class ListViewHorizontal extends StatelessWidget {
  ListViewHorizontal({
    super.key,
    required this.selectedIndex,
    required this.changeSelectedIndex,
    required this.categoria,
  });
  final List<String> categoria;
  final int selectedIndex;
  final void Function(int) changeSelectedIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: categoria.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(categoria[index]),
              selected: isSelected,
              onSelected: (_) {
                changeSelectedIndex(index);
              },
            ),
          );
        },
      ),
    );
  }
}
