import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const StatusChip({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
  });

  factory StatusChip.fromStatus(String status) {
    Color bg = _bgColor(status);
    Color fg = _fgColor(status);
    return StatusChip(
      text: status,
      background: bg.withOpacity(0.12),
      foreground: fg,
    );
  }

  static Color _bgColor(String? s) {
    if (s == null) return Colors.grey.shade200;
    final n = _norm(s);
    if (n.contains('RETARD')) return const Color(0xFFFFCDD2);
    if (n.startsWith('TRAIT')) return const Color(0xFFC8E6C9);
    if (n.contains('ANNUL')) return const Color(0xFFF5F5F5);
    if (n.contains('EN') && n.contains('COURS')) return const Color(0xFFFFECB3);
    if (n.contains('NON') &&
        (n.contains('ACCOMPL') ||
            n.contains('EFFECTU') ||
            n.contains('REALIS')))
      return const Color(0xFFFFE0B2);
    return Colors.grey.shade200;
  }

  static Color _fgColor(String? s) {
    if (s == null) return Colors.grey.shade700;
    final n = _norm(s);
    if (n.contains('RETARD')) return const Color(0xFFC62828);
    if (n.startsWith('TRAIT')) return const Color(0xFF2E7D32);
    if (n.contains('ANNUL')) return const Color(0xFF424242);
    if (n.contains('EN') && n.contains('COURS')) return const Color(0xFFF57C00);
    if (n.contains('NON') &&
        (n.contains('ACCOMPL') ||
            n.contains('EFFECTU') ||
            n.contains('REALIS')))
      return const Color(0xFFEF6C00);
    return Colors.grey.shade700;
  }

  static String _norm(String s) => s
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
