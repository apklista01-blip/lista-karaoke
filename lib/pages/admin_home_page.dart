import 'package:flutter/material.dart';

/// Página principal do administrador (a implementar).
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: const Center(
        child: Text('Painel do administrador (a implementar)'),
      ),
    );
  }
}
