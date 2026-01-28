import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final Function(String) onChanged;
  final TextInputType keyboardType;

  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      obscureText: obscure,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        hintText: hint,
      ),
    );
  }
}
