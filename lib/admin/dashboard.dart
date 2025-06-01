import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

//modal class for medicine:
// 3. Medicines : shows a list of medicines with their details and a button to order the medicine.
class Medicine {
  final String id;
  final String name;
  final String description;
  final double price;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  String toString() {
    return 'Medicine{id: $id, name: $name, description: $description, price: $price}';
  }

  // Factory constructor to create a Medicine instance from a map
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
    );
  }

  // Method to convert a Medicine instance to a map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'price': price};
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

  int doneAppointments = 0;

  MockPatient({
    required this.name,
    required this.specialization,
    required this.contactNumber,
    required this.profilePictureUrl,
  });

  // Factory constructor to create a MockPatient instance from a map
  factory MockPatient.fromMap(Map<String, dynamic> map) {
    return MockPatient(
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(child: Text('Welcome to the Admin Dashboard!')),
    );
  }
}
