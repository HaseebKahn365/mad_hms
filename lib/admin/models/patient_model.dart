// Patient model class for handling patient data
import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String contactNumber;
  final String description;
  final String myFACToken;
  final String password;
  final String phone;
  final String profilePictureUrl;
  final DateTime createdAt;
  final List<String> appointments;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.contactNumber,
    required this.description,
    required this.myFACToken,
    required this.password,
    required this.phone,
    required this.profilePictureUrl,
    required this.createdAt,
    required this.appointments,
  });

  // Factory constructor to create a Patient from a Firestore document
  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      contactNumber: data['contactNumber'] ?? data['phone'] ?? '',
      description: data['description'] ?? '',
      myFACToken: data['myFACToken'] ?? '',
      password: data['password'] ?? '',
      phone: data['phone'] ?? data['contactNumber'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      appointments: List<String>.from(data['appointments'] ?? []),
    );
  }

  // Convert Patient to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'contactNumber': contactNumber,
      'description': description,
      'myFACToken': myFACToken,
      'password': password,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'appointments': appointments,
    };
  }

  // Create a copy of the Patient with specified fields updated
  Patient copyWith({
    String? name,
    int? age,
    String? contactNumber,
    String? description,
    String? myFACToken,
    String? password,
    String? phone,
    String? profilePictureUrl,
    DateTime? createdAt,
    List<String>? appointments,
  }) {
    return Patient(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      myFACToken: myFACToken ?? this.myFACToken,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      appointments: appointments ?? this.appointments,
    );
  }
}
