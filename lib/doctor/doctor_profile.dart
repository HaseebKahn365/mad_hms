import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mad_hms/notifications/notification_service.dart';
import 'package:mad_hms/registration/doctor_registration/doctor_provider.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

XFile? selectedImage; // Global for state to hold the image file

bool settingsChanged = false;

class _DoctorProfileState extends State<DoctorProfile> {
  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing data from provider
    final doctorProvider = Provider.of<DoctorProfileProvider>(
      context,
      listen: false,
    );
    nameController.text = doctorProvider.name;
    specializationController.text = doctorProvider.specialization;
    contactNumberController.text = doctorProvider.contactNumber;
  }

  // Function to upload changes to the profile
  Future<void> uploadChanges() async {
    final doctorProvider = Provider.of<DoctorProfileProvider>(
      context,
      listen: false,
    );

    // Lose focus on the text fields to avoid keyboard issues
    FocusScope.of(context).unfocus();

    try {
      await doctorProvider.updateProfile(
        newName:
            nameController.text.isNotEmpty
                ? nameController.text
                : doctorProvider.name,
        newSpecialization:
            specializationController.text.isNotEmpty
                ? specializationController.text
                : doctorProvider.specialization,
        newContactNumber:
            contactNumberController.text.isNotEmpty
                ? contactNumberController.text
                : doctorProvider.contactNumber,
      );

      // If there's a new profile picture to upload
      if (selectedImage != null) {
        try {
          await uploadProfilePicture(selectedImage!.path, doctorProvider);
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

      // Sync with Firebase
      await syncProfileToFirebase(doctorProvider);

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

  // Function to sync profile to Firebase
  Future<void> syncProfileToFirebase(
    DoctorProfileProvider doctorProvider,
  ) async {
    try {
      final doctorDocRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorProvider.uuid);

      final fcmToken = await NotificationService.getFCMToken();
      await doctorDocRef.set({
        'name': doctorProvider.name,
        'specialization': doctorProvider.specialization,
        'contactNumber': doctorProvider.contactNumber,
        'profilePictureUrl': doctorProvider.profilePictureUrl,
        'myFMCToken': fcmToken,
      }, SetOptions(merge: true));

      log('Profile synced to Firebase successfully');
    } catch (e) {
      log('Error syncing profile to Firebase: $e');
      rethrow;
    }
  }

  // Function to upload profile picture
  Future<void> uploadProfilePicture(
    String filePath,
    DoctorProfileProvider doctorProvider,
  ) async {
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
          .child('doctor_profile_pictures')
          .child('${doctorProvider.uuid}.jpg');

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

      final doctorDocRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorProvider.uuid);

      await doctorDocRef.update({'profilePictureUrl': downloadUrl});

      // Update local provider by calling the new method in DoctorProfileProvider
      await doctorProvider.updateProfilePictureUrl(downloadUrl);
      // No need to set isUploading to false here, it's handled in the provider's method or finally block.
      // No need to call notifyListeners() here, it's handled by updateProfilePictureUrl.

      log('Profile picture upload process completed successfully');
    } catch (e, stackTrace) {
      log('Error uploading profile picture: $e');
      log('Stack trace: $stackTrace');
      rethrow;
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
    nameController.dispose();
    specializationController.dispose();
    contactNumberController.dispose();
    log('Disposed of text controllers');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorProfileProvider>(
      builder: (context, doctorProvider, child) {
        log(
          'Using provider with data: ${doctorProvider.name}, ${doctorProvider.specialization}, ${doctorProvider.contactNumber}, ${doctorProvider.profilePictureUrl}',
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (doctorProvider.profilePictureUrl.isNotEmpty ||
                                    selectedImage != null)
                                ? (doctorProvider.profilePictureUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                      doctorProvider.profilePictureUrl,
                                    )
                                    : selectedImage != null
                                    ? FileImage(File(selectedImage!.path))
                                    : const AssetImage('assets/images/logo.jpg')
                                        as ImageProvider)
                                : const AssetImage('assets/images/logo.jpg'),
                        child:
                            doctorProvider.profilePictureUrl.isEmpty &&
                                    selectedImage == null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              Text(
                'Name',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    settingsChanged = true;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Specialization field
              Text(
                'Specialization',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: specializationController,
                decoration: InputDecoration(
                  hintText: 'Enter your specialization',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    settingsChanged = true;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Contact number field
              Text(
                'Contact Number',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contactNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter your contact number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    settingsChanged = true;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Save button
              if (settingsChanged)
                SizedBox(
                  width: double.infinity,
                  child: TapDebouncer(
                    onTap: uploadChanges,
                    builder: (context, onTap) {
                      return ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            doctorProvider.isUploading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Save Changes'),
                      );
                    },
                  ),
                ),

              // Loading indicator
              if (doctorProvider.isUploading && !settingsChanged)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Logout button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () {
                    // Handle logout
                    final doctorProvider = Provider.of<DoctorProfileProvider>(
                      context,
                      listen: false,
                    );
                    doctorProvider.logout();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
