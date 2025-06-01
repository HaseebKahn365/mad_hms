import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mad_hms/notifications/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

import 'theme_settings_widget.dart';

class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

XFile? selectedImage; //global for state to hold the image file

bool settingsChanged = false;

class _PatientProfileState extends State<PatientProfile> {
  //controllers for text fields can be used if needed
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();

  // Function to upload changes to the profile
  Future<void> uploadChanges() async {
    final profileProvider = Provider.of<PatientProfileProvider>(
      context,
      listen: false,
    );

    try {
      await profileProvider.forceUploadAllProfileData(
        newName:
            nameController.text.isNotEmpty
                ? nameController.text
                : profileProvider.name,
        newAge:
            ageController.text.isNotEmpty
                ? int.tryParse(ageController.text) ?? profileProvider.age
                : profileProvider.age,
        newDescription:
            descriptionController.text.isNotEmpty
                ? descriptionController.text
                : profileProvider.description,
        newContactNumber:
            contactNumberController.text.isNotEmpty
                ? contactNumberController.text
                : profileProvider.contactNumber,
      );

      if (selectedImage != null) {
        try {
          await profileProvider.uploadProfilePicture(selectedImage!.path);
          setState(() {
            selectedImage = null; // Reset the selected image after upload
          });
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
          return;
        }
      }

      setState(() {
        settingsChanged = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (imageFile != null) {
        selectedImage = imageFile;

        setState(() {
          settingsChanged = true;
        });

        log(
          'Image selected: ${selectedImage!.path} with size: ${(await selectedImage!.readAsBytes()).lengthInBytes} bytes',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    ageController.dispose();
    descriptionController.dispose();
    contactNumberController.dispose();
    log('Disposed of text controllers');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProfileProvider>(
      builder: (context, profileProvider, child) {
        log(
          'Using provider with data: ${profileProvider.name}, ${profileProvider.age}, ${profileProvider.description}, ${profileProvider.contactNumber}, ${profileProvider.profilePictureUrl}',
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await pickImage();
                  },
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        selectedImage != null
                            ? FileImage(File(selectedImage!.path))
                            : profileProvider.profilePictureUrl.isNotEmpty
                            ? CachedNetworkImageProvider(
                              profileProvider.profilePictureUrl,
                            )
                            : null,
                    child:
                        selectedImage == null &&
                                profileProvider.profilePictureUrl.isEmpty
                            ? Icon(Icons.person, size: 50)
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText:
                      profileProvider.name.isNotEmpty
                          ? profileProvider.name
                          : 'Enter your name',

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: nameController,
                onChanged: (value) {
                  setState(() {
                    settingsChanged = true;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText:
                      profileProvider.age > 0
                          ? profileProvider.age.toString()
                          : 'Enter your age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: ageController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    settingsChanged = true;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText:
                      profileProvider.description.isNotEmpty
                          ? profileProvider.description
                          : 'Description / bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: descriptionController,
                onChanged: (value) {
                  setState(() {
                    settingsChanged = true;
                  });
                },
              ),

              // Contact number field
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText:
                      profileProvider.contactNumber.isNotEmpty
                          ? profileProvider.contactNumber
                          : 'Contact Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: contactNumberController,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    settingsChanged = true;
                  });
                },
              ),

              const SizedBox(height: 16),
              if (settingsChanged)
                SizedBox(
                  width: 150,
                  child: TapDebouncer(
                    onTap: () async {
                      await uploadChanges();
                    },
                    builder: (context, onTap) {
                      return OutlinedButton(
                        onPressed: onTap,
                        child: const Text('Save Changes'),
                      );
                    },
                  ),
                ),
              if (profileProvider.isUploading)
                const SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text('Uploading...'),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            appBar: AppBar(title: const Text('Theme Settings')),
                            body: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: const ThemeSettingsWidget(),
                            ),
                          ),
                    ),
                  );
                },
                child: const Text('Adjust Theme Settings'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PatientProfileProvider with ChangeNotifier {
  //we are gonna use shared preferences to store the data everytime it changes and load it
  //when the app starts
  SharedPreferences? _prefs;

  String name = '';
  int age = 0;
  String uuid = '1234haseeeb';
  DateTime createdAt = DateTime.now();
  String description = '';
  String profilePictureUrl = '';
  String myFMCToken = '';
  String contactNumber = '';

  List<Appointment> appointments = [];
  bool isUploading = false;

  // Initialize SharedPreferences
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await loadFromPrefs();
  }

  // Save all data to SharedPreferences
  Future<void> saveToPrefs() async {
    if (_prefs == null) await initPrefs();

    await _prefs!.setString('name', name);
    await _prefs!.setInt('age', age);
    await _prefs!.setString('uuid', uuid);
    await _prefs!.setString('description', description);
    await _prefs!.setString('profilePictureUrl', profilePictureUrl);
    await _prefs!.setString('myFMCToken', myFMCToken);
    await _prefs!.setString('contactNumber', contactNumber);
    await _prefs!.setString('createdAt', createdAt.toIso8601String());
  }

  // Load all data from SharedPreferences
  Future<void> loadFromPrefs() async {
    if (_prefs == null) await initPrefs();

    name = _prefs!.getString('name') ?? '';
    age = _prefs!.getInt('age') ?? 0;
    uuid = _prefs!.getString('uuid') ?? '1234haseeeb';
    description = _prefs!.getString('description') ?? '';
    profilePictureUrl = _prefs!.getString('profilePictureUrl') ?? '';
    myFMCToken = _prefs!.getString('myFMCToken') ?? '';
    contactNumber = _prefs!.getString('contactNumber') ?? '';
    final createdAtStr = _prefs!.getString('createdAt');
    createdAt = DateTime.parse(
      createdAtStr ?? DateTime.now().toIso8601String(),
    );

    log(
      'Loaded profile data: name: $name, age: $age, description: $description, contactNumber: $contactNumber, profilePictureUrl: $profilePictureUrl, createdAt: $createdAt',
    );
  }

  forceUploadAllProfileData({
    required String newName,
    required int newAge,
    required String newDescription,
    required String newContactNumber,
  }) async {
    log(
      'Force uploading profile data with name: $newName, age: $newAge, description: $newDescription, contactNumber: $newContactNumber',
    );
    isUploading = true;
    notifyListeners();

    final patientDocRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(uuid);

    try {
      final fcmToken = await NotificationService.getFCMToken();
      await patientDocRef.set({
        'name': newName,
        'age': newAge,
        'description': newDescription,
        'contactNumber': newContactNumber,
        'profilePictureUrl': profilePictureUrl,
        'createdAt': createdAt,
        'myFMCToken': fcmToken,
      }, SetOptions(merge: true));

      name = newName;
      age = newAge;
      description = newDescription;
      contactNumber = newContactNumber;
      await saveToPrefs(); // Save changes to SharedPreferences
    } catch (e) {
      log('Error uploading profile data: $e');
      print('Error uploading profile data: $e');
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfilePicture(String filePath) async {
    isUploading = true;
    notifyListeners();

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $filePath');
      }

      log(
        'Starting profile picture upload. File size: ${await file.length()} bytes',
      );

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uuid.jpg');

      log('Uploading to Firebase Storage path: ${storageRef.fullPath}');

      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        log('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      final snapshot = await uploadTask;
      log(
        'Upload completed. Total bytes transferred: ${snapshot.bytesTransferred}',
      );

      final downloadUrl = await snapshot.ref.getDownloadURL();
      log('Download URL obtained: $downloadUrl');

      final patientDocRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(uuid);
      final docSnapshot = await patientDocRef.get();
      if (docSnapshot.exists) {
        await patientDocRef.update({'profilePictureUrl': downloadUrl});
      } else {
        await patientDocRef.set({
          'profilePictureUrl': downloadUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      profilePictureUrl = downloadUrl;
      await saveToPrefs(); // Save changes to SharedPreferences
      log('Profile picture upload process completed successfully');
    } catch (e, stackTrace) {
      log('Error uploading profile picture: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }
}

class Appointment {
  final String docRefOfDoctor;
  final DateTime appointmentDateTime;

  Appointment({
    required this.docRefOfDoctor,
    required this.appointmentDateTime,
  });
}
