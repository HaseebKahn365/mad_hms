import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mad_hms/arb_screens/patient_stuff/medic.dart';
import 'package:mad_hms/notifications/notification_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

//refined

class _PatientHomeScreenState extends State<PatientHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Shop'),
            Tab(icon: Icon(Icons.medical_services), text: 'Doctors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PatientProfileScreen(),
          MedicineGridScreen(),
          DoctorAppointmentScreen(),
        ],
      ),
    );
  }
}
//a  basic profile screen with profile piciture and name, email, speciality addreess controllers prefilled for Arooba as Patient

XFile globalImageFile = XFile('');

//global var names for patient info for global state
String globalName = 'Arooba Khan';
String globalEmail = 'Arooba@gmail.com';
String globalProblem = 'Headache';
String globalAddress = 'Swabi, KPK, Pakistan';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController(
    text: globalName,
  );
  final TextEditingController _emailController = TextEditingController(
    text: globalEmail,
  );
  final TextEditingController _problemController = TextEditingController(
    text: globalProblem,
  );
  final TextEditingController _addressController = TextEditingController(
    text: globalAddress,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _problemController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 40,
      );
      if (pickedFile != null) {
        setState(() {
          globalImageFile = pickedFile;
        });

        final String fileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        final File file = File(pickedFile.path);
        try {
          final ref = FirebaseStorage.instance.ref().child('arb/$fileName.jpg');
          await ref.putFile(file);
          //make the picker
        } catch (e) {}
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Center(
            child: GestureDetector(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage:
                        globalImageFile.path.isEmpty
                            ? null
                            : FileImage(File(globalImageFile.path))
                                as ImageProvider,
                    child:
                        globalImageFile.path.isEmpty
                            ? const Icon(Icons.camera_alt, size: 50)
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.photo_camera,
                                  size: 32,
                                ),
                                title: const Text(
                                  'Take a photo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.photo_library,
                                  size: 32,
                                ),
                                title: const Text(
                                  'Choose from gallery',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              globalName = value;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              globalEmail = value;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _problemController,
            decoration: const InputDecoration(
              labelText: 'Problem',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              globalProblem = value;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              globalAddress = value;
            },
          ),
        ],
      ),
    );
  }
}

//!meidc page:

class MedicineGridScreen extends StatelessWidget {
  const MedicineGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8, // Adjust item aspect ratio
          ),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            final medicine = medicines[index];
            return MedicineCard(medicine: medicine);
          },
        ),
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final MedicineItem medicine;

  const MedicineCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Show a confirmation dialog first
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Purchase'),
              content: Text(
                'Do you want to purchase ${medicine.name} and have it delivered to \n$globalAddress?',
              ),

              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Purchase'),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          // Send a notification to myself for demo
          String? fcmToken = await NotificationService.getFCMToken();
          if (fcmToken.isNotEmpty) {
            bool success = await NotificationService.sendNotificationToPatient(
              fcmToken,
              'Medicine Purchase Confirmation',
              'Arooba has purchased ${medicine.name} for Rs. ${medicine.price.toStringAsFixed(2)}\n and will be delivered to: $globalAddress',
              data: {'medicineId': medicine.name.toString()},
            );

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase confirmed! Notification sent.'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to send notification.')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not get FCM token.')),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),

        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine Image
                Center(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(medicine.imageUrl),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Medicine Name
                Text(
                  medicine.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),

                // Price
                Text(
                  'Rs. ${medicine.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),

                // Star Rating
                Row(
                  children: [
                    for (int i = 0; i < medicine.rating; i++)
                      Icon(Icons.star, color: Colors.amber, size: 20),
                    for (int i = 0; i < 5 - medicine.rating; i++)
                      Icon(Icons.star_border, color: Colors.amber, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DoctorProfile {
  final String name;
  final String imageUrl;
  final String specialization;
  final int rating;
  final double consultationFee;
  final List<String> availableDays;
  final List<String> availableSlots;

  DoctorProfile({
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.rating,
    required this.consultationFee,
    required this.availableDays,
    required this.availableSlots,
  });
}

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  _DoctorAppointmentScreenState createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  List<DoctorProfile> doctors = [
    DoctorProfile(
      name: 'Dr. Harry Potter',
      imageUrl:
          'https://th.bing.com/th/id/OIP.TYzWK2HqKaqczU98GKeshQHaHZ?rs=1&pid=ImgDetMain',
      specialization: 'Wizarding Medicine',
      rating: 5,
      consultationFee: 2500.00,
      availableDays: ['Mon', 'Wed', 'Fri'],
      availableSlots: ['9:00 AM', '11:00 AM', '2:00 PM'],
    ),
    DoctorProfile(
      name: 'Dr. Sara Khan',
      imageUrl:
          'https://img.freepik.com/premium-photo/young-pakistani-doctor-girl-celebrating-pakistan-14th-august-day_993198-167.jpg',
      specialization: 'General Physician',
      rating: 4,
      consultationFee: 1500.00,
      availableDays: ['Tue', 'Thu', 'Sat'],
      availableSlots: ['10:00 AM', '1:00 PM', '3:00 PM'],
    ),
    DoctorProfile(
      name: 'Dr. Sania Mirza',
      imageUrl:
          'https://bmidoctors.com/wp-content/uploads/2024/03/weight-loss-doctor-1-scaled.jpg',
      specialization: 'Nutrition Specialist',
      rating: 5,
      consultationFee: 2000.00,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu'],
      availableSlots: ['8:00 AM', '12:00 PM', '4:00 PM'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ...doctors.map((doctor) {
            return DoctorCard(
              doctor: doctor,
              onBookAppointment: () => _showAppointmentDialog(context, doctor),
            );
          }),

          const SizedBox(height: 120),
          //text field for setting target FCM token
          TextField(
            decoration: InputDecoration(
              labelText: 'Target Doctor Id',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              targetFCMToken = value; // Update the global token
            },
          ),
        ],
      ),
    );
  }

  void _showAppointmentDialog(BuildContext context, DoctorProfile doctor) {
    String? selectedDay;
    String? selectedSlot;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Book Appointment with ${doctor.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Day'),
                  items:
                      doctor.availableDays.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day));
                      }).toList(),
                  onChanged: (value) => selectedDay = value,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Time Slot'),
                  items:
                      doctor.availableSlots.map((slot) {
                        return DropdownMenuItem(value: slot, child: Text(slot));
                      }).toList(),
                  onChanged: (value) => selectedSlot = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedDay != null && selectedSlot != null) {
                    _confirmAppointment(
                      context,
                      doctor,
                      selectedDay!,
                      selectedSlot!,
                    );
                  }
                },
                child: Text('Book Now'),
              ),
            ],
          ),
    );
  }

  void _confirmAppointment(
    BuildContext context,
    DoctorProfile doctor,
    String day,
    String slot,
  ) {
    Navigator.pop(context); // Close the selection dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Appointment Confirmed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Doctor: ${doctor.name}'),
                Text('Specialization: ${doctor.specialization}'),
                Text('Date: $day'),
                Text('Time: $slot'),
                Text('Fee: Rs. ${doctor.consultationFee}'),
                SizedBox(height: 16),
                Text('We have sent the details to your email.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Send a notification to targetFCMToken
                  bool
                  success = await NotificationService.sendNotificationToPatient(
                    targetFCMToken,
                    'Appointment Confirmation',
                    'Your appointment with ${doctor.name} on $day at $slot has been confirmed. Fee: Rs. ${doctor.consultationFee}, ',

                    data: {
                      'doctorName': doctor.name,
                      'day': day,
                      'slot': slot,
                      'fee': doctor.consultationFee.toString(),
                    },
                  );

                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notification sent to $targetFCMToken'),
                      ),
                    );
                  } else {}

                  // Close the dialog
                  await NotificationService.getFCMToken().then(
                    (token) => log('My FCM Token: $token'),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}

String targetFCMToken = ''; // Replace with your FCM token

class DoctorCard extends StatelessWidget {
  final DoctorProfile doctor;
  final VoidCallback onBookAppointment;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        doctor.specialization,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < doctor.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(doctor.imageUrl),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs. ${doctor.consultationFee}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: onBookAppointment,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Take Appointment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
