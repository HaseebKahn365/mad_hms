import 'dart:developer';
import 'dart:io'; // Added for Platform.isAndroid check

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Added import

class NotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Added FlutterLocalNotificationsPlugin instance
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Added AndroidNotificationChannel
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  static void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      announcement: true,
      sound: true,
      criticalAlert: true,
      carPlay: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else {
      log('User declined or has not accepted permission');
    }
    await initLocalNotifications(); // Added initialization for local notifications
  }

  // Added method to initialize local notifications
  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings
    initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      // onDidReceiveLocalNotification can be added here if needed for older iOS versions
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        // Handle notification tap when app is in foreground or background
        log('notification payload: ${notificationResponse.payload}');
      },
    );

    // Create Android Notification Channel
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  static Future<String> getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      log('FCM Token: $token');
      return token;
    } else {
      log('Failed to get FCM token');
      return '';
    }
  }

  // Added method to show local notification
  static Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // if (notification != null && android != null) { // Check for android specific details if needed
    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon:
                android?.smallIcon ??
                '@mipmap/ic_launcher', // use a default icon
            // other properties...
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload:
            message.data.toString(), // Optional: Pass data to handle on tap
      );
    }
  }

  //start listenting
  static void firebaseMessagingInit(BuildContext context) {
    log('Firebase Messaging Initialized');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log(
        'Received message: ${message.notification?.title} - ${message.notification?.body}',
      );
      // Handle the message here, e.g., show a dialog or notification
      showNotification(message); // Call showNotification
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(
        'Message clicked! ${message.notification?.title} - ${message.notification?.body}',
      );
      // Handle the click action here
    });
  }
}
