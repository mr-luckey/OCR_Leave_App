import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool readOnly;
  final String? Function(String?)? validator;
  final int maxLines;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.readOnly = false,
    this.validator,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
          readOnly: readOnly,
          validator: validator,
          maxLines: maxLines,
        ),
      ),
    );
  }
}
