import 'package:flutter/material.dart';

import 'services/admin_data_service.dart';
import 'widgets/appointments_tab.dart';
import 'widgets/doctors_tab.dart';
import 'widgets/patients_tab.dart';

const List<String> randomNames = [
  'Muhammad Ali',
  'Aisha Rahman',
  'Omar Khan',
  'Fatima Ahmed',
  'Ibrahim Malik',
  'Zainab Hussain',
  'Yusuf Abdullah',
  'Maryam Hassan',
  'Hamza Iqbal',
  'Amina Sheikh',
  'Ismail Farooq',
  'Khadija Akhtar',
  'Bilal Abbas',
  'Safiya Ibrahim',
  'Tariq Mahmood',
  'Hafsa Javed',
  'Idris Nadeem',
  'Sumayya Qureshi',
  'Zakariya Saleem',
  'Ruqayyah Mustafa',
  'Yunus Baig',
  'Asma Chaudhry',
  'Musa Raza',
  'Jamila Akram',
  'Haroon Siddiqui',
  'Mariam Khalid',
  'Usman Farooqi',
  'Nadia Aziz',
  'Abdullah Hashmi',
  'Sara Mirza',
];

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminDataService _dataService = AdminDataService();

  bool _isGeneratingData = false;

  // Stats counters
  int _patientCount = 0;
  int _doctorCount = 0;
  int _appointmentCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Set up listeners for real-time data
    _setupDataListeners();
  }

  void _setupDataListeners() {
    // Listen to patients collection
    _dataService.patientsStream.listen((patients) {
      setState(() {
        _patientCount = patients.length;
      });
    });

    // Listen to doctors collection
    _dataService.doctorsStream.listen((doctors) {
      setState(() {
        _doctorCount = doctors.length;
      });
    });

    // Listen to appointments collection
    _dataService.appointmentsStream.listen((appointments) {
      setState(() {
        _appointmentCount = appointments.length;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Generate mock data for the app
  Future<void> _generateMockData() async {
    if (_isGeneratingData) return;

    setState(() {
      _isGeneratingData = true;
    });

    try {
      // Generate 10 patients
      await _dataService.generateMockPatients(10, randomNames);

      // Generate 5 doctors
      await _dataService.generateMockDoctors(5, randomNames);

      // Generate 20 appointments
      await _dataService.generateMockAppointments(20);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock data generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating mock data: $e')));
    } finally {
      setState(() {
        _isGeneratingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Patients'),
            Tab(icon: Icon(Icons.medical_services), text: 'Doctors'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Appointments'),
          ],
        ),
        actions: [
          // Generate mock data button
          IconButton(
            icon:
                _isGeneratingData
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.add),
            tooltip: 'Generate Mock Data',
            onPressed: _isGeneratingData ? null : _generateMockData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  context,
                  'Patients',
                  _patientCount,
                  Icons.people,
                ),
                _buildStatCard(
                  context,
                  'Doctors',
                  _doctorCount,
                  Icons.medical_services,
                ),
                _buildStatCard(
                  context,
                  'Appointments',
                  _appointmentCount,
                  Icons.calendar_today,
                ),
              ],
            ),
          ),

          // Tab view
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PatientsTab(dataService: _dataService),
                DoctorsTab(dataService: _dataService),
                AppointmentsTab(dataService: _dataService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
