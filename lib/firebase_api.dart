import 'package:fcmtest/main.dart';
import 'package:fcmtest/second_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('The token: $fcmToken');
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleBackgroundMessage(event);
    });
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Handling a background message: ${message.messageId}');
    debugPrint('Message data: ${message.data}');
    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');
    }
    if (message.data['body'] != null) {
      print("here if");
      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (_) => SecondPage(
              title: message.data['title'], body: message.data['body'])));
    }
    debugPrint('Title: ${message.notification!.title}');
    debugPrint('Body: ${message.notification!.body}');
    // debugPrint('Payload: ${message.notification!.android!.channelId}');
  }
}
