import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Services/messaging.dart';
import 'user_state.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkWiz',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      home: const UserState(),
    );
  }


  // This widget is the root of your application.
  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder(
  //     future: _initialization,
  //     builder: (context, snapshot)
  //     {
  //       if(snapshot.connectionState == ConnectionState.waiting)
  //       {
  //         return const MaterialApp(
  //           home: Scaffold(
  //             body: Center(
  //               child: Text('WorkWiz app is being initialized',
  //                 style: TextStyle(
  //                   color: Colors.cyan,
  //                   fontSize: 40,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       }
  //       else if(snapshot.hasError)
  //       {
  //         return const MaterialApp(
  //           home: Scaffold(
  //             body: Center(
  //               child: Text('An error has been occurred',
  //                 style: TextStyle(
  //                   color: Colors.cyan,
  //                   fontSize: 40,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       }
  //       return MaterialApp(
  //         debugShowCheckedModeBanner: false,
  //         title: 'WorkWiz',
  //         theme: ThemeData(
  //           scaffoldBackgroundColor: Colors.white,
  //           primarySwatch: Colors.blue,
  //         ),
  //         home: const UserState(),
  //       );
  //     },
  //   );
  // }
}
