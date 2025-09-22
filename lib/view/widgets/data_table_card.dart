import 'package:flutter/material.dart';

class DataTableCard extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final List<int>? columnFlex;
  const DataTableCard({
    super.key,
    required this.headers,
    required this.rows,
    this.columnFlex,
  });

  @override
  Widget build(BuildContext context) {
    final flex = columnFlex ?? List.generate(headers.length, (_) => 1);

    Widget header = Row(
      children: [
        for (int i = 0; i < headers.length; i++)
          Expanded(
            flex: flex[i],
            child: Text(
              headers[i],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );

    Widget body = Column(
      children: rows.map((r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (int i = 0; i < r.length; i++)
                Expanded(flex: flex[i], child: r[i]),
            ],
          ),
        );
      }).toList(),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF0B1D3A).withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            header,
            const Divider(color: Colors.white24, height: 20),
            body,
          ],
        ),
      ),
    );
  }
}
