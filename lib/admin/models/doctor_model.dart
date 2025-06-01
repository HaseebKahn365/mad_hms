// Doctor model class for handling doctor data
import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String contactNumber;
  final String specialization;
  final String fcmToken;
  final String myFMCToken;
  final String password;
  final String phone;
  final String profilePictureUrl;
  final DateTime createdAt;
  final List<String> appointments;

  Doctor({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.specialization,
    required this.fcmToken,
    required this.myFMCToken,
    required this.password,
    required this.phone,
    required this.profilePictureUrl,
    required this.createdAt,
    required this.appointments,
  });

  // Factory constructor to create a Doctor from a Firestore document
  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Doctor(
      id: doc.id,
      name: data['name'] ?? '',
      contactNumber: data['contactNumber'] ?? data['phone'] ?? '',
      specialization: data['specialization'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
      myFMCToken: data['myFMCToken'] ?? '',
      password: data['password'] ?? '',
      phone: data['phone'] ?? data['contactNumber'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      appointments: List<String>.from(data['appointments'] ?? []),
    );
  }

  // Convert Doctor to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactNumber': contactNumber,
      'specialization': specialization,
      'fcmToken': fcmToken,
      'myFMCToken': myFMCToken,
      'password': password,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'appointments': appointments,
    };
  }

  // Create a copy of the Doctor with specified fields updated
  Doctor copyWith({
    String? name,
    String? contactNumber,
    String? specialization,
    String? fcmToken,
    String? myFMCToken,
    String? password,
    String? phone,
    String? profilePictureUrl,
    DateTime? createdAt,
    List<String>? appointments,
  }) {
    return Doctor(
      id: id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      specialization: specialization ?? this.specialization,
      fcmToken: fcmToken ?? this.fcmToken,
      myFMCToken: myFMCToken ?? this.myFMCToken,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      appointments: appointments ?? this.appointments,
    );
  }
}
