import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';

class AlertesScreen extends StatelessWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Alertes"),
      ),
      drawer: const AdminDrawer(),
      body: const Center(
        child: Text(
          "Welcome to the Admin Alertes!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
