import 'dart:convert';
import 'dart:developer';
import 'dart:io'; // Added for Platform.isAndroid check

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mad_hms/notifications/get_service_key.dart'; // Added import

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

  // Send notification to a specific patient using their FCM token
  static Future<bool> sendNotificationToPatient(
    String fcmToken,
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    try {
      // Use Firebase Cloud Messaging HTTP v1 API
      const String projectId = "mad-hms"; // Your Firebase project ID
      final String fcmUrl =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // Get the OAuth access token (server key)
      String accessToken = await GetServerKey.getServerKey();

      log('Using FCM URL: $fcmUrl');
      log('Using token length: ${accessToken.length}');

      // Prepare the message payload for v1 API format
      final Map<String, dynamic> message = {
        'message': {
          'token': fcmToken,
          'notification': {'title': title, 'body': body},
          'data': data ?? {},
          'android': {
            'priority': 'high',
            'notification': {'sound': 'default'},
          },
          'apns': {
            'payload': {
              'aps': {'sound': 'default'},
            },
          },
        },
      };

      // Send the HTTP request
      final http.Response response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Use Bearer for OAuth tokens
        },
        body: jsonEncode(message),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final int success = responseData['success'] ?? 0;

        log('Notification sent successfully to token: $fcmToken');
        log('FCM Response: ${response.body}');

        return success > 0;
      } else {
        log('Failed to send notification. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error sending notification: $e');
      return false;
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
