import 'package:flutter/material.dart';

import 'auth_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

enum AppFor { patient, doctor, admin }

// Global variable to track selected role
AppFor selectedRole = AppFor.patient;

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();

  void _goToAuthPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // First page: Role selection with radio buttons
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Selected Role: ${selectedRole == AppFor.patient
                        ? "Patient"
                        : selectedRole == AppFor.doctor
                        ? "Doctor"
                        : "Admin"}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //role based icon
                  const SizedBox(height: 16),
                  Icon(
                    selectedRole == AppFor.patient
                        ? Icons.person
                        : selectedRole == AppFor.doctor
                        ? Icons.medical_services
                        : Icons.admin_panel_settings,
                    size: 256,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  // Patient Radio Button
                  RadioListTile<AppFor>(
                    title: const Text('Patient'),
                    value: AppFor.patient,
                    groupValue: selectedRole,
                    onChanged: (AppFor? value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  // Doctor Radio Button
                  RadioListTile<AppFor>(
                    title: const Text('Doctor'),
                    value: AppFor.doctor,
                    groupValue: selectedRole,
                    onChanged: (AppFor? value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  // Admin Radio Button
                  RadioListTile<AppFor>(
                    title: const Text('Admin'),
                    value: AppFor.admin,
                    groupValue: selectedRole,
                    onChanged: (AppFor? value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToAuthPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Second page: Auth screen based on selected role
          // Scaffold(
          //   appBar: AppBar(
          //     leading: IconButton(
          //       icon: const Icon(Icons.arrow_back),
          //       onPressed: _goBack,
          //     ),
          //     title: Text(
          //       selectedRole == AppFor.doctor
          //           ? 'Doctor Registration'
          //           : selectedRole == AppFor.admin
          //           ? 'Admin Registration'
          //           : 'Patient Registration',
          //     ),
          //     automaticallyImplyLeading: false,
          //   ),
          //   // body:
          //   //     selectedRole == AppFor.doctor
          //   //         ? DoctorRegistration(onAuthenticated: _goToDoctorHome)
          //   //         : PatientRegistration(onAuthenticated: _goToHome),
          //   // Note: You'll
          // need to add AdminRegistration if needed
          // ),
          AuthScreen(
            role: selectedRole,
            goBack: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
          ),
        ],
      ),
    );
  }
}

//create auth screen here:
