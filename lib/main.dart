import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mad_hms/firebase_options.dart';
import 'package:mad_hms/notifications/get_service_key.dart';
import 'package:mad_hms/notifications/notification_service.dart';
import 'package:mad_hms/themes/provider.dart';
import 'package:provider/provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize the notification service

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
    ChangeNotifierProvider(
      create:
          (context) => M3ThemeProvider(
            seedColor: Colors.blue, // Seed color for the theme
            themeMode: ThemeMode.system, // Default theme mode
          ),
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
            (context) => Scaffold(
              appBar: AppBar(
                title: Text('Project HMS'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Welcome to Hospital Management System'),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<M3ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme();
                      },
                      child: Text('Toggle Theme'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
