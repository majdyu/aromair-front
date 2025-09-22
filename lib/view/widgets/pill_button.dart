import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  const PillButton({super.key, required this.text, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1E40AF);
    return Material(
      color: c,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: DefaultTextStyle(
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
