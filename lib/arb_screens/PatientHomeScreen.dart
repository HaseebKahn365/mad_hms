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
          Center(child: Text('Doctors List Content')),
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
String globalSpeciality = 'Physio Therapist';
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
  final TextEditingController _specialityController = TextEditingController(
    text: globalSpeciality,
  );
  final TextEditingController _addressController = TextEditingController(
    text: globalAddress,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specialityController.dispose();
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
            controller: _specialityController,
            decoration: const InputDecoration(
              labelText: 'Speciality',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              globalSpeciality = value;
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
