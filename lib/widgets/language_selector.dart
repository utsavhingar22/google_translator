import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String language;
  final VoidCallback onTap;

  const LanguageSelector({super.key, required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(language.toUpperCase()),
    );
  }
}
