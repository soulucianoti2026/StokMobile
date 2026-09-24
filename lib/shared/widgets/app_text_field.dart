import 'package:flutter/material.dart';
import 'package:stokmobile/shared/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.controller,
  });

  //Segui o exemplo que o Professor ensinou em sala.
  final String hintText;

  final bool obscureText;

  final ValueChanged<String>? onChanged;

  final String? Function(String?)? validator;

  final TextEditingController? controller;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _textoEscondido = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _textoEscondido,
      onChanged: widget.onChanged,
      validator: widget.validator,
      style: TextStyle(color: AppColors.slate950),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: AppColors.slate400),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.teal600),
        ),

        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _textoEscondido ? Icons.visibility_outlined  : Icons.visibility_off_outlined,
                  color: AppColors.slate400,
                ),
                onPressed: () {
                  setState(() {
                    _textoEscondido = !_textoEscondido;
                  });
                },
              )
            : null,
      ),
    );
  }
}
