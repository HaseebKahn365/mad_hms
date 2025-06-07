import 'package:flutter/material.dart';
import 'package:mad_hms/notifications/notification_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Appointments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [DocProfile(), DocAppointments()],
      ),
    );
  }
}

class DocProfile extends StatelessWidget {
  const DocProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 75,
              backgroundImage: NetworkImage(
                'https://th.bing.com/th/id/OIP.TYzWK2HqKaqczU98GKeshQHaHZ?rs=1&pid=ImgDetMain',
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Dr. Harry Potter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Wizarding Medicine',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Consultation Fee:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text('Rs.12,500', style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'About Me:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              "As someone who has battled dementors and diagnosed tricky magical maladies, I, Dr. Harry Potter, bring a unique blend of bravery and brilliance to the wizarding world of medicine.",

              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DocAppointments extends StatelessWidget {
  const DocAppointments({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           //show
  //           Container(
  //             //border
  //             decoration: BoxDecoration(
  //               border: Border.all(color: Colors.indigo, width: 2),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             width: double.infinity,
  //             padding: const EdgeInsets.all(20),

  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 //Request from:
  //                 Row(
  //                   children: [
  //                     const CircleAvatar(
  //                       radius: 50,
  //                       child: Text('A', style: TextStyle(fontSize: 24)),
  //                     ),
  //                     const SizedBox(width: 16),
  //                     const Text(
  //                       'Arooba Zamir',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 // Appointment Details
  //                 const Text(
  //                   'Appointment Request',
  //                   style: TextStyle(
  //                     fontSize: 22,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.indigo,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 _buildDetailItem(
  //                   Icons.calendar_today,
  //                   'Date',
  //                   'June 15, 2023',
  //                 ),
  //                 _buildDetailItem(Icons.access_time, 'Time', '10:30 AM'),
  //                 _buildDetailItem(
  //                   Icons.location_on,
  //                   'Location',
  //                   'Swabi, KPK, Pakistan',
  //                 ),
  //                 _buildDetailItem(Icons.email, 'Email', 'Arooba@gmail.com'),
  //                 const SizedBox(height: 5),

  //                 //issue
  //                 _buildDetailItem(
  //                   Icons.description,
  //                   'Issue',
  //                   'severe headaches',
  //                 ),
  //                 const SizedBox(height: 5),

  //                 // Action Buttons
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text('Appointment Accepted!'),
  //                               backgroundColor: Colors.green,
  //                             ),
  //                           );
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.green,
  //                           padding: const EdgeInsets.symmetric(vertical: 16),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                         ),
  //                         child: const Text(
  //                           'Accept',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 16),
  //                     Expanded(
  //                       child: OutlinedButton(
  //                         onPressed: () {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text('Appointment Rejected'),
  //                               backgroundColor: Colors.red,
  //                             ),
  //                           );
  //                         },
  //                         style: OutlinedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(vertical: 16),
  //                           side: const BorderSide(color: Colors.red),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                         ),
  //                         child: const Text(
  //                           'Reject',
  //                           style: TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.red,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  // Add notification feature to the Accept button
  Widget build(BuildContext context) {
    // Text controller for FCM token input
    final TextEditingController tokenController = TextEditingController();
    String patientName = 'Arooba Zamir';
    String appointmentDate = 'June 15, 2023';
    String appointmentTime = '10:30 AM';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient FCM token input field
              Container(
                //border
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Request from:
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Text('A', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Arooba Zamir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Appointment Details
                    const Text(
                      'Appointment Request',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      Icons.calendar_today,
                      'Date',
                      'June 15, 2023',
                    ),
                    _buildDetailItem(Icons.access_time, 'Time', '10:30 AM'),
                    _buildDetailItem(
                      Icons.location_on,
                      'Location',
                      'Swabi, KPK, Pakistan',
                    ),
                    _buildDetailItem(Icons.email, 'Email', 'Arooba@gmail.com'),
                    const SizedBox(height: 5),

                    //issue
                    _buildDetailItem(
                      Icons.description,
                      'Issue',
                      'severe headaches',
                    ),
                    const SizedBox(height: 5),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (tokenController.text.isNotEmpty) {
                                // Send notification when accepting appointment
                                bool success =
                                    await NotificationService.sendNotificationToPatient(
                                      tokenController.text,
                                      'Appointment Accepted',
                                      'Hi Arooba, I Dr. Harry Potter on $appointmentDate at $appointmentTime have accepted your appointment.',
                                      data: {
                                        'doctorName': 'Dr. Harry Potter',
                                        'day': appointmentDate,
                                        'slot': appointmentTime,
                                        'patientName': patientName,
                                      },
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Appointment Accepted! ${success ? "Notification sent." : ""}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Appointment Accepted! (No notification sent - missing token)',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              if (tokenController.text.isNotEmpty) {
                                // Send rejection notification
                                await NotificationService.sendNotificationToPatient(
                                  tokenController.text,
                                  'Appointment Rejected',
                                  'Your appointment request with Dr. Harry Potter on $appointmentDate at $appointmentTime has been rejected.',
                                  data: {
                                    'doctorName': 'Dr. Harry Potter',
                                    'day': appointmentDate,
                                    'slot': appointmentTime,
                                    'status': 'rejected',
                                  },
                                );
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Appointment Rejected'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 200),

              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  labelText: 'Patient FCM Token',
                  hintText: 'Enter patient token to send notification',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (tokenController.text.isNotEmpty) {
                        // Use the notification service to send confirmation
                        bool success =
                            await NotificationService.sendNotificationToPatient(
                              tokenController.text,
                              'Appointment Accepted',
                              'Hi Arooba, I Dr. Harry Potter on $appointmentDate at $appointmentTime have accepted your appointment.',
                              data: {
                                'doctorName': 'Dr. Harry Potter',
                                'day': appointmentDate,
                                'slot': appointmentTime,
                                'patientName': patientName,
                              },
                            );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Notification sent to patient'
                                  : 'Failed to send notification',
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                      } else {}
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
