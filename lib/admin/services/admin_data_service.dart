// Data service for handling Firestore operations
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mad_hms/admin/models/appointment_model.dart';
import 'package:mad_hms/admin/models/doctor_model.dart';
import 'package:mad_hms/admin/models/patient_model.dart';
import 'package:uuid/uuid.dart';

class AdminDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Random _random = Random();
  final List<String> _specializations = [
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'Neurology',
    'Oncology',
    'Pediatrics',
    'Psychiatry',
    'Orthopedics',
    'Urology',
  ];

  // Stream of patients
  Stream<List<Patient>> get patientsStream {
    return _firestore
        .collection('patients')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList(),
        );
  }

  // Stream of doctors
  Stream<List<Doctor>> get doctorsStream {
    return _firestore
        .collection('doctors')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList(),
        );
  }

  // Stream of appointments
  Stream<List<Appointment>> get appointmentsStream {
    return _firestore
        .collection('appointments')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Appointment.fromFirestore(doc))
                  .toList(),
        );
  }

  // Create a new patient
  Future<String> createPatient(Patient patient) async {
    final patientRef = await _firestore
        .collection('patients')
        .add(patient.toMap());
    return patientRef.id;
  }

  // Create a new doctor
  Future<String> createDoctor(Doctor doctor) async {
    final doctorRef = await _firestore
        .collection('doctors')
        .add(doctor.toMap());
    return doctorRef.id;
  }

  // Create a new appointment
  Future<String> createAppointment(Appointment appointment) async {
    final appointmentRef = await _firestore
        .collection('appointments')
        .add(appointment.toMap());

    // Update the doctor's and patient's appointments list
    await _firestore.collection('doctors').doc(appointment.doctorId).update({
      'appointments': FieldValue.arrayUnion([appointmentRef.id]),
    });

    await _firestore.collection('patients').doc(appointment.patientId).update({
      'appointments': FieldValue.arrayUnion([appointmentRef.id]),
    });

    return appointmentRef.id;
  }

  // Update a patient
  Future<void> updatePatient(Patient patient) async {
    await _firestore
        .collection('patients')
        .doc(patient.id)
        .update(patient.toMap());
  }

  // Update a doctor
  Future<void> updateDoctor(Doctor doctor) async {
    await _firestore
        .collection('doctors')
        .doc(doctor.id)
        .update(doctor.toMap());
  }

  // Update an appointment
  Future<void> updateAppointment(Appointment appointment) async {
    await _firestore
        .collection('appointments')
        .doc(appointment.id)
        .update(appointment.toMap());
  }

  // Delete a patient
  Future<void> deletePatient(String patientId) async {
    // First get the patient to find all appointments
    final patient =
        await _firestore.collection('patients').doc(patientId).get();
    final appointments = List<String>.from(
      patient.data()?['appointments'] ?? [],
    );

    // Delete all appointments related to this patient
    for (var appointmentId in appointments) {
      await _firestore.collection('appointments').doc(appointmentId).delete();

      // Remove appointment from doctor's list
      final appointment =
          await _firestore.collection('appointments').doc(appointmentId).get();
      if (appointment.exists) {
        final doctorId = appointment.data()?['doctorId'];
        if (doctorId != null) {
          await _firestore.collection('doctors').doc(doctorId).update({
            'appointments': FieldValue.arrayRemove([appointmentId]),
          });
        }
      }
    }

    // Delete the patient
    await _firestore.collection('patients').doc(patientId).delete();

    // Delete profile picture if it exists
    final profilePictureUrl = patient.data()?['profilePictureUrl'];
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(profilePictureUrl).delete();
      } catch (e) {
        // Ignore error if the file doesn't exist
      }
    }
  }

  // Delete a doctor
  Future<void> deleteDoctor(String doctorId) async {
    // First get the doctor to find all appointments
    final doctor = await _firestore.collection('doctors').doc(doctorId).get();
    final appointments = List<String>.from(
      doctor.data()?['appointments'] ?? [],
    );

    // Delete all appointments related to this doctor
    for (var appointmentId in appointments) {
      await _firestore.collection('appointments').doc(appointmentId).delete();

      // Remove appointment from patient's list
      final appointment =
          await _firestore.collection('appointments').doc(appointmentId).get();
      if (appointment.exists) {
        final patientId = appointment.data()?['patientId'];
        if (patientId != null) {
          await _firestore.collection('patients').doc(patientId).update({
            'appointments': FieldValue.arrayRemove([appointmentId]),
          });
        }
      }
    }

    // Delete the doctor
    await _firestore.collection('doctors').doc(doctorId).delete();

    // Delete profile picture if it exists
    final profilePictureUrl = doctor.data()?['profilePictureUrl'];
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(profilePictureUrl).delete();
      } catch (e) {
        // Ignore error if the file doesn't exist
      }
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String appointmentId) async {
    // Get the appointment to find the doctor and patient
    final appointment =
        await _firestore.collection('appointments').doc(appointmentId).get();
    if (appointment.exists) {
      final doctorId = appointment.data()?['doctorId'];
      final patientId = appointment.data()?['patientId'];

      // Remove appointment from doctor's list
      if (doctorId != null) {
        await _firestore.collection('doctors').doc(doctorId).update({
          'appointments': FieldValue.arrayRemove([appointmentId]),
        });
      }

      // Remove appointment from patient's list
      if (patientId != null) {
        await _firestore.collection('patients').doc(patientId).update({
          'appointments': FieldValue.arrayRemove([appointmentId]),
        });
      }
    }

    // Delete the appointment
    await _firestore.collection('appointments').doc(appointmentId).delete();
  }

  // Generate mock data for patients
  Future<void> generateMockPatients(int count, List<String> randomNames) async {
    for (int i = 0; i < count; i++) {
      final name = randomNames[_random.nextInt(randomNames.length)];
      final age = _random.nextInt(70) + 18; // Random age between 18 and 87
      final phone =
          '+92${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}';

      // Hash the password (using a simple password for mock data)
      final password = "password123";
      final hashedPassword = sha1.convert(utf8.encode(password)).toString();

      final patient = Patient(
        id: const Uuid().v4(),
        name: name,
        age: age,
        contactNumber: phone,
        description: 'Patient description for $name',
        myFACToken: '',
        password: hashedPassword,
        phone: phone,
        profilePictureUrl: '',
        createdAt: DateTime.now().subtract(
          Duration(days: _random.nextInt(365)),
        ),
        appointments: [],
      );

      await _firestore
          .collection('patients')
          .doc(patient.id)
          .set(patient.toMap());
    }
  }

  // Generate mock data for doctors
  Future<void> generateMockDoctors(int count, List<String> randomNames) async {
    for (int i = 0; i < count; i++) {
      final name = randomNames[_random.nextInt(randomNames.length)];
      final specialization =
          _specializations[_random.nextInt(_specializations.length)];
      final phone =
          '+92${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}${_random.nextInt(10)}';

      // Hash the password (using a simple password for mock data)
      final password = "password123";
      final hashedPassword = sha1.convert(utf8.encode(password)).toString();

      final doctor = Doctor(
        id: const Uuid().v4(),
        name: name,
        contactNumber: phone,
        specialization: specialization,
        fcmToken: '',
        myFMCToken: '',
        password: hashedPassword,
        phone: phone,
        profilePictureUrl: '',
        createdAt: DateTime.now().subtract(
          Duration(days: _random.nextInt(365)),
        ),
        appointments: [],
      );

      await _firestore.collection('doctors').doc(doctor.id).set(doctor.toMap());
    }
  }

  // Generate mock appointments
  Future<void> generateMockAppointments(int count) async {
    // Get all patients and doctors
    final patients = await _firestore.collection('patients').get();
    final doctors = await _firestore.collection('doctors').get();

    if (patients.docs.isEmpty || doctors.docs.isEmpty) {
      return; // Can't create appointments without patients and doctors
    }

    final statusOptions = ['pending', 'confirmed', 'cancelled', 'completed'];

    for (int i = 0; i < count; i++) {
      final patientDoc = patients.docs[_random.nextInt(patients.docs.length)];
      final doctorDoc = doctors.docs[_random.nextInt(doctors.docs.length)];

      final patientId = patientDoc.id;
      final doctorId = doctorDoc.id;

      // Create a random date in the next 60 days
      final date = DateTime.now().add(
        Duration(
          days: _random.nextInt(60),
          hours: _random.nextInt(12) + 8, // Between 8am and 8pm
        ),
      );

      final status = statusOptions[_random.nextInt(statusOptions.length)];

      final appointmentId = const Uuid().v4();
      final appointment = Appointment(
        id: appointmentId,
        patientId: patientId,
        doctorId: doctorId,
        date: date,
        status: status,
        notes: 'Appointment notes for patient and doctor consultation',
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      );

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .set(appointment.toMap());

      // Update patient and doctor with this appointment
      await _firestore.collection('patients').doc(patientId).update({
        'appointments': FieldValue.arrayUnion([appointmentId]),
      });

      await _firestore.collection('doctors').doc(doctorId).update({
        'appointments': FieldValue.arrayUnion([appointmentId]),
      });
    }
  }
}
