import 'package:flutter/material.dart';

/// Página de login do administrador (a implementar).
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Admin')),
      body: const Center(child: Text('Login do administrador (a implementar)')),
    );
  }
}
