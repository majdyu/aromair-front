import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';

class DiffuseursScreen extends StatelessWidget {
  const DiffuseursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Diffuseurs"),
      ),
      drawer: const AdminDrawer(),
      body: const Center(
        child: Text(
          "Welcome to the Admin Diffuseurs!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
