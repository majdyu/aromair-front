import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';

class AprobationsScreen extends StatelessWidget {
  const AprobationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Aprobations"),
      ),
      drawer: const AdminDrawer(),
      body: const Center(
        child: Text(
          "Welcome to the Admin Aprobations!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
