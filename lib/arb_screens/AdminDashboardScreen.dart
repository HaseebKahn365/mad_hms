import 'package:flutter/material.dart';

class MedicineItem {
  final String name;
  final String imageUrl;
  final double price;
  final double rating;

  MedicineItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
  });
}

class DoctorProfile {
  final String name;
  final String imageUrl;
  final String specialization;
  final int rating;
  final double consultationFee;

  DoctorProfile({
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.rating,
    required this.consultationFee,
  });
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedSection = 'Appointments';

  // Mock data for medicines
  final List<MedicineItem> _medicines = [
    MedicineItem(
      name: 'Arinac',
      imageUrl:
          'https://th.bing.com/th/id/OIP.N6QhItjra2DFcBNtk3tiMgHaEU?w=289&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      price: 120.50,
      rating: 4.2,
    ),
    MedicineItem(
      name: 'Rotec',
      imageUrl:
          'https://th.bing.com/th/id/OIP.TRb9F_IOKCO6pIuOx_VkNAHaEU?w=255&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      price: 85.75,
      rating: 3.9,
    ),
    MedicineItem(
      name: 'Nospa',
      imageUrl:
          'https://th.bing.com/th/id/OIP.QYGp0m-o5bnw7Kw4TDW56QHaEU?w=283&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      price: 65.00,
      rating: 4.5,
    ),
    MedicineItem(
      name: 'Rigix',
      imageUrl:
          'https://th.bing.com/th/id/OIP.RwXb9icQW4zpBZh_l_X8tAHaEK?w=305&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      price: 95.25,
      rating: 4.1,
    ),
    MedicineItem(
      name: 'Subex',
      imageUrl:
          'https://th.bing.com/th/id/OIP.ZjYH7o-vfNujNY6yJ6ydCgHaEU?w=317&h=184&c=7&r=0&o=7&pid=1.7&rm=3',
      price: 150.00,
      rating: 4.0,
    ),
    MedicineItem(
      name: 'Losartan',
      imageUrl:
          'https://th.bing.com/th/id/OIP.RoXTgANLxXZyTrCqOHdH4QHaEK?w=324&h=182&c=7&r=0&o=7&pid=1.7&rm=3',
      price: 180.50,
      rating: 4.3,
    ),
  ];

  // Mock data for doctors
  final List<DoctorProfile> _doctors = [
    DoctorProfile(
      name: 'Dr. Harry Potter',
      imageUrl:
          'https://th.bing.com/th/id/OIP.TYzWK2HqKaqczU98GKeshQHaHZ?rs=1&pid=ImgDetMain',
      specialization: 'Wizarding Medicine',
      rating: 5,
      consultationFee: 12500.00,
    ),
    DoctorProfile(
      name: 'Dr. Sara Khan',
      imageUrl:
          'https://img.freepik.com/premium-photo/young-pakistani-doctor-girl-celebrating-pakistan-14th-august-day_993198-167.jpg',
      specialization: 'General Physician',
      rating: 4,
      consultationFee: 1500.00,
    ),
    DoctorProfile(
      name: 'Dr. Sania Mirza',
      imageUrl:
          'https://bmidoctors.com/wp-content/uploads/2024/03/weight-loss-doctor-1-scaled.jpg',
      specialization: 'Nutrition & Weight Loss',
      rating: 5,
      consultationFee: 2000.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 4,
      ),
      body: LayoutBuilder(
        builder:
            (context, constraints) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                      children: [
                        _buildDashboardCard(
                          icon: Icons.calendar_month,
                          title: 'Appointments\n(2)',
                          color: Colors.blue,
                          onTap: () => _setSelectedSection('Appointments'),
                        ),
                        _buildDashboardCard(
                          icon: Icons.medical_services,
                          title: 'Doctors\n(3)',
                          color: Colors.green,
                          onTap: () => _setSelectedSection('Doctors'),
                        ),
                        _buildDashboardCard(
                          icon: Icons.medication,
                          title: 'Medicines\n(16)',
                          color: Colors.deepPurple,
                          onTap: () => _setSelectedSection('Medicines'),
                        ),
                        _buildDashboardCard(
                          icon: Icons.people,
                          title: 'Patients\n(10)',
                          color: Colors.orange,
                          onTap: () => _setSelectedSection('Patients'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildSelectedSectionContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorProfile doctor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(doctor.imageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < doctor.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Consultation Fee: Rs. ${doctor.consultationFee.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement edit functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineItem medicine) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    medicine.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. ${medicine.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        medicine.rating.toString(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement edit functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // TODO: Implement delete functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSectionContent() {
    switch (_selectedSection) {
      case 'Doctors':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registered Doctors',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Doctor'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ..._doctors.map((doctor) => _buildDoctorCard(doctor)),
          ],
        );
      case 'Medicines':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Medicine Inventory',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement add medicine functionality
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medicine'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ..._medicines.map((medicine) => _buildMedicineCard(medicine)),
          ],
        );
      case 'Patients':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'dena screenshot ma obasa',
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case 'Appointments':
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'dena screenshot ma obasa',
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }

  void _setSelectedSection(String section) {
    setState(() {
      _selectedSection = section;
    });
  }
}
