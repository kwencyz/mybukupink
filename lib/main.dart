// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_unnecessary_containers

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mybukupink/screens/article_screen.dart';
import 'package:mybukupink/screens/splash_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Route transitions: Use Navigator to control navigation flow
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // Initial route: Splash screen
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
      '/article': (context) => const ArticleScreen(),
      //'/main_screen': (context) => const MainScreen(),
    },
  ));
}