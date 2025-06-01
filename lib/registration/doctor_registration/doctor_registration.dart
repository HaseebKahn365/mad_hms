import 'package:flutter/material.dart';

class DoctorRegistration extends StatelessWidget {
  final VoidCallback onAuthenticated;
  const DoctorRegistration({super.key, required this.onAuthenticated});

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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Doctor Login Page'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onAuthenticated,
                    child: const Text('Login & Go to Home'),
                  ),
                ],
              ),
            ),
            // Sign Up Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Doctor Sign Up Page'),
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
