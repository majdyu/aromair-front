import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';

class AromaScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onRefresh;

  const AromaScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1E40),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: onRefresh,
              tooltip: "Actualiser",
            ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1E40), Color(0xFF152A51), Color(0xFF1E3A8A)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: body,
          ),
        ),
      ),
    );
  }
}
