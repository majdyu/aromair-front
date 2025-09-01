import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Clients"),
      ),
      drawer: const AdminDrawer(),
      body: const Center(
        child: Text(
          "Welcome to the Admin Clients!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
