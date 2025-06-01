// Patients tab widget
import 'package:flutter/material.dart';

import '../models/patient_model.dart';
import '../services/admin_data_service.dart';

class PatientsTab extends StatelessWidget {
  final AdminDataService dataService;

  const PatientsTab({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Patient>>(
      stream: dataService.patientsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final patients = snapshot.data ?? [];

        if (patients.isEmpty) {
          return const Center(child: Text('No patients found'));
        }

        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      patient.profilePictureUrl.isNotEmpty
                          ? NetworkImage(patient.profilePictureUrl)
                          : null,
                  child:
                      patient.profilePictureUrl.isEmpty
                          ? Text(
                            patient.name.isNotEmpty ? patient.name[0] : '?',
                          )
                          : null,
                ),
                title: Text(patient.name),
                subtitle: Text('Age: ${patient.age} | Phone: ${patient.phone}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${patient.appointments.length} appointments'),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeletePatient(context, patient),
                    ),
                  ],
                ),
                onTap: () => _showPatientDetails(context, patient),
              ),
            );
          },
        );
      },
    );
  }

  void _showPatientDetails(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(patient.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (patient.profilePictureUrl.isNotEmpty)
                    Center(
                      child: Image.network(
                        patient.profilePictureUrl,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _detailRow('ID', patient.id),
                  _detailRow('Age', patient.age.toString()),
                  _detailRow('Phone', patient.phone),
                  _detailRow('Contact Number', patient.contactNumber),
                  _detailRow('Description', patient.description),
                  _detailRow('Created At', patient.createdAt.toString()),
                  _detailRow(
                    'Appointments',
                    patient.appointments.length.toString(),
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

  void _confirmDeletePatient(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Patient'),
            content: Text(
              'Are you sure you want to delete ${patient.name}? This will also delete all related appointments.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  dataService.deletePatient(patient.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Patient ${patient.name} deleted')),
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
