import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedSection = 'Appointments';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildDashboardButton(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Appointments',
                    onTap: () => _setSelectedSection('Appointments'),
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.medical_services,
                    label: 'Doctors',
                    onTap: () => _setSelectedSection('Doctors'),
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.medication,
                    label: 'Medicines',
                    onTap: () => _setSelectedSection('Medicines'),
                  ),
                  _buildDashboardButton(
                    context,
                    icon: Icons.people,
                    label: 'Patients',
                    onTap: () => _setSelectedSection('Patients'),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSelectedSectionContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSectionContent() {
    switch (_selectedSection) {
      case 'Doctors':
        return const Center(child: Text('Doctors Management Content'));
      case 'Medicines':
        return const Center(child: Text('Medicines Management Content'));
      case 'Patients':
        return const Center(child: Text('Patients Management Content'));
      case 'Appointments':
      default:
        return const Center(child: Text('Appointments Management Content'));
    }
  }

  void _setSelectedSection(String section) {
    setState(() {
      _selectedSection = section;
    });
  }
}
