import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mad_hms/firebase_options.dart';
import 'package:mad_hms/themes/provider.dart';
import 'package:provider/provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //print the document in the test collection
  final firestore = FirebaseFirestore.instance;
  firestore
      .collection('test')
      .doc('123')
      .get()
      .then((value) {
        log('Document data: ${value.data()}');
      })
      .catchError((error) {
        log('Error getting document: $error');
      });

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
