import 'package:flutter/material.dart';

//basic admin dashboard widget
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(child: Text('Welcome to the Admin Dashboard!')),
    );
  }
}
