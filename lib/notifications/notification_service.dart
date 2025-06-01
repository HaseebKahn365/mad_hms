import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

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

  //start listenting
  static void firebaseMessagingInit(BuildContext context) {
    log('Firebase Messaging Initialized');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log(
        'Received message: ${message.notification?.title} - ${message.notification?.body}',
      );
      // Handle the message here, e.g., show a dialog or notification
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(
        'Message clicked! ${message.notification?.title} - ${message.notification?.body}',
      );
      // Handle the click action here
    });
  }
}
