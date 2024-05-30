import 'package:firebase_core/firebase_core.dart';
import 'package:goals_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:goals_app/pages/welcome_page.dart';

import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const WelcomePage(),
      routes: {
        '/homepage': (context) => const HomePage(),
        '/welcomepage': (context) => const WelcomePage()
      },
    );
  }
}
