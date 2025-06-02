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

  // Helper widget to create a stat card
  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: color),
            const SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              count,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAppointmentsCard(BuildContext context) {
    // Static data for recent appointments
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recent Appointments',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // To disable scrolling within the card
              itemCount: recentAppointments.length,
              itemBuilder: (context, index) {
                final appointment = recentAppointments[index];
                return ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text(
                    '${appointment['patient']} with ${appointment['doctor']}',
                  ),
                  subtitle: Text('Time: ${appointment['time']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineInventoryCard(BuildContext context) {
    // Static data for medicine inventory
    final List<Map<String, dynamic>> medicineInventory = [
      {'name': 'Paracetamol', 'stock': 150, 'status': 'In Stock'},
      {'name': 'Amoxicillin', 'stock': 20, 'status': 'Low Stock'},
      {'name': 'Ibuprofen', 'stock': 0, 'status': 'Out of Stock'},
      {'name': 'Omeprazole', 'stock': 75, 'status': 'In Stock'},
    ];
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Medicine Inventory Status',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicineInventory.length,
              itemBuilder: (context, index) {
                final medicine = medicineInventory[index];
                Color statusColor;
                switch (medicine['status']) {
                  case 'In Stock':
                    statusColor = Colors.green;
                    break;
                  case 'Low Stock':
                    statusColor = Colors.orange;
                    break;
                  case 'Out of Stock':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.grey;
                }
                return ListTile(
                  leading: Icon(Icons.medication_outlined, color: statusColor),
                  title: Text(medicine['name']),
                  subtitle: Text('Stock: ${medicine['stock']}'),
                  trailing: Text(
                    medicine['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
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
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Responsive grid for stat cards
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1; // Single column for very small screens
                }
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio:
                      (crossAxisCount == 1) ? 3 : 1.5, // Adjust aspect ratio
                  children: <Widget>[
                    _buildStatCard(
                      'Total Doctors',
                      '15',
                      Icons.medical_services,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Total Patients',
                      '250',
                      Icons.people,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Upcoming Appointments',
                      '5',
                      Icons.calendar_today,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Medicines Low Stock',
                      '3',
                      Icons.medication,
                      Colors.red,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20.0),
            _buildRecentAppointmentsCard(context),
            const SizedBox(height: 20.0),
            _buildMedicineInventoryCard(context),
          ],
        ),
      ),
    );
  }
}
