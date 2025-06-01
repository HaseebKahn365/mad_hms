import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:mad_hms/registration/doctor_registration/doctor_provider.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class DoctorRegistration extends StatelessWidget {
  final VoidCallback onAuthenticated;
  const DoctorRegistration({super.key, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Registration'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [Tab(text: 'Login'), Tab(text: 'Sign Up')],
          ),
        ),
        body: TabBarView(
          children: [
            // Login Tab
            Center(child: LoginView(onAuthenticated: onAuthenticated)),
            // Sign Up Tab
            Center(child: RegistrationView(onAuthenticated: onAuthenticated)),
          ],
        ),
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  LoginView({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for login fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> authenticateDoctor(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    // Hash the entered password using sha1
    final bytes = utf8.encode(password);
    final hashedPassword = sha1.convert(bytes).toString();
    log('Hashed password: $hashedPassword');

    // Query Firestore for the doctor with the provided phone number
    final doctorDoc =
        await FirebaseFirestore.instance
            .collection('doctors')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

    if (doctorDoc.docs.isNotEmpty) {
      // Document exists, check the password
      final doctorData = doctorDoc.docs.first.data();
      final dbHashedPswd = doctorData['password'] as String;
      return hashedPassword == dbHashedPswd;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Use TapDebouncer to avoid multiple clicks
                TapDebouncer(
                  onTap: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final phone = phoneController.text.trim();
                      final password = passwordController.text.trim();

                      final isAuthenticated = await authenticateDoctor(
                        phone,
                        password,
                      );
                      if (isAuthenticated) {
                        onAuthenticated();
                      } else {
                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Invalid credentials. Please try again.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  builder: (BuildContext context, TapDebouncerFunc? onTap) {
                    return ElevatedButton(
                      onPressed: onTap,
                      child: const Text('Login & Go to Home'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RegistrationView extends StatelessWidget {
  RegistrationView({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for registration fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerDoctor(
    String name,
    String specialization,
    String phone,
    String password,
    BuildContext context,
  ) async {
    // Hash the password using sha1
    final bytes = utf8.encode(password);
    final hashedPassword = sha1.convert(bytes).toString();
    log('Hashed password: $hashedPassword');

    final doctorProvider = Provider.of<DoctorProfileProvider>(
      context,
      listen: false,
    );

    try {
      // Check if doctor with this phone already exists
      final existingDoctors =
          await FirebaseFirestore.instance
              .collection('doctors')
              .where('phone', isEqualTo: phone)
              .get();

      if (existingDoctors.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A doctor with this phone number already exists'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create a new doctor document in Firestore
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorProvider.uuid)
          .set({
            'name': name,
            'specialization': specialization,
            'phone': phone,
            'password': hashedPassword,
            'profilePictureUrl': doctorProvider.profilePictureUrl,
            'createdAt': Timestamp.now(),
          }, SetOptions(merge: true));

      // Update the doctorProvider with the new data
      doctorProvider.name = name;
      doctorProvider.specialization = specialization;
      doctorProvider.contactNumber = phone;

      // Save to shared preferences
      await doctorProvider.saveToPrefs();

      // Navigate to home page
      onAuthenticated();
    } catch (e) {
      log('Error registering doctor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering doctor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: specializationController,
                    decoration: InputDecoration(
                      hintText: 'Specialization (e.g., Cardiology, Pediatrics)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Specialization is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Use TapDebouncer to avoid multiple clicks
                  TapDebouncer(
                    onTap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final name = nameController.text.trim();
                        final specialization =
                            specializationController.text.trim();
                        final phone = phoneController.text.trim();
                        final password = passwordController.text.trim();

                        await registerDoctor(
                          name,
                          specialization,
                          phone,
                          password,
                          context,
                        );
                      }
                    },
                    builder: (BuildContext context, TapDebouncerFunc? onTap) {
                      return ElevatedButton(
                        onPressed: onTap,
                        child: const Text('Sign Up'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Navigate to the login tab
              DefaultTabController.of(context).animateTo(0);
            },
            child: const Text('Already have an account? Login'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
