import 'package:flutter/material.dart';

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
  const LoginView({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Patient Login Page'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onAuthenticated,
          child: const Text('Login & Go to Home'),
        ),
      ],
    );
  }
}
