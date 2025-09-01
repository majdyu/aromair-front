import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';

class ReclamationsScreen extends StatelessWidget {
  const ReclamationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Reclamations"),
      ),
      drawer: const AdminDrawer(),
      body: const Center(
        child: Text(
          "Welcome to the Admin Reclamations!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
