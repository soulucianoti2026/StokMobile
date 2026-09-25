import 'package:flutter/material.dart';

class ButtonNewProduct extends StatelessWidget {
  const ButtonNewProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488),
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add_circle_outline_sharp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
