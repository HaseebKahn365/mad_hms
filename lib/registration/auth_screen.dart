import 'package:flutter/material.dart';

import '../registration/registration.dart';

//  AuthScreen(
//             role: selectedRole,
//             goBack: () {
//               _pageController.previousPage(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeIn,
//               );
//             },

class AuthScreen extends StatefulWidget {
  final AppFor role;
  final VoidCallback goBack;

  const AuthScreen({super.key, required this.role, required this.goBack});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

//this app is for Arooba so prefill all the text fields with her data

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(
    text: 'Arooba@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+92317 0846297',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'Arooba@123',
  );
  final TextEditingController _confirmPasswordController =
      TextEditingController(text: 'Arooba@123');

  bool _isSignUp = false; // Toggle between sign up and sign in

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement authentication logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing authentication...')),
      );

      // Navigate to appropriate home screen based on role
      // This will be implemented later
    }
  }

  // Function to handle back navigation
  void _goBack() {
    widget.goBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.role == AppFor.doctor
              ? 'Doctor Authentication'
              : widget.role == AppFor.admin
              ? 'Admin Authentication'
              : 'Patient Authentication',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBack();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Auth mode toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.role == AppFor.admin
                            ? 'Admin Acsess Password.'
                            : _isSignUp
                            ? 'Sign Up'
                            : 'Sign In',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Fields based on role
                  if (widget.role != AppFor.admin) ...[
                    // Email field for patient and doctor
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone field for patient and doctor (sign-up only)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Password field for all roles
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (_isSignUp && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field (sign-up only and not for admin)
                  if (_isSignUp && widget.role != AppFor.admin) ...[
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isSignUp ? 'Register' : 'Login',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
