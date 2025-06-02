import 'package:flutter/material.dart';
import 'package:mad_hms/notifications/notification_service.dart';
import 'package:mad_hms/patient/profile.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _titles = ['Doctors', 'Medicines', 'Profile'];

  @override
  void initState() {
    super.initState();

    //read the patient provider and fetch the patient data by loadFromPrefs

    Provider.of<PatientProfileProvider>(context, listen: false).loadFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          DoctorsAvailable(),
          // Medicines Tab
          MedicShop(),
          // Profile Tab
          PatientProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Doctors'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        selectedItemColor:
            Theme.of(
              context,
            ).colorScheme.primary, // Set the selected item color
        unselectedItemColor: Colors.grey, // Set the unselected item color
        // backgroundColor: Colors.white, // Set the background color
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class Medicines extends StatelessWidget {
  const Medicines({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: 10, // Replace with actual medicine count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Medicine ${index + 1}'),
            subtitle: Text('Details'),
            trailing: ElevatedButton(
              onPressed: () {
                // Order Medicine
              },
              child: Text('Order Medicine'),
            ),
          );
        },
      ),
    );
  }
}

//lets create a fake list of doctors available for appointment booking from the following information:

final List<Map<String, String>> availableDoctors = [
  {
    'name': 'Dr. Fatima Ali',
    'specialization': 'Cardiology',
    'experience': '8 years',
    'gender': 'Female',
    'rating': '4.8',
    'availableTime': '10:00 AM - 2:00 PM',
  },
  {
    'name': 'Dr. Omar Siddiqui',
    'specialization': 'Neurology',
    'experience': '12 years',
    'gender': 'Male',
    'rating': '4.7',
    'availableTime': '9:00 AM - 5:00 PM',
  },
  {
    'name': 'Dr. Aisha Rahman',
    'specialization': 'Pediatrics',
    'experience': '6 years',
    'gender': 'Female',
    'rating': '4.9',
    'availableTime': '8:00 AM - 3:00 PM',
  },
  {
    'name': 'Dr. Yusuf Malik',
    'specialization': 'Orthopedics',
    'experience': '15 years',
    'gender': 'Male',
    'rating': '4.6',
    'availableTime': '11:00 AM - 6:00 PM',
  },
  {
    'name': 'Dr. Zainab Hussain',
    'specialization': 'Gynecology',
    'experience': '10 years',
    'gender': 'Female',
    'rating': '4.8',
    'availableTime': '9:30 AM - 4:30 PM',
  },
  {
    'name': 'Dr. Ibrahim Khan',
    'specialization': 'Dermatology',
    'experience': '7 years',
    'gender': 'Male',
    'rating': '4.5',
    'availableTime': '10:30 AM - 5:30 PM',
  },
  {
    'name': 'Dr. Layla Mahmood',
    'specialization': 'Psychiatry',
    'experience': '9 years',
    'gender': 'Female',
    'rating': '4.7',
    'availableTime': '12:00 PM - 7:00 PM',
  },
  {
    'name': 'Dr. Tariq Ahmed',
    'specialization': 'Ophthalmology',
    'experience': '11 years',
    'gender': 'Male',
    'rating': '4.6',
    'availableTime': '8:30 AM - 3:30 PM',
  },
];

class DoctorsAvailable extends StatelessWidget {
  const DoctorsAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: availableDoctors.length,
      itemBuilder: (context, index) {
        final doctor = availableDoctors[index];
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      // You can add a placeholder image or use doctor's initials
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        doctor['name']![0], // First letter of doctor's name
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name']!,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            doctor['specialization']!,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4.0),
                            Text(
                              doctor['rating']!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Text(
                          doctor['gender']!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      Icons.work_history_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Experience: ${doctor['experience']!}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Available: ${doctor['availableTime']!}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TapDebouncer(
                    onTap: () async {
                      try {
                        final fcmToken =
                            await NotificationService.getFCMToken();

                        await NotificationService.sendNotificationToPatient(
                          fcmToken,
                          'Afifa : Appointment Request',
                          'Appointment requested with Dr. ${doctor['name']} at ${doctor['availableTime']}',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification sent successfully!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sending notification: $e'),
                          ),
                        );
                      }

                      // TODO: Implement Book Appointment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Booking appointment with ${doctor['name']}...',
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                    cooldown: const Duration(seconds: 2),
                    builder: (context, onTap) {
                      return ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        label: const Text('Book Appointment'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final List<Map<String, String>> availableMedicines = [
  {
    'name': 'Paracetamol',
    'category': 'Pain Reliever',
    'price': '150',
    'dosage': '500mg',
    'usage': 'For fever and mild to moderate pain',
    'delivery': '1-2 days',
  },
  {
    'name': 'Amoxicillin',
    'category': 'Antibiotic',
    'price': '350',
    'dosage': '250mg',
    'usage': 'For bacterial infections',
    'delivery': 'Same day',
  },
  {
    'name': 'Loratadine',
    'category': 'Antihistamine',
    'price': '200',
    'dosage': '10mg',
    'usage': 'For allergies and hay fever',
    'delivery': '1-2 days',
  },
  {
    'name': 'Omeprazole',
    'category': 'Antacid',
    'price': '280',
    'dosage': '20mg',
    'usage': 'For acid reflux and heartburn',
    'delivery': 'Same day',
  },
  {
    'name': 'Metformin',
    'category': 'Antidiabetic',
    'price': '320',
    'dosage': '500mg',
    'usage': 'For type 2 diabetes',
    'delivery': '1-2 days',
  },
  {
    'name': 'Amlodipine',
    'category': 'Blood Pressure',
    'price': '250',
    'dosage': '5mg',
    'usage': 'For high blood pressure',
    'delivery': 'Same day',
  },
  {
    'name': 'Cetirizine',
    'category': 'Antihistamine',
    'price': '180',
    'dosage': '10mg',
    'usage': 'For allergic symptoms',
    'delivery': '1-2 days',
  },
  {
    'name': 'Aspirin',
    'category': 'Pain Reliever',
    'price': '120',
    'dosage': '75mg',
    'usage': 'For pain, fever and inflammation',
    'delivery': 'Same day',
  },
];

class MedicShop extends StatelessWidget {
  const MedicShop({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: availableMedicines.length,
      itemBuilder: (context, index) {
        final medicine = availableMedicines[index];
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.medication,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine['name']!,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            medicine['category']!,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${medicine['price']!}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          medicine['dosage']!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Usage: ${medicine['usage']!}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Delivery: ${medicine['delivery']!}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TapDebouncer(
                    onTap: () async {
                      try {
                        final fcmToken =
                            await NotificationService.getFCMToken();
                        await NotificationService.sendNotificationToPatient(
                          fcmToken,
                          'Medicine Order Placed',
                          '${medicine['name']} has been ordered. Estimated delivery: ${medicine['delivery']}',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sending notification: $e'),
                          ),
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ordering ${medicine['name']}...'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                    cooldown: const Duration(seconds: 2),
                    builder: (context, onTap) {
                      return ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        label: const Text('Order Now'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
