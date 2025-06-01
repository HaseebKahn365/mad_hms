import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mad_hms/notifications/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DoctorProfileProvider with ChangeNotifier {
  // Basic profile information
  String name = '';
  String specialization = '';
  String uuid = const Uuid().v4(); // Unique doctor ID
  String contactNumber = '';
  String profilePictureUrl = '';
  String myFMCToken = '';
  DateTime createdAt = DateTime.now();

  // Appointments will store patient IDs
  List<String> appointments = [];
  bool isUploading = false;

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Initialize preferences
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await loadFromPrefs();
  }

  //!Creating a logout method to clear all data and exit the app with 0
  Future<void> logout() async {
    if (_prefs == null) await initPrefs();

    // Clear all data from SharedPreferences
    await _prefs!.clear();
    log('Doctor profile cleared from local storage');

    // Reset all fields
    name = '';
    specialization = '';
    uuid = const Uuid().v4();
    contactNumber = '';
    profilePictureUrl = '';
    myFMCToken = '';
    createdAt = DateTime.now();
    appointments.clear();

    isUploading = false;
    saveToPrefs(); // Save the cleared state to prefs
    notifyListeners();
    exit(0); // Exit the app with code 0
  }

  // Save all data to local storage
  Future<void> saveToPrefs() async {
    if (_prefs == null) await initPrefs();

    await _prefs!.setString('doctor_name', name);
    await _prefs!.setString('specialization', specialization);
    await _prefs!.setString('doctor_uuid', uuid);
    await _prefs!.setString('contact_number', contactNumber);
    await _prefs!.setString('profile_picture_url', profilePictureUrl);
    await _prefs!.setString('fcm_token', myFMCToken);
    await _prefs!.setString('created_at', createdAt.toIso8601String());

    // Save appointments list
    await _prefs!.setStringList('appointments', appointments);
  }

  // Load all data from local storage
  Future<void> loadFromPrefs() async {
    if (_prefs == null) await initPrefs();

    name = _prefs!.getString('doctor_name') ?? '';
    specialization = _prefs!.getString('specialization') ?? '';
    uuid = _prefs!.getString('doctor_uuid') ?? const Uuid().v4();
    contactNumber = _prefs!.getString('contact_number') ?? '';
    profilePictureUrl = _prefs!.getString('profile_picture_url') ?? '';
    myFMCToken =
        _prefs!.getString('fcm_token') ??
        NotificationService.getFCMToken().toString();

    final createdAtStr = _prefs!.getString('created_at');
    createdAt =
        createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();

    appointments = _prefs!.getStringList('appointments') ?? [];

    log('Loaded doctor profile: $name, $specialization, $contactNumber');
  }

  // Update basic profile information and sync with Firebase
  Future<void> updateProfile({
    required String newName,
    required String newSpecialization,
    required String newContactNumber,
  }) async {
    isUploading = true;
    notifyListeners();

    try {
      // Update local variables
      name = newName;
      specialization = newSpecialization;
      contactNumber = newContactNumber;

      // Save to Firebase
      await syncProfileToFirebase();

      // Save to local storage
      await saveToPrefs();
    } catch (e) {
      log('Error updating profile: $e');
      rethrow;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  // Sync all profile data to Firebase
  Future<void> syncProfileToFirebase() async {
    isUploading = true;
    notifyListeners();

    try {
      final doctorDocRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(uuid);

      // Get updated FCM token
      myFMCToken = await NotificationService.getFCMToken();

      // Set the doctor data with merge option to update existing fields
      await doctorDocRef.set({
        'name': name,
        'specialization': specialization,
        'contactNumber': contactNumber,
        'profilePictureUrl': profilePictureUrl,
        'createdAt': createdAt,
        'fcmToken': myFMCToken,
        'appointments': appointments,
      }, SetOptions(merge: true));

      log('Profile data synced to Firebase successfully');
    } catch (e) {
      log('Error syncing profile to Firebase: $e');
      rethrow;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  // Add a new appointment and sync with Firebase
  Future<void> addAppointment(String patientId) async {
    appointments.add(patientId);
    await saveToPrefs();

    // Update the appointments in Firebase
    final doctorDocRef = FirebaseFirestore.instance
        .collection('doctors')
        .doc(uuid);

    await doctorDocRef.update({
      'appointments': FieldValue.arrayUnion([patientId]),
    });

    notifyListeners();
  }

  // Remove an appointment and sync with Firebase
  Future<void> removeAppointment(String patientId) async {
    appointments.remove(patientId);
    await saveToPrefs();

    // Update the appointments in Firebase
    final doctorDocRef = FirebaseFirestore.instance
        .collection('doctors')
        .doc(uuid);

    await doctorDocRef.update({
      'appointments': FieldValue.arrayRemove([patientId]),
    });

    notifyListeners();
  }

  // Upload profile picture to Firebase Storage and update URLs
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
          .child('doctor_profile_pictures')
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

      // Update the profile picture URL in Firestore
      final doctorDocRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(uuid);
      await doctorDocRef.update({'profilePictureUrl': downloadUrl});

      // Update local provider and persist
      await updateProfilePictureUrl(downloadUrl); // Call the new method here

      log('Profile picture URL updated in provider and Firestore');
    } catch (e) {
      log('Error uploading profile picture: $e');
      rethrow; // Rethrow to allow UI to handle it
    } finally {
      isUploading = false;
      notifyListeners(); // Notify listeners to stop showing loading indicator
    }
  }

  // New method to update profile picture URL and notify listeners
  Future<void> updateProfilePictureUrl(String newUrl) async {
    profilePictureUrl = newUrl;
    await saveToPrefs(); // Persist the new URL
    notifyListeners(); // Notify UI of changes
    log('Profile picture URL updated locally and saved to prefs: $newUrl');
  }

  // Fetch doctor profile from Firebase
  Future<void> fetchProfileFromFirebase() async {
    try {
      final doctorDocRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(uuid);

      final docSnapshot = await doctorDocRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        name = data['name'] ?? '';
        specialization = data['specialization'] ?? '';
        contactNumber = data['contactNumber'] ?? '';
        profilePictureUrl = data['profilePictureUrl'] ?? '';
        myFMCToken = data['fcmToken'] ?? '';

        // Handle createdAt timestamp
        if (data['createdAt'] != null) {
          if (data['createdAt'] is Timestamp) {
            createdAt = (data['createdAt'] as Timestamp).toDate();
          } else if (data['createdAt'] is String) {
            createdAt = DateTime.parse(data['createdAt'] as String);
          }
        }

        // Handle appointments list
        if (data['appointments'] != null && data['appointments'] is List) {
          appointments = List<String>.from(data['appointments'] as List);
        }

        // Save fetched data to local storage
        await saveToPrefs();

        log('Profile fetched from Firebase successfully');
      } else {
        log('Doctor document does not exist in Firestore');
      }
    } catch (e) {
      log('Error fetching profile from Firebase: $e');
    }

    notifyListeners();
  }

  // Refresh data from both local storage and Firebase
  Future<void> refreshData() async {
    await loadFromPrefs();
    await fetchProfileFromFirebase();
    notifyListeners();
  }

  // Create doctor account in Firebase Auth and Firestore
  Future<void> createDoctorAccount(String email, String password) async {
    isUploading = true;
    notifyListeners();

    try {
      // Note: You'll need to implement the actual Firebase Auth integration here
      // This is just a placeholder for the Firestore document creation

      final doctorDocRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(uuid);

      // Get FCM token
      myFMCToken = await NotificationService.getFCMToken();

      // Create the doctor document
      await doctorDocRef.set({
        'name': name,
        'specialization': specialization,
        'contactNumber': contactNumber,
        'profilePictureUrl': profilePictureUrl,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'fcmToken': myFMCToken,
        'appointments': appointments,
      });

      // Save to local storage
      await saveToPrefs();

      log('Doctor account created successfully');
    } catch (e) {
      log('Error creating doctor account: $e');
      rethrow;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  // Check if a doctor exists by phone number
  Future<bool> checkDoctorExists(String phone) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('doctors')
              .where('contactNumber', isEqualTo: phone)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking if doctor exists: $e');
      return false;
    }
  }

  // Authenticate doctor by phone and password
  Future<bool> authenticateDoctor(String phone, String password) async {
    try {
      // Note: This is a simplified example. In a real app, you'd want to use Firebase Auth
      // for secure authentication instead of storing passwords in Firestore

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('doctors')
              .where('contactNumber', isEqualTo: phone)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doctorData = querySnapshot.docs.first.data();
        final storedPassword = doctorData['password'] as String?;

        // In a real app, you'd compare hashed passwords here
        if (storedPassword == password) {
          // Update the UUID to match the one from Firebase
          uuid = querySnapshot.docs.first.id;

          // Fetch the full profile
          await fetchProfileFromFirebase();

          return true;
        }
      }

      return false;
    } catch (e) {
      log('Error authenticating doctor: $e');
      return false;
    }
  }
}
