import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mad_hms/dashboard.dart';
import 'package:mad_hms/doctor/doctor_home.dart';
import 'package:mad_hms/firebase_options.dart';
import 'package:mad_hms/notifications/get_service_key.dart';
import 'package:mad_hms/notifications/notification_service.dart';
import 'package:mad_hms/patient/patient_home.dart';
import 'package:mad_hms/patient/profile.dart';
import 'package:mad_hms/registration/doctor_registration/doctor_provider.dart';
import 'package:mad_hms/registration/registration.dart';
import 'package:mad_hms/themes/provider.dart';
import 'package:provider/provider.dart';

//app can be used by patients, doctors, and admin
enum AppFor { patient, doctor, admin }

AppFor currUserType = AppFor.doctor;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize the notification service
  //if user is admin, show admin dashboard
  if (currUserType == AppFor.admin) {
    showSplashScreen = false; // Skip splash screen for admin
    // Show admin dashboard
    log('Running as Admin on Web');
    runApp(
      ChangeNotifierProvider(
        create:
            (context) => M3ThemeProvider(
              seedColor: Colors.blue, // Seed color for the theme
              themeMode: ThemeMode.system, // Default theme mode
            ),
        child: MaterialApp(
          title: 'MAD Assignment 4 - Admin',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme:
              M3ThemeProvider(
                seedColor: Colors.blue,
                themeMode: ThemeMode.light,
              ).lightTheme,
          darkTheme:
              M3ThemeProvider(
                seedColor: Colors.blue,
                themeMode: ThemeMode.dark,
              ).darkTheme,
          home: const AdminDashboard(
            // Show admin dashboard
            key: Key('admin_dashboard'),
          ),
        ),
      ),
    );
    return;
  }

  NotificationService.requestPermission();
  NotificationService.getFCMToken()
      .then((value) {
        log('FCM Token: $value');
      })
      .catchError((error) {
        log('Error getting FCM token: $error');
      });
  GetServerKey.getServerKey()
      .then((value) {
        log('Server Key: $value');
      })
      .catchError((error) {
        log('Error getting server key: $error');
      });

  await NotificationService.initLocalNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) => M3ThemeProvider(
                seedColor: Colors.blue, // Seed color for the theme
                themeMode: ThemeMode.system, // Default theme mode
              ),
        ),

        ChangeNotifierProvider(
          create:
              (context) =>
                  PatientProfileProvider(), // Add PatientProfileProvider
        ),

        //create doctor profile provider
        ChangeNotifierProvider(
          create:
              (context) => DoctorProfileProvider(), // Add DoctorProfileProvider
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<M3ThemeProvider>(
        context,
        listen: false,
      );
      themeProvider.surfaceColorOverride();
    });

    NotificationService.firebaseMessagingInit(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAD Assignment 4',
      debugShowCheckedModeBanner: false,

      themeMode: Provider.of<M3ThemeProvider>(context).themeMode,
      theme: Provider.of<M3ThemeProvider>(context).lightTheme,
      darkTheme: Provider.of<M3ThemeProvider>(context).darkTheme,
      home: Builder(
        builder:
            (context) =>
                showSplashScreen ? const SplashScreen() : PatientHome(),
      ),
    );
  }
}

bool showSplashScreen = true;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    handleNavigation();
  }

  Future<void> handleNavigation() async {
    // Navigate to home screen after 2 seconds

    // navigate to registration screen is createdAt is less than 5 seconds in the patient profile provider
    if (!isDoctorApp) {
      final patientProfileProvider = Provider.of<PatientProfileProvider>(
        context,
        listen: false,
      );

      await patientProfileProvider.initPrefs();

      if (patientProfileProvider.createdAt.isBefore(
        DateTime.now().subtract(const Duration(seconds: 123213)),
      )) {
        log(
          'Navigating to Home Screen because created secs ago: ${DateTime.now().difference(patientProfileProvider.createdAt).inSeconds} seconds',
        );
        // If createdAt is more than 5 seconds ago, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PatientHome()),
        );
      } else {
        log(
          'Navigating to Home Screen because created secs ago: ${DateTime.now().difference(patientProfileProvider.createdAt).inSeconds} seconds',
        );
        // If createdAt is less than 5 seconds ago, navigate to registration screen
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          );
        });
      }
    } else {
      // also do the same as above to see if doctor profile is created
      final doctorProfileProvider = Provider.of<DoctorProfileProvider>(
        context,
        listen: false,
      );

      await doctorProfileProvider.initPrefs();

      if (doctorProfileProvider.createdAt.isBefore(
        DateTime.now().subtract(const Duration(seconds: 123123)),
      )) {
        log(
          'Navigating to Home Screen because created secs ago: ${DateTime.now().difference(doctorProfileProvider.createdAt).inSeconds} seconds',
        );
        // If createdAt is more than 5 seconds ago, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorHome()),
        );
      } else {
        log(
          'Navigating to Home Screen because created secs ago: ${DateTime.now().difference(doctorProfileProvider.createdAt).inSeconds} seconds',
        );
        // If createdAt is less than 5 seconds ago, navigate to registration screen
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
            ), // Add your logo image
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Hospital Management System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
