// Doctors tab widget
import 'package:flutter/material.dart';

import '../models/doctor_model.dart';
import '../services/admin_data_service.dart';

class DoctorsTab extends StatelessWidget {
  final AdminDataService dataService;

  const DoctorsTab({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Doctor>>(
      stream: dataService.doctorsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final doctors = snapshot.data ?? [];

        if (doctors.isEmpty) {
          return const Center(child: Text('No doctors found'));
        }

        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      doctor.profilePictureUrl.isNotEmpty
                          ? NetworkImage(doctor.profilePictureUrl)
                          : null,
                  child:
                      doctor.profilePictureUrl.isEmpty
                          ? Text(doctor.name.isNotEmpty ? doctor.name[0] : '?')
                          : null,
                ),
                title: Text(doctor.name),
                subtitle: Text(
                  'Specialization: ${doctor.specialization} | Phone: ${doctor.phone}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${doctor.appointments.length} appointments'),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteDoctor(context, doctor),
                    ),
                  ],
                ),
                onTap: () => _showDoctorDetails(context, doctor),
              ),
            );
          },
        );
      },
    );
  }

  void _showDoctorDetails(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(doctor.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (doctor.profilePictureUrl.isNotEmpty)
                    Center(
                      child: Image.network(
                        doctor.profilePictureUrl,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _detailRow('ID', doctor.id),
                  _detailRow('Specialization', doctor.specialization),
                  _detailRow('Phone', doctor.phone),
                  _detailRow('Contact Number', doctor.contactNumber),
                  _detailRow('Created At', doctor.createdAt.toString()),
                  _detailRow(
                    'Appointments',
                    doctor.appointments.length.toString(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
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

  void _confirmDeleteDoctor(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Doctor'),
            content: Text(
              'Are you sure you want to delete ${doctor.name}? This will also delete all related appointments.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  dataService.deleteDoctor(doctor.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Doctor ${doctor.name} deleted')),
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
