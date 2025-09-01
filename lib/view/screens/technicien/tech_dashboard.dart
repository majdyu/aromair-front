import 'package:flutter/material.dart';

class TechDashboard extends StatelessWidget {
  const TechDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Overview"),
      ),
      body: const Center(
        child: Text(
          "Welcome to the Technician Overview !",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
