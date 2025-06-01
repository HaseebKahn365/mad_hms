// create a page view to register the user as a patient or doctor:

/*
Here is how :
the first page view will give user two options to register as a patient or doctor.
which will take user to the respective registration page.
registration page allow the user to either login or signup.
once the user is registered or logged in, it will take the user to the home page using pushReplacement.
 */

import 'package:flutter/material.dart';
import 'package:mad_hms/patient/patient_home.dart';
import 'package:mad_hms/registration/doctor_registration.dart';
import 'package:mad_hms/registration/patient_registration.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

const bool isDoctorApp = true;

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();

  void _goToAuthPage(bool doctor) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _goToHome() {
    // You can handle navigation outside this widget, or pop to root, etc.
    // For now, just show a dialog as a placeholder.
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Authenticated!'),
            content: const Text(
              'You are now logged in. Implement navigation as needed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => PatientHome()),
                  );
                },
                child: const Text('for test'),
              ),
            ],
          ),
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // First page: Choose Patient or Doctor
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_services,
                    size: 120,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Welcome to HMS",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Register as a Patient or Doctor to get started.",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Sexy Patient Button
                  if (!isDoctorApp)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _goToAuthPage(false),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.blueAccent.withOpacity(0.3),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF42A5F5), Color(0xFF478DE0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Register as Patient",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Sexy Doctor Button
                  if (isDoctorApp)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _goToAuthPage(true),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.purpleAccent.withOpacity(0.3),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.medical_information,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Register as Doctor",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Second page: Auth screen with back button
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              ),
              title: Text(
                isDoctorApp ? 'Doctor Registration' : 'Patient Registration',
              ),
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
            ),
            body:
                isDoctorApp
                    ? DoctorRegistration(onAuthenticated: _goToHome)
                    : PatientRegistration(onAuthenticated: _goToHome),
          ),
        ],
      ),
    );
  }
}
