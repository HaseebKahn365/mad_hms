import 'package:flutter/material.dart';
import 'package:mad_hms/patient/profile.dart';
import 'package:provider/provider.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _titles = ['Doctors', 'Medicines', 'Profile'];

  @override
  void initState() {
    super.initState();

    //read the patient provider and fetch the patient data by loadFromPrefs

    Provider.of<PatientProfileProvider>(context, listen: false).loadFromPrefs();
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
          DoctorsAvailable(),
          // Medicines Tab
          Medicines(),
          // Profile Tab
          PatientProfile(),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Doctors'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        selectedItemColor:
            Theme.of(
              context,
            ).colorScheme.primary, // Set the selected item color
        unselectedItemColor: Colors.grey, // Set the unselected item color
        // backgroundColor: Colors.white, // Set the background color
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class Medicines extends StatelessWidget {
  const Medicines({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: 10, // Replace with actual medicine count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Medicine ${index + 1}'),
            subtitle: Text('Details'),
            trailing: ElevatedButton(
              onPressed: () {
                // Order Medicine
              },
              child: Text('Order Medicine'),
            ),
          );
        },
      ),
    );
  }
}

class DoctorsAvailable extends StatelessWidget {
  const DoctorsAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: 10, // Replace with actual doctor count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Doctor ${index + 1}'),
            subtitle: Text('Specialization'),
            trailing: ElevatedButton(
              onPressed: () {
                // Book Appointment
              },
              child: Text('Book Appointment'),
            ),
          );
        },
      ),
    );
  }
}

class PatientServices extends StatelessWidget {
  const PatientServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to My Services',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to services page
            },
            child: Text('View Services'),
          ),
        ],
      ),
    );
  }
}
