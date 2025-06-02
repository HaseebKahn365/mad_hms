import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

//modal class for medicine:
// 3. Medicines : shows a list of medicines with their details and a button to order the medicine.
class Medicine {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock; // Added stock for inventory status

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.stock = 0, // Default stock to 0
  });

  @override
  String toString() {
    return 'Medicine{id: $id, name: $name, description: $description, price: $price, stock: $stock}';
  }

  // Factory constructor to create a Medicine instance from a map
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      stock: map['stock'] ?? 0,
    );
  }

  // Method to convert a Medicine instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    };
  }
}

class MockPatient {
  String name = '';
  String specialization = '';
  String uuid = const Uuid().v4(); // Unique doctor ID
  String contactNumber = '';
  String profilePictureUrl = '';
  String myFMCToken = '';
  DateTime createdAt = DateTime.now();
  int age; // Added age for patient
  DateTime? lastVisit; // Added lastVisit for patient

  int doneAppointments = 0;

  MockPatient({
    required this.name,
    required this.specialization,
    required this.contactNumber,
    required this.profilePictureUrl,
    this.age = 30, // Default age
    this.lastVisit,
  });

  // Factory constructor to create a MockPatient instance from a map
  factory MockPatient.fromMap(Map<String, dynamic> map) {
    return MockPatient(
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      age: map['age'] ?? 30,
      lastVisit:
          map['lastVisit'] != null ? DateTime.tryParse(map['lastVisit']) : null,
    )..uuid = map['uuid'] ?? const Uuid().v4();
  }

  // Method to convert a MockPatient instance to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'contactNumber': contactNumber,
      'profilePictureUrl': profilePictureUrl,
      'uuid': uuid,
      'createdAt': createdAt.toIso8601String(),
      'doneAppointments': doneAppointments,
      'age': age,
      'lastVisit': lastVisit?.toIso8601String(),
    };
  }
}

//these are the collections in firebase firestore where the the mock data will be stored: and should also read from it
// appointments
// doctors
// medicines
// patients

//Here is what patients look like:

//basic admin dashboard widget
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // Helper widget to create a stat card with gradient background
  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Card(
      elevation: 8.0,
      shadowColor: gradientColors[0].withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(icon, size: 32.0, color: Colors.white.withOpacity(0.9)),
                ],
              ),
              const SizedBox(height: 15.0),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 28.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAppointmentsCard(BuildContext context) {
    final List<Map<String, String>> recentAppointments = [
      {'patient': 'Ahmed Khan', 'doctor': 'Dr. Fatima Ali', 'time': '10:00 AM'},
      {
        'patient': 'Yusuf Rahman',
        'doctor': 'Dr. Omar Siddiqui',
        'time': '11:30 AM',
      },
      {
        'patient': 'Aisha Malik',
        'doctor': 'Dr. Fatima Ali',
        'time': '02:00 PM',
      },
    ];

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Appointments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.date_range_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentAppointments.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final appointment = recentAppointments[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    appointment['patient']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${appointment['doctor']} • ${appointment['time']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'Scheduled',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineInventoryCard(BuildContext context) {
    final List<Map<String, dynamic>> medicineInventory = [
      {'name': 'Paracetamol', 'stock': 150, 'status': 'In Stock'},
      {'name': 'Amoxicillin', 'stock': 20, 'status': 'Low Stock'},
      {'name': 'Ibuprofen', 'stock': 0, 'status': 'Out of Stock'},
      {'name': 'Omeprazole', 'stock': 75, 'status': 'In Stock'},
    ];

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medicine Inventory',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.medication_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicineInventory.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final medicine = medicineInventory[index];
                Color statusColor;
                IconData statusIcon;
                switch (medicine['status']) {
                  case 'In Stock':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle_outline;
                    break;
                  case 'Low Stock':
                    statusColor = Colors.orange;
                    statusIcon = Icons.warning_outlined;
                    break;
                  case 'Out of Stock':
                    statusColor = Colors.red;
                    statusIcon = Icons.error_outline;
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusIcon = Icons.help_outline;
                }
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  title: Text(
                    medicine['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Stock: ${medicine['stock']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      medicine['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hospital Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.3,
                  children: <Widget>[
                    _buildStatCard(
                      'Total Doctors',
                      '15',
                      Icons.medical_services_rounded,
                      [Color(0xFF6C63FF), Color(0xFF3F3D9B)],
                    ),
                    _buildStatCard(
                      'Total Patients',
                      '250',
                      Icons.people_alt_rounded,
                      [Color(0xFF00B4DB), Color(0xFF0083B0)],
                    ),
                    _buildStatCard(
                      'Today\'s\nAppointments',
                      '5',
                      Icons.calendar_today_rounded,
                      [Color(0xFFF6685E), Color(0xFFE53935)],
                    ),
                    _buildStatCard(
                      'Low Stock\nMedicines',
                      '3',
                      Icons.medical_information_rounded,
                      [Color(0xFF2DAF7D), Color(0xFF1E8C67)],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24.0),
            _buildRecentAppointmentsCard(context),
            const SizedBox(height: 24.0),
            _buildMedicineInventoryCard(context),
          ],
        ),
      ),
    );
  }
}
