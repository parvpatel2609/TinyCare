import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/notification_services.dart';
import 'package:flutter_application_1/services/shared_pref.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final NotificationServices notificationServices = NotificationServices();
var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
  // print("Background handler");
  // print(message.notification!.title.toString());
  // print(message.notification!.body.toString());
  print("Handling a background & terminated app message");
  notificationServices.showNotification(message);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: SharedpreferenceHelper().getUserToken(), // Check for user token
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return const HomePage(); // User is logged in, show HomePage
            } else {
              return const LoginPage(); // User is not logged in, show LoginPage
            }
          }
        },
      ),
    );
  }
}
