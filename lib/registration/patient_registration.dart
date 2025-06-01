import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class PatientRegistration extends StatelessWidget {
  final VoidCallback onAuthenticated;
  const PatientRegistration({super.key, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [Tab(text: 'Login'), Tab(text: 'Sign Up')],
          ),
        ),
        body: TabBarView(
          children: [
            // Login Tab
            Center(child: LoginView(onAuthenticated: onAuthenticated)),
            // Sign Up Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Patient Sign Up Page'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onAuthenticated,
                    child: const Text('Sign Up & Go to Home'),
                  ),
                ],
              ),
            ),
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

  //login the patient via only Phone Number and password

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> authenticatePatient(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // look for all documents in the patients collection where phone is equal to phone

    // Hash the entered password using sha1
    final bytes = utf8.encode(password);
    final hashedPassword = sha1.convert(bytes).toString();
    log('Hashed password: $hashedPassword');
    //fetch teh document from the where phone is equal to phone
    final patientDoc =
        await FirebaseFirestore.instance
            .collection('patients')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

    if (patientDoc.docs.isNotEmpty) {
      // Document exists, now check the password

      //apply sha1 to password
      // Use bcrypt to hash and compare the password

      final patientData = patientDoc.docs.first.data();
      final dbHashedPswd = patientData['password'] as String;
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

                      final isAuthenticated = await authenticatePatient(
                        phone,
                        password,
                      );
                      if (isAuthenticated) {
                        onAuthenticated();
                      } else {
                        // Show an error message
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
