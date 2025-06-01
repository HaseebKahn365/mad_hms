import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mad_hms/doctor/doctor_profile.dart';
import 'package:mad_hms/registration/doctor_registration/doctor_provider.dart';
import 'package:provider/provider.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _titles = ['My Dashboard', 'Patients', 'Profile'];

  @override
  void initState() {
    super.initState();
    // Load the doctor profile data
    Provider.of<DoctorProfileProvider>(context, listen: false).loadFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Appointments Tab
          DoctorAppointments(),
          // Patients Tab
          PatientsList(),
          // Profile Tab
          DoctorProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Use fixed for 4+ items
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class DoctorDashboard extends StatelessWidget {
  DoctorDashboard({super.key});

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // Get doctor info from provider
    final doctorProvider = Provider.of<DoctorProfileProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor welcome card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Dr. ${doctorProvider.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Specialization: ${doctorProvider.specialization}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoCard(
                        context,
                        Icons.people,
                        'Patients',
                        '${doctorProvider.appointments.length}',
                      ),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                        context,
                        Icons.calendar_today,
                        'Today\'s Appointments',
                        '0', // This would be calculated from appointments
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                Icons.add_circle,
                'New Appointment',
                () {
                  // Navigate to appointments page
                  _pageController.animateToPage(
                    1, // Appointments tab index
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              _buildActionButton(context, Icons.person_add, 'Add Patient', () {
                // Show add patient dialog
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Feature Coming Soon'),
                        content: const Text(
                          'Patient addition will be available in a future update.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }),
              _buildActionButton(context, Icons.edit_note, 'Edit Profile', () {
                // Navigate to profile page
                _pageController.animateToPage(
                  3, // Profile tab index
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          // Recent activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Sample recent activities
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.event_note, color: Colors.white),
                  ),
                  title: Text('Activity ${index + 1}'),
                  subtitle: Text('Patient appointment updated 2 hours ago'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show activity details
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorAppointments extends StatelessWidget {
  const DoctorAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProfileProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selector and filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date indicator
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Today', // This would be dynamic
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              // Filter button
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  // Show filter options
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Appointment stats
          Row(
            children: [
              _buildAppointmentStat(
                context,
                'Total',
                '${doctorProvider.appointments.length + doctorProvider.doneAppointments}',
                Colors.blue,
              ),
              _buildAppointmentStat(
                context,
                'Upcoming',
                '${doctorProvider.appointments.length}', // Would be calculated
                Colors.orange,
              ),
              _buildAppointmentStat(
                context,
                'Completed',
                '${doctorProvider.doneAppointments}', // Would be calculated
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Appointments list
          Text('Appointments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(
            child:
                doctorProvider.appointments.isEmpty
                    ? _buildEmptyAppointments(context)
                    : ListView.builder(
                      itemCount: doctorProvider.appointments.length,
                      itemBuilder: (context, index) {
                        final patientId = doctorProvider.appointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueGrey.shade100,
                              child: const Icon(Icons.person),
                            ),
                            title: Text('Patient ID: $patientId'),
                            subtitle: Text('Appointment time not set'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.videocam),
                                  onPressed: () {
                                    // Start video call
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    // Show options
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // Show appointment details
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentStat(
    BuildContext context,
    String title,
    String count,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                count,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointments(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Your appointments will appear here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class PatientsList extends StatefulWidget {
  const PatientsList({super.key});

  @override
  State<PatientsList> createState() => _PatientsListState();
}

class _PatientsListState extends State<PatientsList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Patients list
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('patients').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients found',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final patients =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] ?? '').toString().toLowerCase();
                      return _searchText.isEmpty || name.contains(_searchText);
                    }).toList();

                if (patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients found',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient =
                        patients[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              patient['profilePictureUrl'] != null &&
                                      patient['profilePictureUrl']
                                          .toString()
                                          .isNotEmpty
                                  ? NetworkImage(patient['profilePictureUrl'])
                                      as ImageProvider
                                  : const AssetImage('assets/images/logo.jpg'),
                        ),
                        title: Text(patient['name'] ?? 'Unknown'),
                        subtitle: Text('Age: ${patient['age'] ?? 'N/A'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.medical_services),
                          onPressed: () {
                            // Show patient medical history
                          },
                        ),
                        onTap: () {
                          // Show patient details
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(
                                    patient['name'] ?? 'Patient Details',
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phone: ${patient['contactNumber'] ?? 'N/A'}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Description: ${patient['description'] ?? 'N/A'}',
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Add as appointment
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Add Appointment'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
