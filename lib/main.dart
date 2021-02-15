import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'router.dart' as router;
import 'screens/splashscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: firebase_core.Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text('Error while loading firebase');
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return new MaterialApp(
              debugShowCheckedModeBanner: true,
              title: 'Flutter Widgets',
              theme: new ThemeData(
                primarySwatch: Colors.blue,
              ),
              onGenerateRoute: router.generateRoute,
              initialRoute: router.HOME);
        } else {
          return SplashScreen();
        }
      },
    );
  }
}
