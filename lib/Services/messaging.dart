import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
    'work_wiz_notification_190496', // id
    'This it Title', // title
    'This is description', // description
    importance: Importance.defaultImportance,
    playSound: true
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Push message id: ${message.messageId}');
}

void setupNotificationListener(context) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? remoteNotification = message.notification;
    AndroidNotification? androidNotification = message.notification?.android;

    if(remoteNotification != null && androidNotification != null) {
      flutterLocalNotificationsPlugin.show(
          remoteNotification.hashCode,
          remoteNotification.title,
          remoteNotification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  notificationChannel.id,
                  notificationChannel.name,
                  notificationChannel.description,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher'
              )
          )
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    RemoteNotification? remoteNotification = message.notification;
    AndroidNotification? androidNotification = message.notification?.android;

    if(remoteNotification != null && androidNotification != null) {
      showDialog(context: context, builder: (_) {
        return AlertDialog(
          title: Text(remoteNotification.title!),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(remoteNotification.body!)
              ],
            ),
          ),
        );
      });
    }
  });
}