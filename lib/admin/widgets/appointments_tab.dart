// Appointments tab widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../models/patient_model.dart';
import '../services/admin_data_service.dart';

class AppointmentsTab extends StatelessWidget {
  final AdminDataService dataService;

  const AppointmentsTab({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: dataService.appointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return const Center(child: Text('No appointments found'));
        }

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];

            // Create status color
            Color statusColor;
            switch (appointment.status) {
              case 'confirmed':
                statusColor = Colors.green;
                break;
              case 'cancelled':
                statusColor = Colors.red;
                break;
              case 'completed':
                statusColor = Colors.blue;
                break;
              case 'pending':
              default:
                statusColor = Colors.orange;
                break;
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor,
                  child: Icon(
                    _getIconForStatus(appointment.status),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(appointment.date),
                ),
                subtitle: Text(
                  'Status: ${appointment.status}',
                  style: TextStyle(color: statusColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed:
                      () => _confirmDeleteAppointment(context, appointment),
                ),
                onTap: () => _showAppointmentDetails(context, appointment),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      case 'pending':
      default:
        return Icons.pending;
    }
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    // Fetch patient and doctor data for this appointment
    _fetchPatientAndDoctor(appointment).then((data) {
      final Patient? patient = data['patient'];
      final Doctor? doctor = data['doctor'];

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Appointment on ${DateFormat('MMM dd, yyyy').format(appointment.date)}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _detailRow('ID', appointment.id),
                    _detailRow(
                      'Date',
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(appointment.date),
                    ),
                    _detailRow('Status', appointment.status),
                    _detailRow('Notes', appointment.notes),
                    _detailRow(
                      'Created At',
                      DateFormat('MMM dd, yyyy').format(appointment.createdAt),
                    ),
                    const Divider(),
                    _detailRow('Patient ID', appointment.patientId),
                    if (patient != null)
                      _detailRow('Patient Name', patient.name),
                    const Divider(),
                    _detailRow('Doctor ID', appointment.doctorId),
                    if (doctor != null) _detailRow('Doctor Name', doctor.name),
                    if (doctor != null)
                      _detailRow('Specialization', doctor.specialization),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                _buildStatusChangeButton(context, appointment),
              ],
            ),
      );
    });
  }

  Widget _buildStatusChangeButton(
    BuildContext context,
    Appointment appointment,
  ) {
    return TextButton(
      onPressed: () {
        _showStatusChangeDialog(context, appointment);
      },
      child: const Text('Change Status'),
    );
  }

  void _showStatusChangeDialog(BuildContext context, Appointment appointment) {
    final statusOptions = ['pending', 'confirmed', 'cancelled', 'completed'];
    String selectedStatus = appointment.status;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Appointment Status'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      statusOptions
                          .map(
                            (status) => RadioListTile<String>(
                              title: Text(status),
                              value: status,
                              groupValue: selectedStatus,
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value!;
                                });
                              },
                            ),
                          )
                          .toList(),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Update appointment with new status
                  final updatedAppointment = appointment.copyWith(
                    status: selectedStatus,
                  );
                  dataService.updateAppointment(updatedAppointment);
                  Navigator.of(context).pop(); // Close status dialog
                  Navigator.of(context).pop(); // Close details dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Appointment status updated to $selectedStatus',
                      ),
                    ),
                  );
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  Future<Map<String, dynamic>> _fetchPatientAndDoctor(
    Appointment appointment,
  ) async {
    Patient? patient;
    Doctor? doctor;

    try {
      final patientDoc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(appointment.patientId)
              .get();

      if (patientDoc.exists) {
        patient = Patient.fromFirestore(patientDoc);
      }

      final doctorDoc =
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(appointment.doctorId)
              .get();

      if (doctorDoc.exists) {
        doctor = Doctor.fromFirestore(doctorDoc);
      }
    } catch (e) {
      print('Error fetching patient or doctor: $e');
    }

    return {'patient': patient, 'doctor': doctor};
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDeleteAppointment(
    BuildContext context,
    Appointment appointment,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Appointment'),
            content: Text(
              'Are you sure you want to delete this appointment on ${DateFormat('MMM dd, yyyy').format(appointment.date)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  dataService.deleteAppointment(appointment.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment deleted')),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
